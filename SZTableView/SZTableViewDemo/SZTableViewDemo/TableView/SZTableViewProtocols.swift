//
//  SZTableViewProtocols.swift
//  SZTableViewDemo
//
//  Created by Slava Zubrin on 1/14/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit


@objc protocol SZTableViewDataSource
{
    func numberOfRowsInTableView(tableView: SZTableView) -> Int
    func numberOfColumnsInTableView(tableView: SZTableView) -> Int
    func tableView(tableView: SZTableView, cellForItemAtIndexPath indexPath: SZIndexPath) -> SZTableViewCell
    
    optional func tableView(tableView: SZTableView, headerForColumnAtIndex columnIndex: Int) -> SZTableViewReusableView
    optional func tableView(tableView: SZTableView, headerForRowAtIndex rowIndex: Int) -> SZTableViewReusableView
}


@objc protocol SZTableViewDelegate
{
    optional func tableView(tableView: SZTableView, didSelectCellAtIndexPath indexPath: SZIndexPath)
}


@objc protocol SZTableViewGridLayoutDelegate
{
    func heightOfRaw(index: Int, ofTableView tableView: SZTableView) -> Float
    func widthOfColumn(index: Int, ofTableView tableView: SZTableView) -> Float
    
    optional func widthForRowHeadersOfTableView(tableView: SZTableView) -> Float
    optional func heightForColumnHeadersOfTableView(tableView: SZTableView) -> Float
}
