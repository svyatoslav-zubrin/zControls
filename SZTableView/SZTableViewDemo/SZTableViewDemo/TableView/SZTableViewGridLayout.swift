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
        var newLayoutInfo = LayoutInfo()
        var cellsLayoutAttributes = LayoutAttributes()
        
        let rowsCount = tableView.tableDataSource.numberOfRowsInTableView(tableView)
        let columnsCount = tableView.tableDataSource.numberOfColumnsInTableView(tableView)
        let tableHasContent = columnsCount > 0 && rowsCount > 0
        
        if tableHasContent {
            for rowIndex in 0..<rowsCount {
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
        }
        
        newLayoutInfo[SZReusableViewKind.Cell] = cellsLayoutAttributes
        layoutInfo = newLayoutInfo
        
        self.tableView.contentSize = calculateContentSize()
    }

    func frameForCellAtIndexPath(indexPath: SZIndexPath) -> CGRect
    {
        if let cellsLayoutAttributes = layoutInfo[SZReusableViewKind.Cell] as LayoutAttributes? {
            if let cellAttributes = cellsLayoutAttributes[indexPath] as SZTableViewLayoutAttributes? {
                return cellAttributes.frame
            }
        }
        return CGRect.zeroRect
    }

    // MARK: - Helpers

    func borderVisibleIndexes() -> SZBorderIndexes
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

        var maxColumnIndex = maxElement{indexPathsOfVisibleCells.reduce{$0.columnIndex}}
        var minColumnIndex = minElement{indexPathsOfVisibleCells.reduce{$0.columnIndex}}
        var maxRawIndex = maxElement{indexPathsOfVisibleCells.reduce{$0.rawIndex}}
        var minRawIndex = minElement{indexPathsOfVisibleCells.reduce{$0.rawIndex}}

        return ((minColumnIndex, maxColumnIndex), (minRawIndex, maxRawIndex))
    }
    
    // MARK: - Private
    
    private func calculateFrameForCellAtIndexPath(indexPath: SZIndexPath) -> CGRect
    {
        var height = layoutDelegate.heightOfRaw(indexPath.columnIndex, ofTableView: tableView)
        var originY: Float = 0.0
        for rowIndex in 0..<indexPath.rowIndex {
            originY += layoutDelegate.heightOfRaw(rowIndex, ofTableView: tableView) + interRawSpacing
        }

        var width = layoutDelegate.widthOfColumn(indexPath.columnIndex, ofTableView: tableView)
        var originX: Float = 0.0
        for columnIndex in 0..<indexPath.columnIndex {
            originX += layoutDelegate.widthOfColumn(columnIndex, ofTableView: tableView) + interColumnSpacing
        }

        return CGRect(x     : CGFloat(originX),
                      y     : CGFloat(originY),
                      width : CGFloat(width),
                      height: CGFloat(height))
    }
    
    private func calculateContentSize() -> CGSize
    {
        let rowsCount = tableView.tableDataSource.numberOfRowsInTableView(tableView)
        var height = layoutDelegate.heightOfRaw(rowsCount - 1, ofTableView: tableView)
        for rowIndex in 1..<rowsCount {
            height += layoutDelegate.heightOfRaw(rowIndex, ofTableView: tableView) + interRawSpacing
        }
        
        
        let columnsCount = tableView.tableDataSource.numberOfColumnsInTableView(tableView)
        var width = layoutDelegate.widthOfColumn(columnsCount - 1, ofTableView: tableView)
        for columnIndex in 1..<columnsCount {
            width += layoutDelegate.widthOfColumn(columnIndex, ofTableView: tableView) + interColumnSpacing
        }
        
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
}
