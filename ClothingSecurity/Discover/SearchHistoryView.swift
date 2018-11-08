//
//  SearchHistoryView.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/3.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit

class SearchHistoryView: UIView {
    
    var onHideSearchView: (() -> Void)?
    var onClickKeyword: ((String) -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(10)
        }
        addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(17)
        }
        deleteButton.addTarget(self, action: #selector(deleteClick), for: .touchUpInside)
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(150)
        }
        reset()
    }
    
    func reset() {
        containerView.subviews.forEach { subView in
            subView.removeFromSuperview()
        }
        if let dataList = SearchHistory.history() {
            var gap: CGFloat = 0
            var width: CGFloat = 0
            dataList.forEach { keyword in
                let newItem = SingleSearchHistoryItem()
                newItem.keyword = keyword
                newItem.onClick = { keyword in
                    self.onClickKeyword?(keyword)
                }
                containerView.addSubview(newItem)
                newItem.snp.makeConstraints({ make in
                    let newItemWidth = self.widthOfKeyWord(keyword)
                    if width + 15 + newItemWidth > ScreenWidth {
                        gap += 43
                        width = 15
                    } else {
                        width += 15
                    }
                    make.left.equalToSuperview().offset(width)
                    make.top.equalToSuperview().offset(gap)
                    make.width.equalTo(newItemWidth)
                    make.height.equalTo(28)
                    width += newItemWidth
                })
            }
        }
    }
    
    private func widthOfKeyWord(_ keyword: String) -> CGFloat {
        if keyword.length <= 2 {
            return 58
        } else if keyword.length == 3 {
            return 70
        } else {
            return historyMaxWitdh
        }
    }
    
    @objc private func deleteClick() {
        onHideSearchView?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#000000")
        label.font = systemFontSize(fontSize: 14)
        label.text = "历史搜索记录"
        return label
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(imageNamed("ic_history_close"), for: .normal)
        button.hitTestEdgeInsets = UIEdgeInsets(top: -5, left: -10, bottom: -5, right: -5)
        return button
    }()
}

class SingleSearchHistoryItem: UIView {
    var onClick: ((String) -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickKeyword))
        container.addGestureRecognizer(tap)
    }
    
    @objc private func clickKeyword() {
        if let keyword = keyword {
            onClick?(keyword)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var keyword: String? {
        didSet {
            label.text = keyword
        }
    }
    
    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "#000000")
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 14)
        label.textColor = UIColor(hexString: "#ffef04")
        label.clipsToBounds = true
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .center
        return label
    }()
}

let saveHistoryKeyword = "scp.clothing.saveKeyword"
let historyMaxWitdh: CGFloat = 85.0

class SearchHistory: NSObject {
    
    static func save( _ keyword: String) {
        if let list = UserDefaults.standard.object(forKey: saveHistoryKeyword) as? [String] {
            var newList = list
            if let index = list.firstIndex(where: {$0 == keyword}) {
                newList.remove(at: index)
            }
            newList.insert(keyword, at: 0)
            UserDefaults.standard.set(newList, forKey: saveHistoryKeyword)
            if newList.count > 10 {
                newList.removeLast()
            }
        } else {
            UserDefaults.standard.set([keyword], forKey: saveHistoryKeyword)
        }
        UserDefaults.standard.synchronize()
    }
    
    static func history() -> [String]? {
        if let list = UserDefaults.standard.object(forKey: saveHistoryKeyword) as? [String] {
            return list
        }
        return nil
    }
    
    static func delete(_ keyword: String) {
        if let list = UserDefaults.standard.object(forKey: saveHistoryKeyword) as? [String] {
            var newList = list
            if let index = list.firstIndex(where: {$0 == keyword}) {
                newList.remove(at: index)
            }
            UserDefaults.standard.set(newList, forKey: saveHistoryKeyword)
            UserDefaults.standard.synchronize()
        }
    }
}
