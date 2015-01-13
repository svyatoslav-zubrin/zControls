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
    case RawHeader
    case ColumnsSectionHeader
    case RawsSectionHeader
}

// MARK: - SZTableViewDataSource protocol

protocol SZTableViewDataSource {
    
    func numberOfColumnsSectionsInTableView(_tableView: UICollectionView) -> Int
    func numberOfRawsSectionsInTableView(tableView: UICollectionView) -> Int
    func numberOfColumnsInSection(_sectionIndex: Int, ofTableView tableView: UICollectionView) -> Int
    func numberOfRowsInSection(_sectionIndex: Int, ofTableView tableView: UICollectionView) -> Int
    
    // geometry
    func widthOfColumn(atIndexPath indexPath: SZIndexPath, ofTableView tableView: UICollectionView) -> Float
    func hightOfRaw(atIndexPath indexPath: SZIndexPath, ofTableView tableView: UICollectionView) -> Float

    // view for cells
    func dequeCell(atIndexPath indexPath: SZIndexPath, withReuseIdentifier reuseID: String, forTableView tableView: UICollectionView) -> UICollectionViewCell
    
    // views for headers of different kind
    func dequeHeaderForIndexPath(indexPath: SZIndexPath, ofHeaderKind headerKind: SZReusableViewKind, withReuseIdentifier reuseID: String, forTableView tableView: UICollectionView) -> UICollectionReusableView
}

// MARK: - SZTableViewDelegate protocol

protocol SZTableViewDelegate {
    
    func tableView(_tableView: UICollectionView, didSelectCellAtIndexPath   indexPath: NSIndexPath)
    func tableView(_tableView: UICollectionView, didSelectHeaderAtIndexPath indexPath: NSIndexPath)
}

// MARK: - SZTableViewLayout

class SZTableViewLayout: UICollectionViewLayout {
    
    // MARK: - Global TODOs:
    // MARK: ...implement correct attributes calculation
    // MARK: ...implement NSIndexPath<->SZIndexPath conversion logic
    // MARK: ...implement NSIndexPath->SZReusableViewKind conversion logic
    // MARK: ...implement cache for global paramenters and layout attributes
    // MARK: ...implement expandable raws and columns
    // MARK: ...implement sorting of all the table with tap on the column/raw/section header
    // MARK: ...implement possibility to fix the posiiton of column/raw/section
    // MARK: ...implement filtering of the table over column/raw/section content
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
        
        let rawSectionsCount = dataSource.numberOfRawsSectionsInTableView(self.collectionView!)
        let columnSectionsCount = dataSource.numberOfColumnsSectionsInTableView(self.collectionView!)
        let tableHasContent = columnSectionsCount > 0 && rawSectionsCount > 0

        if tableHasContent {
            var cellsLayoutAttributes = LayoutAttributes()
            // cells
            for rawSectionIndex in 0..<rawSectionsCount {
                for columnSectionIndex in 0..<columnSectionsCount {
                    let rawsCount = dataSource.numberOfRowsInSection(rawSectionIndex, ofTableView: self.collectionView!)
                    let columnsCount = dataSource.numberOfColumnsInSection(columnSectionIndex, ofTableView: self.collectionView!)
                    let sectionHasContent = columnsCount > 0 && rawsCount > 0
                    
                    if sectionHasContent {
                        for rawIndex in 0..<rawsCount {
                            for columnIndex in 0..<columnsCount {
                                let indexPath = SZIndexPath(rawSectionIndex: rawSectionIndex, columnSectionIndex: columnSectionIndex, rawIndex: rawIndex, columnIndex: columnIndex)
                                let cellAttributes = SZTableViewLayoutAttributes(forCellWithIndexPath: indexPath)
                                cellAttributes.frame = frameForCellAtIndexPath(indexPath)
                                cellsLayoutAttributes[indexPath] = cellAttributes
                            }
                        }
                    }
                }
            }
            
            // raws headers
            var rawSectionsHeadersLayoutAttributes = LayoutAttributes()
            var rawsHeadersLayoutAttributes = LayoutAttributes()
            for rawSectionIndex in 0..<rawSectionsCount {
                // sections header
                let indexPath = SZIndexPath(rawSectionIndex: rawSectionIndex, columnSectionIndex: 0, rawIndex: 0, columnIndex: 0)
                let headerAttributes = SZTableViewLayoutAttributes(forHeaderOfKind: SZReusableViewKind.RawsSectionHeader, atIndexPath: indexPath)
                headerAttributes.frame = frameForHeaderOfKind(SZReusableViewKind.RawsSectionHeader, atIndexPath: indexPath)
                rawSectionsHeadersLayoutAttributes[indexPath] = headerAttributes
                // rows headers
                let rawsCount = dataSource.numberOfRowsInSection(rawSectionIndex, ofTableView: self.collectionView!)
                if rawsCount > 0 {
                    for rawIndex in 0..<rawsCount {
                        let indexPath = SZIndexPath(rawSectionIndex: rawSectionIndex, columnSectionIndex: 0, rawIndex: rawIndex, columnIndex: 0)
                        let headerAttributes = SZTableViewLayoutAttributes(forHeaderOfKind: SZReusableViewKind.RawHeader, atIndexPath: indexPath)
                        headerAttributes.frame = frameForHeaderOfKind(SZReusableViewKind.RawHeader, atIndexPath: indexPath)
                        rawsHeadersLayoutAttributes[indexPath] = headerAttributes
                    }
                }
            }
            
            // columns headers
            var columnSectionsHeadersLayoutAttributes = LayoutAttributes()
            var columnsHeadersLayoutAttributes = LayoutAttributes()
            for columnSectionIndex in 0..<columnSectionsCount {
                // sections header
                let indexPath = SZIndexPath(rawSectionIndex: 0, columnSectionIndex: columnSectionIndex, rawIndex: 0, columnIndex: 0)
                let headerAttributes = SZTableViewLayoutAttributes(forHeaderOfKind: SZReusableViewKind.ColumnsSectionHeader, atIndexPath: indexPath)
                headerAttributes.frame = frameForHeaderOfKind(SZReusableViewKind.ColumnsSectionHeader, atIndexPath: indexPath)
                columnSectionsHeadersLayoutAttributes[indexPath] = headerAttributes
                
                // rows headers
                let columnsCount = dataSource.numberOfColumnsInSection(columnSectionIndex, ofTableView: self.collectionView!)
                if columnsCount > 0 {
                    for columnIndex in 0..<columnsCount {
                        let indexPath = SZIndexPath(rawSectionIndex: 0, columnSectionIndex: columnSectionIndex, rawIndex: 0, columnIndex: columnIndex)
                        let headerAttributes = SZTableViewLayoutAttributes(forHeaderOfKind: SZReusableViewKind.ColumnHeader, atIndexPath: indexPath)
                        headerAttributes.frame = frameForHeaderOfKind(SZReusableViewKind.ColumnHeader, atIndexPath: indexPath)
                        columnsHeadersLayoutAttributes[indexPath] = headerAttributes
                    }
                }
            }
            
            newLayoutInfo[SZReusableViewKind.Cell]                  = cellsLayoutAttributes
            newLayoutInfo[SZReusableViewKind.RawsSectionHeader]     = rawSectionsHeadersLayoutAttributes
            newLayoutInfo[SZReusableViewKind.ColumnsSectionHeader]  = columnSectionsHeadersLayoutAttributes
            newLayoutInfo[SZReusableViewKind.RawHeader]             = rawsHeadersLayoutAttributes
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
            result = layoutAttributes[indexPath.szIndexPath()]
        }
        return result
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        var result: UICollectionViewLayoutAttributes? = nil
        if let layoutAttributes = layoutInfo[indexPath.szReusableViewKind()] as LayoutAttributes? {
            result = layoutAttributes[indexPath.szIndexPath()]
        }
        return result
    }
}

// MARK: - Private

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
