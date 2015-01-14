//
//  SZTableView.swift
//  SZTableViewDemo
//
//  Created by Slava Zubrin on 1/14/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit


class SZTableView
    : UIScrollView
    , UIScrollViewDelegate
{
    @IBOutlet weak var tableDataSource: SZTableViewDataSource!
    @IBOutlet weak var tableDelegate: SZTableViewDelegate!
    
    var cellsReusePool = [String: SZTableViewCell]()
    
    var registeredCellNibs    = [String: UINib]()
    var registeredCellClasses = [String: AnyClass]()
    
    var gridLayout: SZTableViewGridLayout!
    
    // MARK: - Lifecycle
    
    required init(coder aDecoder: NSCoder)
    {
//        self.gridLayout = SZTableViewGridLayout()
        
        super.init(coder: aDecoder)
    }
    
    // MARK: - Public
    
    func dequeReusableCellWithIdentifier(reuseIdentifier: String) -> SZTableViewCell?
    {
        if let cell = cellsReusePool[reuseIdentifier] {
            cellsReusePool[reuseIdentifier] = nil
            return cell
        }
        else {
            // TODO: instantiate new cell and return it
            // return type after that must be changed to non-optional ))
            if let cellNib = registeredCellNibs[reuseIdentifier] {
                return loadCellFromNib(cellNib)
            }
            else if let cellClass: AnyClass = registeredCellClasses[reuseIdentifier] {
                return loadCellFromClass(cellClass)
            }
            
            return nil
        }
    }
    
    private func registerClass(cellClass: AnyClass, forCellWithReuseIdentifier cellReuseIdentifier: String)
    {
        registeredCellClasses[cellReuseIdentifier] = cellClass
        registeredCellNibs[cellReuseIdentifier] = nil
    }
    
    func registerNib(cellNib: UINib, forCellWithReuseIdentifier cellReuseIdentifier: String)
    {
        registeredCellNibs[cellReuseIdentifier] = cellNib
        registeredCellClasses[cellReuseIdentifier] = nil
    }
    
    func reloadData()
    {
        // renew data

        // remove all subviews (place to reuse pool if needed)
        for view in subviews {
            if view is SZTableViewCell {
                view.removeFromSuperview()
            }
        }
        
        gridLayout.prepareLayout()
        
        // add all needed cells again
        for rowIndex in 0..<tableDataSource.numberOfRowsInTableView(self) {
            for columnIndex in 0..<tableDataSource.numberOfColumnsInTableView(self) {
                let indexPath = SZIndexPath(rowSectionIndex: 0, columnSectionIndex: 0, rowIndex: rowIndex, columnIndex: columnIndex)
                let cell = tableDataSource.tableView(self, cellForItemAtIndexPath: indexPath)
                cell.frame = gridLayout.frameForCellAtIndexPath(indexPath)
                self.addSubview(cell)
                println(cell)
            }
        }
        
        setNeedsDisplay()
    }

    // MARK: - Private

    private func loadCellFromNib(nib: UINib) -> SZTableViewCell?
    {
        return nib.instantiateWithOwner(nil, options: nil).first as? SZTableViewCell
    }
    
    private func loadCellFromClass(cellClass: AnyClass) -> SZTableViewCell?
    {
//        if cellClass.self is SZTableViewCell.Type {
//            if let cell = cellClass() {
//                return cell
//            }
//        }
        return nil
    }
}
