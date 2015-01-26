//
//  SZTableViewGridLayout.swift
//  SZTableViewDemo
//
//  Created by Slava Zubrin on 1/14/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit

class SZTableViewGridLayout: NSObject
{
    // MARK: - Global TODOs:
    // MARK: ...implement correct attributes calculation for the case of variable width/height of column/row
    // MARK: ...implement cache for global paramenters and layout attributes
    // MARK: ...implement expandable Raws and columns
    // MARK: ...implement sorting of all the table with tap on the column/Raw/section header
    // MARK: ...implement possibility to fix the posiiton of column/Raw/section
    // MARK: ...implement filtering of the table over column/Raw/section content
    // MARK: ...implement inline editing of the cell content
    // MARK: -
    
    var layoutDelegate: SZTableViewGridLayoutDelegate! = nil
    weak var tableView: SZTableView! = nil
    
    // geometry constants
    var interColumnSpacing: Float = 0.0
    var interRawSpacing   : Float = 0.0
    
    // privat properties
    typealias LayoutAttributes = [SZIndexPath: SZTableViewLayoutAttributes]
    typealias LayoutInfo = [SZReusableViewKind: LayoutAttributes]
    private var layoutInfo: LayoutInfo! = nil

    // MARK: - Public
    
    func prepareLayout()
    {
        layoutInfo = LayoutInfo()

        prepareLayoutAttributesForRowHeaders()
        prepareLayoutAttributesForColumnHeaders()
        prepareLayoutAttributesForCells()

        self.tableView.contentSize = calculateContentSize()
    }

    private func prepareLayoutAttributesForRowHeaders()
    {
        let rowsCount = tableView.tableDataSource.numberOfRowsInTableView(tableView)

        if isRowHeadersNeeded() && rowsCount > 0 {

            var rowHeadersLayoutAttributes = LayoutAttributes()

            for rowIndex in 0 ..< rowsCount {
                let indexPath = SZIndexPath.indexPathOfRowHeaderAtIndex(rowIndex)
                let viewAttributes = SZTableViewLayoutAttributes(forReusableViewOfKind: SZReusableViewKind.RowHeader,
                        atIndexPath: indexPath)
                viewAttributes.frame = calculateFrameForReusableViewOfKind(SZReusableViewKind.RowHeader,
                        atIndexPath: indexPath)
                rowHeadersLayoutAttributes[indexPath] = viewAttributes
            }

            layoutInfo[SZReusableViewKind.RowHeader] = rowHeadersLayoutAttributes
        }
    }

    private func prepareLayoutAttributesForColumnHeaders()
    {
        let columnsCount = tableView.tableDataSource.numberOfColumnsInTableView(tableView)

        if isColumnHeadersNeeded() && columnsCount > 0 {

            var columnHeadersLayoutAttributes = LayoutAttributes()

            for columnIndex in 0 ..< columnsCount {
                let indexPath = SZIndexPath.indexPathOfColumnHeaderAtIndex(columnIndex)
                let viewAttributes = SZTableViewLayoutAttributes(forReusableViewOfKind: SZReusableViewKind.ColumnHeader,
                        atIndexPath: indexPath)
                viewAttributes.frame = calculateFrameForReusableViewOfKind(SZReusableViewKind.ColumnHeader,
                        atIndexPath: indexPath)
                columnHeadersLayoutAttributes[indexPath] = viewAttributes
            }

            layoutInfo[SZReusableViewKind.ColumnHeader] = columnHeadersLayoutAttributes
        }
    }

    private func prepareLayoutAttributesForCells()
    {
        let rowsCount = tableView.tableDataSource.numberOfRowsInTableView(tableView)
        let columnsCount = tableView.tableDataSource.numberOfColumnsInTableView(tableView)
        let tableHasContent = columnsCount > 0 && rowsCount > 0

        if tableHasContent {

            var cellsLayoutAttributes = LayoutAttributes()

            for rowIndex in 0 ..< rowsCount {
                for columnIndex in 0..<columnsCount {
                    let indexPath = SZIndexPath(rowSectionIndex: 0,
                            columnSectionIndex: 0,
                            rowIndex: rowIndex,
                            columnIndex: columnIndex)
                    let cellAttributes = SZTableViewLayoutAttributes(forCellWithIndexPath: indexPath)
                    cellAttributes.frame = calculateFrameForCellAtIndexPath(indexPath)
                    cellsLayoutAttributes[indexPath] = cellAttributes
                }
            }

            layoutInfo[SZReusableViewKind.Cell] = cellsLayoutAttributes
        }
    }

    func frameForReusableViewOfKind(kind: SZReusableViewKind, atIndexPath indexPath: SZIndexPath) -> CGRect
    {
        if let viewsLayoutAttributes = layoutInfo[kind] as LayoutAttributes? {
            if let viewAttributes = viewsLayoutAttributes[indexPath] as SZTableViewLayoutAttributes? {
                return viewAttributes.frame
            }
        }
        return CGRect.zeroRect
    }

    // MARK: - Helpers

    func cellsVisibleBorderIndexes() -> SZBorderIndexes?
    {
        var indexPathsOfVisibleCells = [SZIndexPath]()

        let visibleScrollRect = CGRect(x: tableView.contentOffset.x,
                                       y: tableView.contentOffset.y,
                                       width: tableView.bounds.width,
                                       height: tableView.bounds.height)

        if let cellsLayoutAttributes = layoutInfo[SZReusableViewKind.Cell] as LayoutAttributes? {
            for (indexPath, attributes) in cellsLayoutAttributes {
                if (CGRectIntersectsRect(visibleScrollRect, attributes.frame)) {
                    indexPathsOfVisibleCells.append(indexPath)
                }
            }
        }

        let maxColumnIndex = maxElement(indexPathsOfVisibleCells.map{$0.columnIndex})
        let minColumnIndex = minElement(indexPathsOfVisibleCells.map{$0.columnIndex})
        let maxRawIndex    = maxElement(indexPathsOfVisibleCells.map{$0.rowIndex})
        let minRawIndex    = minElement(indexPathsOfVisibleCells.map{$0.rowIndex})

        return ((minColumnIndex, maxColumnIndex), (minRawIndex, maxRawIndex))
    }

    func headersVisibleBorderIndexesForHeaderKind(kind: SZReusableViewKind) -> SZBorderIndexes?
    {
        var indexPathsOfVisibleHeaders = [SZIndexPath]()

        let visibleScrollRect = CGRect(x: tableView.contentOffset.x,
                y: tableView.contentOffset.y,
                width: tableView.bounds.width,
                height: tableView.bounds.height)

        if kind == SZReusableViewKind.RowHeader && tableView.rowHeadersAlwaysVisible {
            prepareLayoutAttributesForRowHeaders()
        }

        if kind == SZReusableViewKind.ColumnHeader && tableView.columnHeadersAlwaysVisible {
            prepareLayoutAttributesForColumnHeaders()
        }

        if let headersLayoutAttributes = layoutInfo[kind] as LayoutAttributes? {
            for (indexPath, attributes) in headersLayoutAttributes {
                if (CGRectIntersectsRect(visibleScrollRect, attributes.frame)) {
                    indexPathsOfVisibleHeaders.append(indexPath)
                }
            }
        }

        if indexPathsOfVisibleHeaders.count != 0 {
            let maxColumnIndex = maxElement(indexPathsOfVisibleHeaders.map{$0.columnIndex})
            let minColumnIndex = minElement(indexPathsOfVisibleHeaders.map{$0.columnIndex})
            let maxRawIndex    = maxElement(indexPathsOfVisibleHeaders.map{$0.rowIndex})
            let minRawIndex    = minElement(indexPathsOfVisibleHeaders.map{$0.rowIndex})
            return ((minColumnIndex, maxColumnIndex), (minRawIndex, maxRawIndex))
        }
        else {
            return nil
        }
    }
    
    // MARK: - Private
    
    private func calculateFrameForReusableViewOfKind(kind: SZReusableViewKind,
        atIndexPath indexPath: SZIndexPath) -> CGRect
    {
        var frame: CGRect? = nil
        
        switch kind {
        case .Cell:
            frame = calculateFrameForCellAtIndexPath(indexPath)
        case .RowHeader:
            frame = calculateFrameForRowHeaderAtIndexPath(indexPath)
        case .ColumnHeader:
            frame = calculateFrameForColumnHeaderAtIndexPath(indexPath)
        default:
            frame = CGRect.zeroRect
        }
        
        return frame!
    }
    
    private func calculateFrameForCellAtIndexPath(indexPath: SZIndexPath) -> CGRect
    {
        var height = layoutDelegate.heightOfRaw(indexPath.rowIndex, ofTableView: tableView)

        var originY = columnHeadersHeight() + (columnHeadersHeight() == 0.0 ? 0.0 : interRawSpacing)
        for rowIndex in 0 ..< indexPath.rowIndex {
            originY += layoutDelegate.heightOfRaw(rowIndex, ofTableView: tableView) + interRawSpacing
        }

        var width = layoutDelegate.widthOfColumn(indexPath.columnIndex, ofTableView: tableView)
        var originX = rowHeadersWidth() + (rowHeadersWidth() == 0.0 ? 0.0 : interColumnSpacing)
        for columnIndex in 0 ..< indexPath.columnIndex {
            originX += layoutDelegate.widthOfColumn(columnIndex, ofTableView: tableView) + interColumnSpacing
        }

        return CGRect(x     : CGFloat(originX),
                      y     : CGFloat(originY),
                      width : CGFloat(width),
                      height: CGFloat(height))
    }
    
    private func calculateFrameForRowHeaderAtIndexPath(indexPath: SZIndexPath) -> CGRect
    {
        var frame = CGRect.zeroRect
        
        if let headerWidth = layoutDelegate.widthForRowHeadersOfTableView?(tableView) {
            let rowHeight = layoutDelegate.heightOfRaw(indexPath.rowIndex, ofTableView: tableView)

            var originX: Float = tableView.rowHeadersAlwaysVisible
                                    ? Float(tableView.contentOffset.x)
                                    : 0.0
            var originY: Float = layoutDelegate.heightForColumnHeadersOfTableView?(tableView) != nil
                                    ? layoutDelegate.heightForColumnHeadersOfTableView!(tableView) + interRawSpacing
                                    : 0.0
            
            for rowIndex in 0 ..< indexPath.rowIndex {
                originY += layoutDelegate.heightOfRaw(rowIndex, ofTableView: tableView) + interRawSpacing
            }
            
            frame = CGRect(x: CGFloat(originX),
                           y: CGFloat(originY),
                           width: CGFloat(headerWidth),
                           height: CGFloat(rowHeight))
        }
        
        return frame
    }

    private func calculateFrameForColumnHeaderAtIndexPath(indexPath: SZIndexPath) -> CGRect
    {
        var frame = CGRect.zeroRect
        
        if let headerHeight = layoutDelegate.heightForColumnHeadersOfTableView?(tableView) {
            let columnWidth = layoutDelegate.widthOfColumn(indexPath.rowIndex, ofTableView: tableView)
            
            var originX: Float = layoutDelegate.widthForRowHeadersOfTableView?(tableView) != nil
                                    ? layoutDelegate.widthForRowHeadersOfTableView!(tableView) + interColumnSpacing
                                    : 0.0
            var originY: Float = tableView.columnHeadersAlwaysVisible
                                    ? Float(tableView.contentOffset.y)
                                    : 0.0

            for columnIndex in 0 ..< indexPath.columnIndex {
                originX += layoutDelegate.widthOfColumn(columnIndex, ofTableView: tableView) + interColumnSpacing
            }
            
            frame = CGRect(x: CGFloat(originX),
                           y: CGFloat(originY),
                           width: CGFloat(columnWidth),
                           height: CGFloat(headerHeight))
        }
        
        return frame
    }

    private func calculateContentSize() -> CGSize
    {
        let rowsCount = tableView.tableDataSource.numberOfRowsInTableView(tableView)
        var height = layoutDelegate.heightOfRaw(rowsCount - 1, ofTableView: tableView)
                     + columnHeadersHeight()
                     + (columnHeadersHeight() == 0.0 ? 0.0 : interRawSpacing)
        for rowIndex in 1 ..< rowsCount {
            height += layoutDelegate.heightOfRaw(rowIndex, ofTableView: tableView) + interRawSpacing
        }
        
        
        let columnsCount = tableView.tableDataSource.numberOfColumnsInTableView(tableView)
        var width = layoutDelegate.widthOfColumn(columnsCount - 1, ofTableView: tableView)
                    + rowHeadersWidth()
                    + (rowHeadersWidth() == 0.0 ? 0.0 : interColumnSpacing)
        for columnIndex in 1 ..< columnsCount {
            width += layoutDelegate.widthOfColumn(columnIndex, ofTableView: tableView) + interColumnSpacing
        }
        
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
    
    // Helpers
    
    private func isColumnHeadersNeeded() -> Bool
    {
        if let m = layoutDelegate.heightForColumnHeadersOfTableView? {
            return true
        }
        else {
            return false
        }
    }
    
    private func columnHeadersHeight() -> Float
    {
        return layoutDelegate.heightForColumnHeadersOfTableView?(tableView) != nil
                ? layoutDelegate.heightForColumnHeadersOfTableView!(tableView)
                : 0.0
    }

    private func rowHeadersWidth() -> Float
    {
        return layoutDelegate.widthForRowHeadersOfTableView?(tableView) != nil
                ? layoutDelegate.widthForRowHeadersOfTableView!(tableView)
                : 0.0
    }

    private func isRowHeadersNeeded() -> Bool
    {
        if let m = layoutDelegate.widthForRowHeadersOfTableView? {
            return true
        }
        else {
            return false
        }
    }
}
