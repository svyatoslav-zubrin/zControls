//
//  SZTableViewLayout.swift
//  SZTableViewDemo
//
//  Created by Slava Zubrin on 1/12/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit

enum SZReusableViewKind {
    case Cell
    case ColumnHeader
    case RowHeader
    case ColumnsSectionHeader
    case RowsSectionHeader
}

// MARK: - SZTableViewDataSource protocol

protocol SZTableViewDataSource {
    
    func numberOfColumnsSectionsInTableView(_tableView: UICollectionView) -> Int
    func numberOfRowsSectionsInTableView(tableView: UICollectionView) -> Int
    func numberOfColumnsInSection(_sectionIndex: Int, ofTableView tableView: UICollectionView) -> Int
    func numberOfRowsInSection(_sectionIndex: Int, ofTableView tableView: UICollectionView) -> Int
    
    // geometry
    func widthOfColumn(atIndexPath indexPath: SZIndexPath, ofTableView tableView: UICollectionView) -> Float
    func hightOfRow(atIndexPath indexPath: SZIndexPath, ofTableView tableView: UICollectionView) -> Float

    // view for cells
    func dequeCell(atIndexPath indexPath: SZIndexPath, withReuseIdentifier reuseID: String, forTableView tableView: UICollectionView) -> UICollectionViewCell
    
    // views for headers of different kind
    func dequeHeaderForIndexPath(indexPath: SZIndexPath, ofHeaderKind headerKind: SZReusableViewKind, withReuseIdentifier reuseID: String, forTableView tableView: UICollectionView) -> UICollectionReusableView
}

// MARK: - SZTableViewDelegate protocol

protocol SZTableViewDelegate {
    
    func tableView(_tableView: UICollectionView, didSelectCellAtIndexPath   indexPath: SZIndexPath)
    func tableView(_tableView: UICollectionView, didSelectHeaderAtIndexPath indexPath: SZIndexPath)
}

// MARK: - SZTableViewLayout

class SZTableViewLayout: UICollectionViewLayout {
    
    // MARK: - Global TODOs:
    // MARK: ...implement correct attributes calculation
    // MARK: ...implement NSIndexPath<->SZIndexPath conversion logic
    // MARK: ...implement NSIndexPath->SZReusableViewKind conversion logic
    // MARK: ...implement cache for global paramenters and layout attributes
    // MARK: ...implement expandable Raws and columns
    // MARK: ...implement sorting of all the table with tap on the column/Raw/section header
    // MARK: ...implement possibility to fix the posiiton of column/Raw/section
    // MARK: ...implement filtering of the table over column/Raw/section content
    // MARK: ...implement inline editing of the cell content
    // MARK: -
    
    var dataSource: SZTableViewDataSource! = nil
    var delegate  : SZTableViewDelegate!   = nil
    
    // geometry constants
    let interColumnSpacing: Int = 0
    let interRawSpacing   : Int = 0
    
    // privat properties
    typealias LayoutAttributes = [SZIndexPath: UICollectionViewLayoutAttributes]
    typealias LayoutInfo = [SZReusableViewKind: LayoutAttributes]
    private var layoutInfo: LayoutInfo! = nil
    
    // MARK: - Core layout process
    
    /*
    The 'prepareLayout' method is your opportunity to perform whatever calculations are needed
    to determine the position of the cells and views in the layout. At a minimum, you should
    compute enough information in this method to be able to return the overall size of the
    content area.
    */
    override func prepareLayout() {
        var newLayoutInfo = LayoutInfo()
        
        let rowSectionsCount = dataSource.numberOfRowsSectionsInTableView(self.collectionView!)
        let columnSectionsCount = dataSource.numberOfColumnsSectionsInTableView(self.collectionView!)
        let tableHasContent = columnSectionsCount > 0 && rowSectionsCount > 0

        if tableHasContent {
            var cellsLayoutAttributes = LayoutAttributes()
            // cells
            for rowSectionIndex in 0..<rowSectionsCount {
                for columnSectionIndex in 0..<columnSectionsCount {
                    let rowsCount = dataSource.numberOfRowsInSection(rowSectionIndex, ofTableView: self.collectionView!)
                    let columnsCount = dataSource.numberOfColumnsInSection(columnSectionIndex, ofTableView: self.collectionView!)
                    let sectionHasContent = columnsCount > 0 && rowsCount > 0
                    
                    if sectionHasContent {
                        for rowIndex in 0..<rowsCount {
                            for columnIndex in 0..<columnsCount {
                                let indexPath = SZIndexPath(rowSectionIndex: rowSectionIndex, columnSectionIndex: columnSectionIndex, rowIndex: rowIndex, columnIndex: columnIndex)
                                let cellAttributes = SZTableViewLayoutAttributes(forCellWithIndexPath: indexPath)
                                cellAttributes.frame = frameForCellAtIndexPath(indexPath)
                                cellsLayoutAttributes[indexPath] = cellAttributes
                            }
                        }
                    }
                }
            }
            
            // rows headers
            var rowSectionsHeadersLayoutAttributes = LayoutAttributes()
            var rowsHeadersLayoutAttributes = LayoutAttributes()
            for rowSectionIndex in 0..<rowSectionsCount {
                // sections header
                let indexPath = SZIndexPath(rowSectionIndex: rowSectionIndex, columnSectionIndex: 0, rowIndex: 0, columnIndex: 0)
                let headerAttributes = SZTableViewLayoutAttributes(forHeaderOfKind: SZReusableViewKind.RowsSectionHeader, atIndexPath: indexPath)
                headerAttributes.frame = frameForHeaderOfKind(SZReusableViewKind.RowsSectionHeader, atIndexPath: indexPath)
                rowSectionsHeadersLayoutAttributes[indexPath] = headerAttributes
                // rows headers
                let rowsCount = dataSource.numberOfRowsInSection(rowSectionIndex, ofTableView: self.collectionView!)
                if rowsCount > 0 {
                    for rowIndex in 0..<rowsCount {
                        let indexPath = SZIndexPath(rowSectionIndex: rowSectionIndex, columnSectionIndex: 0, rowIndex: rowIndex, columnIndex: 0)
                        let headerAttributes = SZTableViewLayoutAttributes(forHeaderOfKind: SZReusableViewKind.RowHeader, atIndexPath: indexPath)
                        headerAttributes.frame = frameForHeaderOfKind(SZReusableViewKind.RowHeader, atIndexPath: indexPath)
                        rowsHeadersLayoutAttributes[indexPath] = headerAttributes
                    }
                }
            }
            
            // columns headers
            var columnSectionsHeadersLayoutAttributes = LayoutAttributes()
            var columnsHeadersLayoutAttributes = LayoutAttributes()
            for columnSectionIndex in 0..<columnSectionsCount {
                // sections header
                let indexPath = SZIndexPath(rowSectionIndex: 0, columnSectionIndex: columnSectionIndex, rowIndex: 0, columnIndex: 0)
                let headerAttributes = SZTableViewLayoutAttributes(forHeaderOfKind: SZReusableViewKind.ColumnsSectionHeader, atIndexPath: indexPath)
                headerAttributes.frame = frameForHeaderOfKind(SZReusableViewKind.ColumnsSectionHeader, atIndexPath: indexPath)
                columnSectionsHeadersLayoutAttributes[indexPath] = headerAttributes
                
                // rows headers
                let columnsCount = dataSource.numberOfColumnsInSection(columnSectionIndex, ofTableView: self.collectionView!)
                if columnsCount > 0 {
                    for columnIndex in 0..<columnsCount {
                        let indexPath = SZIndexPath(rowSectionIndex: 0, columnSectionIndex: columnSectionIndex, rowIndex: 0, columnIndex: columnIndex)
                        let headerAttributes = SZTableViewLayoutAttributes(forHeaderOfKind: SZReusableViewKind.ColumnHeader, atIndexPath: indexPath)
                        headerAttributes.frame = frameForHeaderOfKind(SZReusableViewKind.ColumnHeader, atIndexPath: indexPath)
                        columnsHeadersLayoutAttributes[indexPath] = headerAttributes
                    }
                }
            }
            
            newLayoutInfo[SZReusableViewKind.Cell]                  = cellsLayoutAttributes
            newLayoutInfo[SZReusableViewKind.RowsSectionHeader]     = rowSectionsHeadersLayoutAttributes
            newLayoutInfo[SZReusableViewKind.ColumnsSectionHeader]  = columnSectionsHeadersLayoutAttributes
            newLayoutInfo[SZReusableViewKind.RowHeader]             = rowsHeadersLayoutAttributes
            newLayoutInfo[SZReusableViewKind.ColumnHeader]          = columnsHeadersLayoutAttributes
        }
        
        layoutInfo = newLayoutInfo
    }

    /*
    The 'collectionViewContentSize' method should return the overall size of the entire
    content area based on your initial calculations.
    */
    override func collectionViewContentSize() -> CGSize {
        return CGSize.zeroSize
    }
    
    /*
    Use the 'layoutAttributesForElementsInRect:' method to return the attributes for cells 
    and views that are in the specified rectangle.
    */
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        
        var allAttributes = [UICollectionViewLayoutAttributes]()
        for (reusableViewKind, layoutAttributes) in layoutInfo {
            for (_, attributes) in layoutAttributes {
                if CGRectIntersectsRect(rect, attributes.frame) {
                    allAttributes.append(attributes)
                }
            }
        }
        
        return allAttributes
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        var result: UICollectionViewLayoutAttributes? = nil
        if let layoutAttributes = layoutInfo[SZReusableViewKind.Cell] as LayoutAttributes? {
            result = layoutAttributes[szIndexPath(fromStandardIndexPath: indexPath)]
        }
        return result
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        var result: UICollectionViewLayoutAttributes? = nil
        if let layoutAttributes = layoutInfo[szReusableViewKind(fromStandardIndexPath: indexPath)] as LayoutAttributes? {
            result = layoutAttributes[szIndexPath(fromStandardIndexPath: indexPath)]
        }
        return result
    }
}

// MARK: - Private -
// MARK: Frames calculation

private extension SZTableViewLayout {
    
    func frameForCellAtIndexPath(indexPath: SZIndexPath) -> CGRect {
        // TODO: correct implementation needed
        return CGRect.zeroRect
    }
    
    func frameForHeaderOfKind(kind: SZReusableViewKind, atIndexPath indexPath: SZIndexPath) -> CGRect {
        // TODO: correct implementation needed
        return CGRect.zeroRect
    }
}

// MARK: Index paths conversions

private extension SZTableViewLayout {
    
    func szIndexPath(fromStandardIndexPath nsIndexPath: NSIndexPath) -> SZIndexPath {
        return SZIndexPath()
    }
    
    func nsIndexPath(fromInternalIndexPath szIndexPath: SZIndexPath) -> NSIndexPath {
        
        // columns
        var totalColumnsNumber: Int = 0
        let columnSectionsNumber = dataSource.numberOfColumnsSectionsInTableView(self.collectionView!)
        for columnSectionIndex in 0..<columnSectionsNumber {
            totalColumnsNumber += dataSource.numberOfColumnsInSection(columnSectionIndex, ofTableView: self.collectionView!)
        }
        
        var totalRowsNumber: Int = 0
        let rowSectionsNumber = dataSource.numberOfColumnsSectionsInTableView(self.collectionView!)
        for rowSectionIndex in 0..<rowSectionsNumber {
            totalRowsNumber += dataSource.numberOfRowsInSection(rowSectionIndex, ofTableView: self.collectionView!)
        }

        let totalCellsNumber = totalColumnsNumber * totalRowsNumber
        
        // TODO: continue here
        
        return NSIndexPath()
    }
    
    func szReusableViewKind(fromStandardIndexPath nsIndexPath: NSIndexPath) -> SZReusableViewKind {
        return SZReusableViewKind.Cell
    }
}

