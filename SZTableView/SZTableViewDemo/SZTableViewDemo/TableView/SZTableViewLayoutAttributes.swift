//
//  SZTableViewLayoutAttributes.swift
//  SZTableViewDemo
//
//  Created by Slava Zubrin on 1/13/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit

class SZTableViewLayoutAttributes: NSObject {
    
    private(set) var kind: SZReusableViewKind
    private(set) var indexPath: SZIndexPath
    
    var frame: CGRect = CGRect.zeroRect
    
    init(forCellWithIndexPath _indexPath: SZIndexPath) {
        kind = SZReusableViewKind.Cell
        indexPath = _indexPath
        super.init()
    }
    
    init(forReusableViewOfKind _kind: SZReusableViewKind, atIndexPath _indexPath: SZIndexPath) {
        kind = _kind
        indexPath = _indexPath
        super.init()
    }
}
