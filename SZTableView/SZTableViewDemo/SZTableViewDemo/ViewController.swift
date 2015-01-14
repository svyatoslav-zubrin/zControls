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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let cellNib = UINib(nibName: "SimpleTableCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(cellNib, forCellWithReuseIdentifier: "SimpleCell")
        let layout = SZTableViewGridLayout()
        layout.layoutDelegate = self
        layout.tableView = self.tableView
        tableView.gridLayout = layout
        tableView.tableDataSource = self
        tableView.tableDelegate = self
        
        // debug:
        tableView.layer.borderColor = UIColor.redColor().CGColor
        tableView.layer.borderWidth = 2.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - SZTableViewDataSource

    func numberOfRowsInTableView(tableView: SZTableView) -> Int {
        return 3
    }
    
    func numberOfColumnsInTableView(tableView: SZTableView) -> Int {
        return 15
    }

    func tableView(tableView: SZTableView, cellForItemAtIndexPath indexPath: SZIndexPath) -> SZTableViewCell {
        let cell = tableView.dequeReusableCellWithIdentifier("SimpleCell")
        cell!.layer.borderColor = UIColor.blueColor().CGColor
        cell!.layer.borderWidth = 3.0
        return cell!
    }
    // MARK: - SZTableViewGridLayoutDelegate
    
    func widthOfColumn(index: Int, ofTableView tableView: SZTableView) -> Float {
        return 50.0
    }
    
    func heightOfRaw(index: Int, ofTableView tableView: SZTableView) -> Float {
        return 100.0
    }
    
    // MARK: - User actions
    
    @IBAction func reloadAction(sender: UIButton)
    {
        tableView.reloadData()
    }
}

