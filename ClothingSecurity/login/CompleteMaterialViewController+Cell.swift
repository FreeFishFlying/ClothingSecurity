//
//  CompleteMaterialViewController+Cell.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/26.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Eureka

enum HumanSex: Int {
    case man = 1
    case woman = 0
}

class ChooseSexCell: Cell<String>, CellType {
    var onSexChoose: ((HumanSex?) -> Void)?
    override func setup() {
        super.setup()
        backgroundColor = .clear
        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(26)
        }
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(20)
            make.centerY.equalToSuperview()
        }
        addSubview(womanButton)
        womanButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
        }
        womanButton.addTarget(self, action: #selector(chooseSex(sender:)), for: .touchUpInside)
        addSubview(manButton)
        manButton.snp.makeConstraints { make in
            make.right.equalTo(womanButton.snp.left).offset(-50)
            make.centerY.equalToSuperview()
        }
        manButton.addTarget(self, action: #selector(chooseSex(sender:)), for: .touchUpInside)
        addSubview(line)
        line.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-0.5)
            make.height.equalTo(0.5)
        }
        layoutIfNeeded()
    }
    
    @objc private func chooseSex(sender: UIButton) {
        sex = HumanSex(rawValue: sender.tag)
        onSexChoose?(sex)
    }
    
    var sex: HumanSex? {
        didSet {
            if let sex = sex {
                if sex == .man {
                    womanButton.isSelected = false
                    manButton.isSelected = true
                } else {
                    womanButton.isSelected = true
                    manButton.isSelected = false
                }
            }
        }
    }
    
    var sexType: String? {
        if let sex = sex {
            if sex == .man {
                return "MALE"
            } else {
                return "FEMALE"
            }
        }
        return nil
    }
    
    private let icon: UIImageView = {
        let icon = UIImageView()
        icon.image = imageNamed("icon_sex")
        return icon
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = systemFontSize(fontSize: 15)
        label.textColor = UIColor.black
        label.text = "性别"
        return label
    }()
    
    private let manButton: UIButton = {
        let button = UIButton()
        button.tag = 1
        button.setImage(imageNamed("gender_select"), for: .selected)
        button.setImage(imageNamed("gender"), for: .normal)
        button.setTitle("男", for: .normal)
        button.setTitle("男", for: .selected)
        button.setTitleColor(UIColor(hexString: "#bfbfbf"), for: .normal)
        button.setTitleColor(UIColor.black, for: .selected)
        return button
    }()
    
    private let womanButton: UIButton = {
        let button = UIButton()
        button.tag = 0
        button.setImage(imageNamed("gender_select"), for: .selected)
        button.setImage(imageNamed("gender"), for: .normal)
        button.setTitle("女", for: .normal)
        button.setTitle("女", for: .selected)
        button.setTitleColor(UIColor(hexString: "#bfbfbf"), for: .normal)
        button.setTitleColor(UIColor.black, for: .selected)
        return button
    }()
    
    private let line: UIImageView = {
        let line = UIImageView()
        line.backgroundColor = UIColor(red: 229.0 / 255.0, green: 229.0 / 255.0, blue: 229.0 / 255.0, alpha: 1.0)
        return line
    }()
}

final class ChooseSexCellRow: Row<ChooseSexCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<ChooseSexCell>()
    }
}
