//
//  BaseTableView.swift
//  CompleteProject
//
//  Created by J Labs
//

import UIKit

class BaseTableView: UITableView {
    

    init(frame: CGRect, style: UITableView.Style, delegate:UITableViewDelegate?, dataSource:UITableViewDataSource?) {
        super.init(frame: frame, style: style)
        if style == .plain {
            self.tableFooterView = UIView.init();
        }
        if style == .grouped {
            if #available(iOS 11.0, *) {
                estimatedSectionHeaderHeight = 0;
                estimatedSectionFooterHeight = 0;
            }
        }
        if #available(iOS 15.0, *) {
            self.sectionHeaderTopPadding = 0
        }
        
        
        if let myDelegate = delegate {
            self.delegate = myDelegate
        }
        
        if let myDataSource = dataSource {
            self.dataSource = myDataSource
        }
        
        separatorStyle = .none
        
        showsHorizontalScrollIndicator = false;
        showsVerticalScrollIndicator = false;
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
