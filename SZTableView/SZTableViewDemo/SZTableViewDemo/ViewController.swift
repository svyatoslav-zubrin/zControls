//
//  ViewController.swift
//  SZTableViewDemo
//
//  Created by Slava Zubrin on 1/12/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit
import Foundation

class ViewController
    : UIViewController
    , SZTableViewDataSource
    , SZTableViewDelegate
    , SZTableViewGridLayoutDelegate
{
    @IBOutlet weak var tableView: SZTableView!
    
    let rowsNumber = 13
    let colsNumber = 15
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "SimpleTableCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(cellNib, forCellWithReuseIdentifier: "SimpleCell")
        tableView.directionalLockEnabled = true
        let layout = SZTableViewGridLayout()
        layout.layoutDelegate = self
        layout.interColumnSpacing = 5
        layout.interRawSpacing = 10
        layout.tableView = self.tableView
        tableView.gridLayout = layout
        tableView.tableDataSource = self
        tableView.tableDelegate = self
        
        // debug:
//        tableView.layer.borderColor = UIColor.redColor().CGColor
//        tableView.layer.borderWidth = 2.0
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }

    // MARK: - User actions
    
    @IBAction func reloadAction(sender: UIButton)
    {
        tableView.reloadData()
    }
}

// MARK: - SZTableViewDataSource

extension ViewController
{
    func numberOfRowsInTableView(tableView: SZTableView) -> Int {
        return rowsNumber
    }
    
    func numberOfColumnsInTableView(tableView: SZTableView) -> Int {
        return colsNumber
    }

    func tableView(tableView: SZTableView, cellForItemAtIndexPath indexPath: SZIndexPath) -> SZTableViewCell {
        let cell = tableView.dequeReusableCellWithIdentifier("SimpleCell")
        
        let red     = CGFloat(indexPath.columnIndex) / CGFloat(colsNumber)
        let green   = CGFloat(indexPath.rowIndex) / CGFloat(rowsNumber)
        let blue    = CGFloat(0.3)
        let bgColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        cell?.backgroundColor = bgColor
        
        cell?.textLabel.text = "\(indexPath.columnIndex + 1):\(indexPath.rowIndex + 1)"
        
        return cell!
    }
}

// MARK: - SZTableViewGridLayoutDelegate
    
extension ViewController
{
    func widthOfColumn(index: Int, ofTableView tableView: SZTableView) -> Float {
        return 100.0
    }
    
    func heightOfRaw(index: Int, ofTableView tableView: SZTableView) -> Float {
        return 70.0
    }
}

