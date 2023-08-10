//
//  BaseCollectionView.swift
//  CompleteProject
//
//  Created by J Labs
//

import UIKit

class BaseCollectionView: UICollectionView {

    init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout, delegate:UICollectionViewDelegate?, dataSource:UICollectionViewDataSource?) {
        super.init(frame: frame, collectionViewLayout: layout)
        if let myDelegate = delegate {
            self.delegate = myDelegate
        }
        
        if let myDataSource = dataSource {
            self.dataSource = myDataSource
        }
        
        showsVerticalScrollIndicator = false
        showsVerticalScrollIndicator = false
        if #available(iOS 11, *) {
            contentInsetAdjustmentBehavior = .never
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
