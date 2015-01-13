//
//  SZTableViewLayoutAttributes.swift
//  SZTableViewDemo
//
//  Created by Slava Zubrin on 1/13/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit

class SZTableViewLayoutAttributes: UICollectionViewLayoutAttributes {
    
    private(set) var szKind: SZReusableViewKind
    
    init(forCellWithIndexPath _indexPath: SZIndexPath) {
        
        szKind = SZReusableViewKind.Cell

        super.init()
        
        indexPath = _indexPath.nsIndexPath()
    }
    
    init(forHeaderOfKind kind: SZReusableViewKind, atIndexPath _indexPath: SZIndexPath) {
        
        szKind = kind
        
        super.init()
        
        indexPath = _indexPath.nsIndexPath()
    }
}
