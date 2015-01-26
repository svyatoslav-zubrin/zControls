//
//  SZTableViewReusableView.swift
//  SZTableViewDemo
//
//  Created by Slava Zubrin on 1/20/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit

class SZTableViewReusableView: UIView
{
    var kind: SZReusableViewKind = SZReusableViewKind.Undefined {
        didSet {
            switch kind {
            case .Cell:
                layer.zPosition = CGFloat(SZReusableViewsZOrder.Cell.rawValue)
            case .RowHeader, .ColumnHeader:
                layer.zPosition = CGFloat(SZReusableViewsZOrder.RowAndColumnHeader.rawValue)
            default:
                layer.zPosition = CGFloat(SZReusableViewsZOrder.Undefined.rawValue)
            }
        }
    }
    var reuseIdentifier: String? = nil
}
