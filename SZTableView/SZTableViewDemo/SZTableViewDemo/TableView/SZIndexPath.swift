//
//  SZIndexPath.swift
//  SZTableViewDemo
//
//  Created by Slava Zubrin on 1/13/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit

class SZIndexPath: NSObject {
   
    private(set) var rowSectionIndex: Int = 0
    private(set) var columnSectionIndex: Int = 0
    private(set) var rowIndex: Int = 0
    private(set) var columnIndex: Int = 0
    
    convenience init(rowSectionIndex    _rowSectionIndex    : Int,
                     columnSectionIndex _columnSectionIndex : Int,
                     rowIndex           _rowIndex           : Int,
                     columnIndex        _columnIndex        : Int)
    {
        self.init()

        rowSectionIndex = _rowSectionIndex
        columnSectionIndex = _columnSectionIndex
        rowIndex = _rowIndex
        columnIndex = _columnIndex
    }
}

// MARK: Index paths conversions

extension SZIndexPath {

    class func szIndexPath(fromStandardIndexPath nsIndexPath: NSIndexPath) -> SZIndexPath {
        return SZIndexPath()
    }

    class func nsIndexPath(fromInternalIndexPath szIndexPath: SZIndexPath) -> NSIndexPath {

//        // columns
//        var totalColumnsNumber: Int = 0
//        let columnSectionsNumber = dataSource.numberOfColumnsSectionsInTableView(self.collectionView!)
//        for columnSectionIndex in 0..<columnSectionsNumber {
//            totalColumnsNumber += dataSource.numberOfColumnsInSection(columnSectionIndex, ofTableView: self.collectionView!)
//        }
//
//        var totalRowsNumber: Int = 0
//        let rowSectionsNumber = dataSource.numberOfColumnsSectionsInTableView(self.collectionView!)
//        for rowSectionIndex in 0..<rowSectionsNumber {
//            totalRowsNumber += dataSource.numberOfRowsInSection(rowSectionIndex, ofTableView: self.collectionView!)
//        }
//
//        let totalCellsNumber = totalColumnsNumber * totalRowsNumber
//
//        // TODO: continue here

        return NSIndexPath()
    }

    class func szReusableViewKind(fromStandardIndexPath nsIndexPath: NSIndexPath) -> SZReusableViewKind {
        return SZReusableViewKind.Cell
    }
}

