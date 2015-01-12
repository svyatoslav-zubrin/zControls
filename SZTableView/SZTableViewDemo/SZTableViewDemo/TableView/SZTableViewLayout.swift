//
//  SZTableViewLayout.swift
//  SZTableViewDemo
//
//  Created by Slava Zubrin on 1/12/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit

protocol SZTableViewDataSource {
    
    func numberOfColumnsSectionsInTableView(_tableView: UICollectionView) -> Int;
    func numberOfRawsSectionsInTableView(_tableView: UICollectionView) -> Int;
    func numberOfColumnsInSection(_sectionIndex: Int, ofTableView tableView: UICollectionView) -> Int;
    func numberOfRowsInSection(_sectionIndex: Int, ofTableView tableView: UICollectionView) -> Int;
    
    func widthOfColumn(columnIndex: Int,
        inSection sectionIndex: Int,
        ofTableView tableView: UICollectionView) -> Float;
    func hightOfRaw(rawIndex: Int,
        inSection sectionIndex: Int,
        ofTableView tableView: UICollectionView) -> Float;

    func dequeCellForColumn(columnIndex: Int,
        andRaw rawIndex: Int,
        withReuseIdentifier reuseID: String,
        ofTableView tableView: UICollectionView) -> UICollectionViewCell;
    
    func dequeColumnsSectionHeader(sectionIndex: Int,
        withReuseIdentifier reuseID: String,
        ofTableView tableView: UICollectionView) -> UICollectionReusableView;
    func dequeRawsSectionHeader(sectionIndex: Int,
        withReuseIdentifier reuseID: String,
        ofTableView tableView: UICollectionView) -> UICollectionReusableView;
    func dequeColumnHeader(columnIndex: Int,
        withReuseIdentifier reuseID: String,
        ofTableView tableView: UICollectionView) -> UICollectionReusableView;
    func dequeRawHeader(rawIndex: Int,
        withReuseIdentifier reuseID: String,
        ofTableView tableView: UICollectionView) -> UICollectionReusableView;
}

protocol SZTableViewDelegate {
    
}

class SZTableViewLayout: UICollectionViewLayout {
    
}
