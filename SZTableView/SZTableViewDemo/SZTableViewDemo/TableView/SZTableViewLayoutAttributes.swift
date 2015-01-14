//
//  SZTableViewLayoutAttributes.swift
//  SZTableViewDemo
//
//  Created by Slava Zubrin on 1/13/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit

class SZTableViewLayoutAttributes: NSObject {
    
    private(set) var szKind: SZReusableViewKind
    private(set) var szIndexPath: SZIndexPath
    
    var frame: CGRect = CGRect.zeroRect
    
    init(forCellWithIndexPath _indexPath: SZIndexPath) {
        szKind = SZReusableViewKind.Cell
        szIndexPath = _indexPath
        super.init()
    }
    
    init(forHeaderOfKind kind: SZReusableViewKind, atIndexPath _indexPath: SZIndexPath) {
        szKind = kind
        szIndexPath = _indexPath
        super.init()
    }
}
