//
//  SZTableViewCommon.swift
//  SZTableViewDemo
//
//  Created by Slava Zubrin on 1/14/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation

enum SZReusableViewKind
{
    case Undefined
    case Cell
    case ColumnHeader
    case RowHeader
    case ColumnsSectionHeader
    case RowsSectionHeader
}

enum SZReusableViewsZOrder: Int
{
    case Undefined = 0
    case Cell = -1
    case RowAndColumnHeader = 50
}

typealias SZBorderIndexes = (column: (minIndex: Int, maxIndex: Int), row: (minIndex: Int, maxIndex: Int))
