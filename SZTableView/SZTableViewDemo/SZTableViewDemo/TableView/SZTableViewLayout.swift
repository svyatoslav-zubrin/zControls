//
//  SZTableViewLayout.swift
//  SZTableViewDemo
//
//  Created by Slava Zubrin on 1/12/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit

enum SZTableViewHeaderKind {
    case Column
    case Raw
    case ColumnsSection
    case RawsSection
}

protocol SZTableViewDataSource {
    
    func numberOfColumnsSectionsInTableView(_tableView: UICollectionView) -> Int;
    func numberOfRawsSectionsInTableView(_tableView: UICollectionView) -> Int;
    func numberOfColumnsInSection(_sectionIndex: Int,
        ofTableView tableView: UICollectionView) -> Int;
    func numberOfRowsInSection(_sectionIndex: Int,
        ofTableView tableView: UICollectionView) -> Int;
    
    // geometry
    func widthOfColumn(columnIndex: Int,
        inSection sectionIndex: Int,
        ofTableView tableView: UICollectionView) -> Float;
    func hightOfRaw(rawIndex: Int,
        inSection sectionIndex: Int,
        ofTableView tableView: UICollectionView) -> Float;

    // view for cells
    func dequeCellForColumn(columnIndex: Int,
        andRaw rawIndex: Int,
        withReuseIdentifier reuseID: String,
        ofTableView tableView: UICollectionView) -> UICollectionViewCell;
    
    // views for headers of different kind
    func dequeHeaderForIndexPath(_indexPath: NSIndexPath,
        ofHeaderKind headerKind: SZTableViewHeaderKind,
        withReuseIdentifier reuseID: String,
        forTableView tableView: UICollectionView) -> UICollectionReusableView;
}

protocol SZTableViewDelegate {
    
}

class SZTableViewLayout: UICollectionViewLayout {
    
}
