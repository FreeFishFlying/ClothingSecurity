//
//  ActionSheetGridItemView.swift
//  Components-Swift
//
//  Created by Dylan on 17/05/2017.
//  Copyright © 2017 liao. All rights reserved.
//

import UIKit
import Core

public class ActionSheetGridItem {

    public var title: String?
    public var image: UIImage?
    public var imageUrl: String?
    public var handler: (() -> Void)?

    public init(title: String?, image: UIImage?, handler: (() -> Void)?) {
        self.title = title
        self.image = image
        self.handler = handler
    }

    public init(title: String?, imageUrl: String?, handler: (() -> Void)?) {
        self.title = title
        self.imageUrl = imageUrl
        self.handler = handler
    }
}

class ActionSheetGridCell: GridViewCell {

    private var image: UIImage?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColorRGB(0x585858)
        return label
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(titleLabel)
        contentView.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.centerX.top.equalToSuperview()
            make.width.height.equalTo(47)
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(7)
            make.width.lessThanOrEqualToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func fill(data: ActionSheetGridItem?) {
        image = data?.image
        titleLabel.text = data?.title
        imageView.image = image
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        imageView.image = image?.image(overlayColor: UIColor.black.withAlphaComponent(0.5))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        imageView.image = image
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        imageView.image = image
    }
}

public class ActionSheetGridItemView: ActionSheetItemView {

    private lazy var gridView: GridView = {
        let gridView = GridView()
        gridView.numberOfColums = 4
        gridView.numberOfRows = 2
        gridView.delegate = self
        gridView.dataSource = self
        gridView.sectionInset = UIEdgeInsets(top: 15, left: 10, bottom: 10, right: 10)
        gridView.register(ActionSheetGridCell.self, forCellWithReuseIdentifier: "ActionSheetGridCell")
        return gridView
    }()

    fileprivate lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = UIColorRGB(0xC0C0C0)
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()

    fileprivate var items: [ActionSheetGridItem]?

    public init(items: [ActionSheetGridItem]?) {
        super.init(frame: CGRect.zero)
        self.items = items
        initalizeSubviews()
        gridView.reloadData()
        let numberOfPages = gridView.numberOfPages
        pageControl.numberOfPages = gridView.numberOfPages
        pageControl.isHidden = numberOfPages <= 1
    }

    public func cellAt(indexPath: IndexPath) -> GridViewCell? {
        return gridView.collectionView.cellForItem(at: indexPath) as? GridViewCell
    }

    private func initalizeSubviews() {
        addSubview(gridView)
        addSubview(pageControl)

        gridView.snp.makeConstraints { make in
            make.right.left.top.equalToSuperview()
            make.height.equalTo(200)
        }
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
            make.bottom.equalTo(-5)
        }
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var preferredHeight: CGFloat {
        if let count = items?.count {
            if count <= 4 {
                return 100
            } else {
                return 200
            }
        }
        return 100
    }
}

extension ActionSheetGridItemView: GridViewDelegate, GridViewDataSource {

    public func numberOfCellsInGridView(gridView _: GridView) -> Int {
        return items?.count ?? 0
    }

    public func gridView(_ gridView: GridView, cellForIndex index: Int) -> GridViewCell {
        let cell = gridView.dequeueReusableCell(withReuseIdentifier: "ActionSheetGridCell", for: index) as! ActionSheetGridCell
        if let data = items?[index] {
            cell.fill(data: data)
        } else {
            cell.fill(data: nil)
        }
        return cell
    }

    public func gridView(_: GridView, didChangeTo index: Int) {
        pageControl.currentPage = index
    }

    public func gridView(_: GridView, didSelectedCell _: GridViewCell, atIndex index: Int) {
        if let data = items?[index] {
            if let handler = data.handler {
                handler()
            }
            actionSheetController?.dismiss(animated: true)
        }
    }
}
