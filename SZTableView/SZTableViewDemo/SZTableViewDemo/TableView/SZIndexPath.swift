//
//  SZIndexPath.swift
//  SZTableViewDemo
//
//  Created by Slava Zubrin on 1/13/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit

class SZIndexPath
    : NSObject
{
   
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
    
    func description() -> String
    {
        return "iPath(\(rowSectionIndex), \(columnSectionIndex), \(rowIndex), \(columnIndex))"
    }
}

// MARK: - Hashable

extension SZIndexPath: Hashable
{
    var hasValue: Int {
        let prime: Int = 31
        var result: Int = 1
        result = result * prime + rowSectionIndex.hashValue + columnSectionIndex.hashValue + rowIndex.hashValue + columnIndex.hashValue
        return result

//        return rowSectionIndex.hashValue ^
//               columnSectionIndex.hashValue ^
//               rowIndex.hashValue ^
//               columnIndex.hashValue
    }
}

// MARK: - Equatable

extension SZIndexPath: Equatable {}

func ==(lhs: SZIndexPath, rhs: SZIndexPath) -> Bool
{
    return lhs.rowSectionIndex    == rhs.rowSectionIndex
        && lhs.columnSectionIndex == rhs.columnSectionIndex
        && lhs.rowIndex           == rhs.rowIndex
        && lhs.columnIndex        == rhs.columnIndex
}

func !=(lhs: SZIndexPath, rhs: SZIndexPath) -> Bool
{
    return !(lhs == rhs)
}

