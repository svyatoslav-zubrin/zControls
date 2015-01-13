//
//  SZIndexPath.swift
//  SZTableViewDemo
//
//  Created by Slava Zubrin on 1/13/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit

class SZIndexPath: NSObject {
   
    private(set) var rawSectionIndex: Int = 0
    private(set) var columnSectionIndex: Int = 0
    private(set) var rawIndex: Int = 0
    private(set) var columnIndex: Int = 0
    
    convenience init(rawSectionIndex    _rawSectionIndex    : Int,
                     columnSectionIndex _columnSectionIndex : Int,
                     rawIndex           _rawIndex           : Int,
                     columnIndex        _columnIndex        : Int)
    {
        self.init()

        rawSectionIndex = _rawSectionIndex
        columnSectionIndex = _columnSectionIndex
        rawIndex = _rawIndex
        columnIndex = _columnIndex
    }
    
    func nsIndexPath() -> NSIndexPath {
        // TODO: correct implementation
        return NSIndexPath()
    }
}

extension NSIndexPath {
    func szIndexPath() -> SZIndexPath {
        // TODO: correct implementation needed
        return SZIndexPath()
    }
    
    func szReusableViewKind() -> SZReusableViewKind {
        // TODO: correct implementation needed
        return SZReusableViewKind.Cell
    }
}