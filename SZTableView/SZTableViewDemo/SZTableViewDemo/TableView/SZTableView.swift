//
//  SZTableView.swift
//  SZTableViewDemo
//
//  Created by Slava Zubrin on 1/14/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit

enum SZScrollDirection
{
    case Unknown
    case FromMinToMax
    case FromMaxToMin
}
typealias SZTableViewScrollDirection = (vertical: SZScrollDirection, horizontal: SZScrollDirection)


class SZTableView
    : UIScrollView
    , UIScrollViewDelegate
{
    @IBOutlet weak var tableDataSource: SZTableViewDataSource!
    @IBOutlet weak var tableDelegate: SZTableViewDelegate!

    var reusePool = [String: SZTableViewReusableView]()
    var cellsOnView = [SZIndexPath: SZTableViewCell]()
    var headersOnView = [SZIndexPath: SZTableViewReusableView]()
    
    var previousScrollPosition: CGPoint = CGPoint.zeroPoint
    var scrollDirection: SZTableViewScrollDirection = (SZScrollDirection.Unknown, SZScrollDirection.Unknown)

    var registeredViewNibs = [String: UINib]()
    var registeredViewClasses = [String: AnyClass]()

    var gridLayout: SZTableViewGridLayout!

    var cellsBorderIndexes: SZBorderIndexes! = nil
    var rowHeadersBorderIndexes: SZBorderIndexes? = nil
    var columnHeadersBorderIndexes: SZBorderIndexes? = nil

    // MARK: - Lifecycle

    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup()
    {
        self.delegate = self
        self.clipsToBounds = true
    }
    
    // MARK: - Public

    func dequeReusableViewOfKind(kind: SZReusableViewKind,
                                 withReuseIdentifier reuseIdentifier: String) -> SZTableViewReusableView?
    {
        if let view = reusePool[reuseIdentifier] {
            reusePool[reuseIdentifier] = nil
            return view
        }
        else {
            // TODO: instantiate new cell and return it
            // return type after that must be changed to non-optional ))
            if let nib = registeredViewNibs[reuseIdentifier] {
                if let view = loadReusableViewFromNib(nib) {
                    view.reuseIdentifier = reuseIdentifier
                    view.kind = kind
                    return view
                }
                else {
                    return nil
                }
            }
            else if let cellClass: AnyClass = registeredViewClasses[reuseIdentifier] {
                if let view = loadCellFromClass(cellClass) {
                    view.reuseIdentifier = reuseIdentifier
                    view.kind = kind
                    return view
                }
                else {
                    return nil
                }
            }
            return nil
        }
    }

    private func registerClass(cellClass: AnyClass,
                               forCellWithReuseIdentifier cellReuseIdentifier: String)
    {
        registeredViewClasses[cellReuseIdentifier] = cellClass
        registeredViewNibs[cellReuseIdentifier] = nil
    }

    func registerNib(nib: UINib, forViewWithReuseIdentifier reuseIdentifier: String)
    {
        registeredViewNibs[reuseIdentifier] = nib
        registeredViewClasses[reuseIdentifier] = nil
    }

    func reloadData() {
        // renew data

        // remove all subviews (place to reuse pool if needed)
        for (_, cell) in cellsOnView {
            cell.removeFromSuperview()
        }
        cellsOnView.removeAll(keepCapacity: true)
        for (_, header) in headersOnView {
            header.removeFromSuperview()
        }
        headersOnView.removeAll(keepCapacity: true)

        // 
        gridLayout.prepareLayout()
        cellsBorderIndexes = gridLayout.cellsVisibleBorderIndexes()
        rowHeadersBorderIndexes = gridLayout.headersVisibleBorderIndexesForHeaderKind(SZReusableViewKind.RowHeader)
        columnHeadersBorderIndexes = gridLayout.headersVisibleBorderIndexesForHeaderKind(SZReusableViewKind.ColumnHeader)

        // add all needed headers
        if rowHeadersBorderIndexes != nil {
            for rowIndex in rowHeadersBorderIndexes!.row.minIndex ... rowHeadersBorderIndexes!.row.maxIndex {
                let indexPath = SZIndexPath.indexPathOfRowHeaderAtIndex(rowIndex)
                placeHeaderOfKind(SZReusableViewKind.RowHeader, atIndexPath: indexPath)
            }
            for columnIndex in columnHeadersBorderIndexes!.column.minIndex ... columnHeadersBorderIndexes!.column.maxIndex {
                let indexPath = SZIndexPath.indexPathOfColumnHeaderAtIndex(columnIndex)
                placeHeaderOfKind(SZReusableViewKind.ColumnHeader, atIndexPath: indexPath)
            }
        }
        // add all needed cells again
        for rowIndex in cellsBorderIndexes.row.minIndex ... cellsBorderIndexes.row.maxIndex {
            for columnIndex in cellsBorderIndexes.column.minIndex ... cellsBorderIndexes.column.maxIndex {
                let indexPath = SZIndexPath(rowSectionIndex: 0,
                                            columnSectionIndex: 0,
                                            rowIndex: rowIndex,
                                            columnIndex: columnIndex)
                placeCellWithIndexPath(indexPath)
            }
        }

        setNeedsDisplay()
    }

    // MARK: - Private

    private func loadReusableViewFromNib(nib: UINib) -> SZTableViewReusableView?
    {
        let array = nib.instantiateWithOwner(nil, options: nil)
        return array.first as? SZTableViewReusableView
    }

    private func loadCellFromClass(cellClass: AnyClass) -> SZTableViewCell?
    {
//        if cellClass.self is SZTableViewCell.Type {
//            if let cell = cellClass() {
//                return cell
//            }
//        }
        return nil
    }
    
    private func getScrollDirection()
    {
        var d: SZTableViewScrollDirection = (SZScrollDirection.Unknown, SZScrollDirection.Unknown)
        
        if contentOffset.y < previousScrollPosition.y {
            d.vertical = SZScrollDirection.FromMaxToMin
        }
        else if contentOffset.y > previousScrollPosition.y {
            d.vertical = SZScrollDirection.FromMinToMax
        }
        
        if contentOffset.x < previousScrollPosition.x {
            d.horizontal = SZScrollDirection.FromMaxToMin
        }
        else if contentOffset.x > previousScrollPosition.x {
            d.horizontal = SZScrollDirection.FromMinToMax
        }

        previousScrollPosition = contentOffset
        
        scrollDirection = d
    }
    
    private func placeCellWithIndexPath(indexPath: SZIndexPath)
    {
        // prevent cells duplication
        // ...perhaps it may me replaced with correct border indexes calculation in 'borderVisibleIndexes()'
        if let cellOnView = cellsOnView[indexPath] {
            return
        }
        
        let cell = tableDataSource.tableView(self, cellForItemAtIndexPath: indexPath)
        cell.frame = gridLayout.frameForReusableViewOfKind(SZReusableViewKind.Cell, atIndexPath: indexPath)
        self.addSubview(cell)
        cellsOnView[indexPath] = cell
    }
    
    private func removeCellWithIndexPath(indexPath: SZIndexPath)
    {
        if let cell = cellsOnView[indexPath] {
            cell.removeFromSuperview()
            cellsOnView[indexPath] = nil
            reusePool[cell.reuseIdentifier!] = cell
        }
    }
    
    private func placeHeaderOfKind(kind: SZReusableViewKind, atIndexPath indexPath: SZIndexPath)
    {
        // prevent cells duplication
        // ...perhaps it may me replaced with correct border indexes calculation in 'borderVisibleIndexes()'
        if let cellOnView = headersOnView[indexPath] {
            return
        }
        
        let header = kind == SZReusableViewKind.ColumnHeader
                        ? tableDataSource.tableView!(self, headerForColumnAtIndex: indexPath.columnIndex)
                        : tableDataSource.tableView!(self, headerForRowAtIndex: indexPath.rowIndex)
        header.frame = gridLayout.frameForReusableViewOfKind(kind, atIndexPath: indexPath)
        self.addSubview(header)
        headersOnView[indexPath] = header
    }
    
    private func removeHeaderAtIndexPath(indexPath: SZIndexPath)
    {
        if let header = headersOnView[indexPath] {
            header.removeFromSuperview()
            headersOnView[indexPath] = nil
            reusePool[header.reuseIdentifier!] = header
        }
    }
}

// MARK: - UIScrollViewDelegate

extension SZTableView: UIScrollViewDelegate
{
    enum SZTableViewInternalCellOperation
    {
        case Place
        case Remove
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        getScrollDirection()

        // column headers
        let newColumnHeadersBorderIndexes = gridLayout.headersVisibleBorderIndexesForHeaderKind(SZReusableViewKind.ColumnHeader)
        let columnHedearsToRemove = findHeadersOfKind(SZReusableViewKind.ColumnHeader,
                                                     forOperation: .Remove,
                                                     andNewBorderIndexes: newColumnHeadersBorderIndexes!)
        for indexPath in columnHedearsToRemove {
            removeHeaderAtIndexPath(indexPath)
        }
        let columnHeadersToPlace = findHeadersOfKind(SZReusableViewKind.ColumnHeader,
                forOperation: .Place,
                andNewBorderIndexes: newColumnHeadersBorderIndexes!)
        for indexPath in columnHeadersToPlace {
            placeHeaderOfKind(SZReusableViewKind.ColumnHeader, atIndexPath: indexPath)
        }
        columnHeadersBorderIndexes = newColumnHeadersBorderIndexes

        // row headers
        let newRowHeadersBorderIndexes = gridLayout.headersVisibleBorderIndexesForHeaderKind(SZReusableViewKind.RowHeader)
        let rowHeadersToRemove = findHeadersOfKind(SZReusableViewKind.RowHeader,
                forOperation: .Remove,
                andNewBorderIndexes: newRowHeadersBorderIndexes!)
        for indexPath in rowHeadersToRemove {
            removeHeaderAtIndexPath(indexPath)
        }
        let rowHeadersToPlace = findHeadersOfKind(SZReusableViewKind.RowHeader,
                forOperation: .Place,
                andNewBorderIndexes: newRowHeadersBorderIndexes!)
        for indexPath in rowHeadersToPlace {
            placeHeaderOfKind(SZReusableViewKind.RowHeader, atIndexPath: indexPath)
        }
        rowHeadersBorderIndexes = newRowHeadersBorderIndexes

        // cells
        let newCellsBorderIndexes = gridLayout.cellsVisibleBorderIndexes()

        let cellIndexesToRemove = findCellsForOperation(.Remove, andNewBorderIndexes: newCellsBorderIndexes)
        for indexPath in cellIndexesToRemove {
            removeCellWithIndexPath(indexPath)
        }
        
        let cellIndexesToPlace = findCellsForOperation(.Place, andNewBorderIndexes: newCellsBorderIndexes)
        for indexPath in cellIndexesToPlace {
            placeCellWithIndexPath(indexPath)
        }

        cellsBorderIndexes = newCellsBorderIndexes

        // global
        setNeedsDisplay()
    }

    func findCellsForOperation(operation: SZTableViewInternalCellOperation,
                               andNewBorderIndexes newBorderIndexes: SZBorderIndexes) -> [SZIndexPath]
    {
        var indexes = [SZIndexPath]()
        
        for z in 0...1 { // 0 - for columns, 1 - for rows
            
            let mainItem        = z==0 ? cellsBorderIndexes.column : cellsBorderIndexes.row
            let oppositeItem    = z==0 ? cellsBorderIndexes.row : cellsBorderIndexes.column
            let newMainItem     = z==0 ? newBorderIndexes.column : newBorderIndexes.row
            let newOppositeItem = z==0 ? newBorderIndexes.row : newBorderIndexes.column
            let scrollDirectionToHandle = z==0 ? scrollDirection.horizontal : scrollDirection.vertical
            
            if scrollDirectionToHandle == SZScrollDirection.FromMinToMax {
                let maxIndexValue = operation == .Place ? newMainItem.maxIndex + 1 : newMainItem.maxIndex
                if mainItem.maxIndex < maxIndexValue {
                    for mainIndex in mainItem.maxIndex ... newMainItem.maxIndex {
                        for oppositeIndex in newOppositeItem.minIndex ... newOppositeItem.maxIndex {
                            let columnIndex = z==0 ? mainIndex : oppositeIndex
                            let rowIndex    = z==0 ? oppositeIndex : mainIndex
                            indexes.append(SZIndexPath(rowSectionIndex: 0,
                                columnSectionIndex: 0,
                                rowIndex: rowIndex,
                                columnIndex: columnIndex))
                        }
                    }
                }
            }
            else if scrollDirectionToHandle == SZScrollDirection.FromMaxToMin {
                let maxIndexValue = operation == .Place ? newMainItem.minIndex + 1 : newMainItem.minIndex
                if mainItem.minIndex < maxIndexValue {
                    for mainIndex in mainItem.minIndex ... maxIndexValue {
                        for oppositeIndex in newOppositeItem.minIndex ... newOppositeItem.maxIndex {
                            let columnIndex = z==0 ? mainIndex : oppositeIndex
                            let rowIndex    = z==0 ? oppositeIndex : mainIndex
                            indexes.append(SZIndexPath(rowSectionIndex: 0,
                                columnSectionIndex: 0,
                                rowIndex: rowIndex,
                                columnIndex: columnIndex))
                        }
                    }
                }
            }
        }
        
        return indexes
    }
    
    func findHeadersOfKind(kind: SZReusableViewKind,
                           forOperation operation: SZTableViewInternalCellOperation,
                           andNewBorderIndexes newBorderIndexes: SZBorderIndexes) -> [SZIndexPath]
    {
        var indexes = [SZIndexPath]()

        // columns
        let newHeadersBorderIndexes = gridLayout.headersVisibleBorderIndexesForHeaderKind(kind)
        let isColumns = kind == SZReusableViewKind.ColumnHeader
        let borderIndexes = isColumns ? columnHeadersBorderIndexes : rowHeadersBorderIndexes
        if isColumns { // column headers
            if scrollDirection.horizontal == .FromMinToMax {
                if operation == .Remove {
                    let minIndex = columnHeadersBorderIndexes!.column.minIndex
                    let maxIndex = newHeadersBorderIndexes!.column.minIndex
                    if minIndex < maxIndex {
                        for columnIndex in minIndex ... maxIndex {
                            indexes.append(SZIndexPath.indexPathOfColumnHeaderAtIndex(columnIndex))
                        }
                    }
                }
                else {
                    let minIndex = columnHeadersBorderIndexes!.column.maxIndex
                    let maxIndex = newHeadersBorderIndexes!.column.maxIndex + 1
                    if minIndex < maxIndex {
                        for columnIndex in minIndex ... maxIndex {
                            indexes.append(SZIndexPath.indexPathOfColumnHeaderAtIndex(columnIndex))
                        }
                    }
                }
            }
            else if scrollDirection.horizontal == .FromMaxToMin {
                if operation == .Remove {
                    let minIndex = columnHeadersBorderIndexes!.column.maxIndex
                    let maxIndex = newHeadersBorderIndexes!.column.maxIndex
                    if minIndex < maxIndex {
                        for columnIndex in minIndex ... maxIndex {
                            indexes.append(SZIndexPath.indexPathOfColumnHeaderAtIndex(columnIndex))
                        }
                    }
                }
                else {
                    let minIndex = columnHeadersBorderIndexes!.column.minIndex
                    let maxIndex = newHeadersBorderIndexes!.column.minIndex + 1
                    if minIndex < maxIndex {
                        for columnIndex in minIndex ... maxIndex {
                            indexes.append(SZIndexPath.indexPathOfColumnHeaderAtIndex(columnIndex))
                        }
                    }
                }
            }
        }
        else { // row headers
            if scrollDirection.vertical == .FromMinToMax {
                if operation == .Remove {
                    let minIndex = rowHeadersBorderIndexes!.row.minIndex
                    let maxIndex = newHeadersBorderIndexes!.row.minIndex
                    if minIndex < maxIndex {
                        for rowIndex in minIndex ... maxIndex {
                            indexes.append(SZIndexPath.indexPathOfRowHeaderAtIndex(rowIndex))
                        }
                    }
                }
                else {
                    let minIndex = rowHeadersBorderIndexes!.row.maxIndex
                    let maxIndex = newHeadersBorderIndexes!.row.maxIndex + 1
                    if minIndex < maxIndex {
                        for rowIndex in minIndex ... maxIndex {
                            indexes.append(SZIndexPath.indexPathOfRowHeaderAtIndex(rowIndex))
                        }
                    }
                }
            }
            else if scrollDirection.vertical == .FromMaxToMin {
                if operation == .Remove {
                    let minIndex = rowHeadersBorderIndexes!.row.maxIndex
                    let maxIndex = newHeadersBorderIndexes!.row.maxIndex
                    if minIndex < maxIndex {
                        for rowIndex in minIndex ... maxIndex {
                            indexes.append(SZIndexPath.indexPathOfRowHeaderAtIndex(rowIndex))
                        }
                    }
                }
                else {
                    let minIndex = rowHeadersBorderIndexes!.row.minIndex
                    let maxIndex = newHeadersBorderIndexes!.row.minIndex + 1
                    if minIndex < maxIndex {
                        for rowIndex in minIndex ... maxIndex {
                            indexes.append(SZIndexPath.indexPathOfRowHeaderAtIndex(rowIndex))
                        }
                    }
                }
            }
        }


        return indexes
    }
}
