//
//  SZTableViewCell.swift
//  SZTableViewDemo
//
//  Created by Slava Zubrin on 1/14/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit

class SZTableViewCell: SZTableViewReusableView
{
    @IBOutlet weak var textLabel: UILabel!
    
    override init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setup()
    }
    
    override init()
    {
        super.init()
        setup()
    }
    
    private func setup()
    {
        kind = SZReusableViewKind.Cell
    }
}
