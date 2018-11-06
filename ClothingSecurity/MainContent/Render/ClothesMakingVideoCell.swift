//
//  ClothesMakingVideoCell.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/11/6.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit

class ClothesMakingVideoCell: UITableViewCell, UIScrollViewDelegate {
    var onPlayView: ((String) -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo((ScreenWidth - 30) / 16 * 9 + 39)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.bounces = false
        scroll.alwaysBounceVertical = false
        scroll.alwaysBounceHorizontal = false
        scroll.delegate = self
        return scroll
    }()
    
    func render(_ model: ClothesMakingVideoModel) {
        scrollView.subviews.forEach { sub in
            sub.removeFromSuperview()
        }
        var lastView: UIView? = nil
        model.videoModel.forEach { item in
            let subVideoView = VideoContentView()
            subVideoView.model = item
            scrollView.addSubview(subVideoView)
            subVideoView.snp.makeConstraints { make in
                make.top.equalToSuperview()
                if let view = lastView {
                    make.left.equalTo(view.snp.right).offset(6)
                } else {
                    make.left.equalToSuperview().offset(15)
                }
                make.width.equalTo(model.videoViewSize.width)
                make.height.equalTo(model.videoViewSize.height)
            }
            lastView = subVideoView
            subVideoView.onPlayVideo = { [weak self] url in
                guard let `self` = self else { return }
                self.onPlayView?(url)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}

class VideoContentView: UIView {
    var onPlayVideo: ((String) -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-39)
        }
        addSubview(playButton)
        playButton.snp.makeConstraints { make in
            make.center.equalTo(imageView.snp.center)
        }
        playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
        addSubview(desLabel)
        desLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalTo(snp.bottom).offset(-19)
            make.right.equalToSuperview()
        }
        addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalTo(imageView.snp.bottom).offset(-6)
        }
        addSubview(timeIcon)
        timeIcon.snp.makeConstraints { make in
            make.centerY.equalTo(timeLabel.snp.centerY).offset(-3)
            make.right.equalTo(timeLabel.snp.left).offset(-5.5)
        }
    }
    
    @objc private func play() {
        if let model = model {
            onPlayVideo?(model.playUrl)
        }
    }
    
    var model: VideoViewModel? {
        didSet {
            if let model = model {
                if let url = URL(string: model.coverUrl) {
                    imageView.kf.setImage(with: url, placeholder: imageNamed("perch_match_inside"))
                } else {
                    imageView.image = imageNamed("perch_match_inside")
                }
                timeLabel.text = model.playTime
                desLabel.text = model.name
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.setImage(imageNamed("ic_play"), for: .normal)
        return button
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 12)
        label.textColor = UIColor(hexString: "#ffffff")
        return label
    }()
    
    private let timeIcon: UIImageView = {
        let icon = UIImageView()
        icon.image = imageNamed("ic_strip")
        return icon
    }()
    
    private let desLabel: UILabel = {
        let lab = UILabel()
        lab.font = UIFont(name: "PingFangSC-Medium", size: 15.0)
        lab.textColor = UIColor(hexString: "#333333")
        return lab
    }()
}
