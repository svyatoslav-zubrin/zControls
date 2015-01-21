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
    
    let rowsNumber = 15
    let colsNumber = 25
    
    let columnWidth: Float = 100.0
    let columnHeaderHeight: Float = 20.0
    
    let rowHeight: Float = 70.0
    let rowHeaderWidth: Float = 50.0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "SimpleTableCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(cellNib, forViewWithReuseIdentifier: "SimpleCell")
        let headerNib = UINib(nibName: "SimpleTableReusableView", bundle: NSBundle.mainBundle())
        tableView.registerNib(headerNib, forViewWithReuseIdentifier: "SimpleReusableView")
        
        tableView.directionalLockEnabled = true
        let layout = SZTableViewGridLayout()
        layout.layoutDelegate = self
        layout.interColumnSpacing = 10
        layout.interRawSpacing = 10
        layout.tableView = self.tableView
        tableView.gridLayout = layout
        tableView.tableDataSource = self
        tableView.tableDelegate = self
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
    func numberOfRowsInTableView(tableView: SZTableView) -> Int
    {
        return rowsNumber
    }
    
    func numberOfColumnsInTableView(tableView: SZTableView) -> Int
    {
        return colsNumber
    }

    func tableView(tableView: SZTableView,
        cellForItemAtIndexPath indexPath: SZIndexPath) -> SZTableViewCell
    {
        let cell = tableView.dequeReusableViewOfKind(SZReusableViewKind.Cell,
                                                    withReuseIdentifier: "SimpleCell") as SZTableViewCell
        
        let red     = CGFloat(indexPath.columnIndex) / CGFloat(colsNumber)
        let green   = CGFloat(indexPath.rowIndex) / CGFloat(rowsNumber)
        let blue    = CGFloat(0.3)
        let bgColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        cell.backgroundColor = bgColor
        
        cell.textLabel.text = "\(indexPath.columnIndex + 1):\(indexPath.rowIndex + 1)"
        
        return cell
    }
    
    func tableView(tableView: SZTableView,
        headerForRowAtIndex rowIndex: Int) -> SZTableViewReusableView
    {
        let view = tableView.dequeReusableViewOfKind(SZReusableViewKind.RowHeader,
                                                    withReuseIdentifier: "SimpleReusableView")
        return view!
    }
    
    func tableView(tableView: SZTableView,
        headerForColumnAtIndex columnIndex: Int) -> SZTableViewReusableView
    {
        let view = tableView.dequeReusableViewOfKind(SZReusableViewKind.RowHeader,
                                                    withReuseIdentifier: "SimpleReusableView")
        return view!
    }
}

// MARK: - SZTableViewGridLayoutDelegate
    
extension ViewController
{
    func widthOfColumn(index: Int, ofTableView tableView: SZTableView) -> Float
    {
        return columnWidth
    }
    
    func heightOfRaw(index: Int, ofTableView tableView: SZTableView) -> Float
    {
        return rowHeight
    }
    
    func widthForRowHeadersOfTableView(tableView: SZTableView) -> Float
    {
        return rowHeaderWidth
    }
    
    func heightForColumnHeadersOfTableView(tableView: SZTableView) -> Float
    {
        return columnHeaderHeight
    }
}

