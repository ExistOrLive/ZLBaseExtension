//
//  UITableView+ZLBase.swift
//  ZLGitHubClient
//
//  Created by 朱猛 on 2022/1/17.
//  Copyright © 2022 ZM. All rights reserved.
//

import Foundation
import UIKit

public extension UITableView {
    
    func initCommonTableView() {
        
        separatorStyle = .none
        backgroundColor = UIColor.clear
        
        estimatedRowHeight = 44
        rowHeight = UITableView.automaticDimension
        
        estimatedSectionFooterHeight = 20
        sectionFooterHeight = UITableView.automaticDimension
        
        estimatedSectionHeaderHeight = 20
        sectionHeaderHeight = UITableView.automaticDimension
        
        translatesAutoresizingMaskIntoConstraints = false
     
        if #available(iOS 15.0, *) {
            sectionHeaderTopPadding = 0
        }
    }
    
   
    // UITableViewCell
    func register<T: UITableViewCell>(_ cellType: T.Type) {
        register(cellType, forCellReuseIdentifier: NSStringFromClass(cellType))
    }

    func dequeueReusableCell<T: UITableViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T {
        guard let cell =  dequeueReusableCell(withIdentifier: NSStringFromClass(cellType), for: indexPath) as? T else {
            return T()
        }
        return cell
    }

    func dequeueReusableCell<T: UITableViewCell>(_ cellType: T.Type) -> UITableViewCell? {
        guard let cell =  dequeueReusableCell(withIdentifier: NSStringFromClass(cellType)) as? T else {
            return T(style: .default, reuseIdentifier: NSStringFromClass(cellType))
        }
        return cell
    }
    
    // UITableViewHeaderFooterView
    func registerHeaderFooterView<T: UITableViewHeaderFooterView>(_ viewType: T.Type) {
        register(viewType, forHeaderFooterViewReuseIdentifier: NSStringFromClass(viewType))
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ viewType: T.Type) -> T{
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(viewType)) as? T else {
            return T(reuseIdentifier: NSStringFromClass(viewType))
        }
        return view
    }
}


public extension UITableView {
    
    
    @objc dynamic func zl_reloadAndScrollToTop() {
        UIView.performWithoutAnimation {
            self.reloadData()
        }
        self.layoutIfNeeded()
        self.zl_scrollToTop(animated: false)
    }
    
    @objc dynamic func zl_scrollToTop(_ position: ScrollPosition = .top, animated: Bool = true) {
        let sections = self.numberOfSections
        // sections 数量为0 时，直接设置contentOffset
        if sections < 1 {
            self.setContentOffset(.zero, animated: animated)
        } else {
            // sections 数量不为0时，找第一个rows数量不为0的section
            var firstVisibleSection = -1
            for s in 0..<sections {
                let rows = self.numberOfRows(inSection: s)
                if rows > 0 {
                    firstVisibleSection = s
                    break
                }
            }
            // 如果没找到rows数量不为0的section, 直接设置contentOffset，否则使用srollToRow
            if firstVisibleSection < 0 {
                self.setContentOffset(.zero, animated: animated)
            } else {
                self.scrollToRow(at: IndexPath(row: 0, section: firstVisibleSection), at: position, animated: animated)
            }
        }
    }
}
