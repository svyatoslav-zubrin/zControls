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