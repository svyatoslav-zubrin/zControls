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

    var cellsReusePool = [String: SZTableViewCell]()
    var cellsOnView = [SZIndexPath: SZTableViewCell]()
    
    var previousScrollPosition: CGPoint = CGPoint.zeroPoint
    var scrollDirection: SZTableViewScrollDirection = (SZScrollDirection.Unknown, SZScrollDirection.Unknown)

    var registeredCellNibs = [String: UINib]()
    var registeredCellClasses = [String: AnyClass]()

    var gridLayout: SZTableViewGridLayout!

    var borderIndexes: SZBorderIndexes! = nil

    // MARK: - Lifecycle

    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }

    func setup()
    {
        self.delegate = self
        self.clipsToBounds = true
    }
    // MARK: - Public

    func dequeReusableCellWithIdentifier(reuseIdentifier: String) -> SZTableViewCell?
    {
        if let cell = cellsReusePool[reuseIdentifier] {
            cellsReusePool[reuseIdentifier] = nil
            return cell
        }
        else {
            // TODO: instantiate new cell and return it
            // return type after that must be changed to non-optional ))
            if let cellNib = registeredCellNibs[reuseIdentifier] {
                if let cell = loadCellFromNib(cellNib) {
                    cell.reuseIdentifier = reuseIdentifier
                    return cell
                }
                else {
                    return nil
                }
            }
            else if let cellClass: AnyClass = registeredCellClasses[reuseIdentifier] {
                if let cell = loadCellFromClass(cellClass) {
                    cell.reuseIdentifier = reuseIdentifier
                    return cell
                }
                else {
                    return nil
                }
            }
            return nil
        }
    }

    private func registerClass(cellClass: AnyClass, forCellWithReuseIdentifier cellReuseIdentifier: String)
    {
        registeredCellClasses[cellReuseIdentifier] = cellClass
        registeredCellNibs[cellReuseIdentifier] = nil
    }

    func registerNib(cellNib: UINib, forCellWithReuseIdentifier cellReuseIdentifier: String)
    {
        registeredCellNibs[cellReuseIdentifier] = cellNib
        registeredCellClasses[cellReuseIdentifier] = nil
    }

    func reloadData()
    {
        // renew data

        // remove all subviews (place to reuse pool if needed)
        for (_, cell) in cellsOnView {
            cell.removeFromSuperview()
        }
        cellsOnView.removeAll(keepCapacity: true)

        gridLayout.prepareLayout()
        borderIndexes = gridLayout.borderVisibleIndexes()

        // add all needed cells again
        for rowIndex in borderIndexes.row.minIndex ... borderIndexes.row.maxIndex {
            for columnIndex in borderIndexes.column.minIndex ... borderIndexes.column.maxIndex {
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

    private func loadCellFromNib(nib: UINib) -> SZTableViewCell?
    {
        return nib.instantiateWithOwner(nil, options: nil).first as? SZTableViewCell
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
        // ...perhaps it may me replaced with correct border indexes calculation in 'borderVisibleIndexes()')
        if let cellOnView = cellsOnView[indexPath] {
            return
        }
        
        let cell = tableDataSource.tableView(self, cellForItemAtIndexPath: indexPath)
        cell.frame = gridLayout.frameForCellAtIndexPath(indexPath)
        self.addSubview(cell)
        cellsOnView[indexPath] = cell
    }
    
    private func removeCellWithIndexPath(indexPath: SZIndexPath)
    {
        if let cell = cellsOnView[indexPath] {
            cell.removeFromSuperview()
            cellsOnView[indexPath] = nil
            cellsReusePool[cell.reuseIdentifier!] = cell
        }
    }
}

// MARK: - Reuse cache operations

extension SZTableView
{
    func cacheCell(cell: SZTableViewCell, forReuseIdentifier reuseIdentifier: String)
    {
        cellsReusePool[reuseIdentifier] = cell
    }
    
    func cachedCellForReuseIdentifier(reuseIdentifier: String) -> SZTableViewCell?
    {
        return cellsReusePool[reuseIdentifier]
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
        let newBorderIndexes = gridLayout.borderVisibleIndexes()
        getScrollDirection()
        
        let indexesToRemove = findCellsForOperation(.Remove, andNewBorderIndexes: newBorderIndexes)
        for indexPath in indexesToRemove {
            removeCellWithIndexPath(indexPath)
        }
        
        let indexesToPlace = findCellsForOperation(.Place, andNewBorderIndexes: newBorderIndexes)
        for indexPath in indexesToPlace {
            placeCellWithIndexPath(indexPath)
        }

        borderIndexes = newBorderIndexes
    }

    func findCellsForOperation(operation: SZTableViewInternalCellOperation,
            andNewBorderIndexes newBorderIndexes: SZBorderIndexes) -> [SZIndexPath]
    {
        var indexes = [SZIndexPath]()
        
        for z in 0...1 { // 0 - for columns, 1 - for rows
            
            let mainItem        = z==0 ? borderIndexes.column : borderIndexes.row
            let oppositeItem    = z==0 ? borderIndexes.row : borderIndexes.column
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
}
