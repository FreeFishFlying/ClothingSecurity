//
//  CompleteMaterialViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/26.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Core
import Eureka
import HUD
import PopoverImagePicker
class CompleteMaterialViewController: BaseLoginViewController {
    var imageUrl: String? {
        didSet {
            if let url = imageUrl {
                self.headerView.imageUrl = url
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerTitle = localizedString("perfectInformation")
        configTableView()
        configTableViewCell()
        configButton()
        headerView.onChooseLogo = { [weak self] in
            guard let `self` = self else { return }
            self.uploadImage()
        }
    }
    
    private func uploadImage() {
        AppAuthorizationUtil.checkPhoto({ () in
            PopoverImagePicker.choosePhoto(actionSheetActions: [], navigationControllerClass: ThemeNavigationController.self) { image -> Void in
                if let image = image {
                    if let data = image.asJPEGData(0.4) {
                        PersonCenterFacade.shared.onUploadImage(value: data, callBack: { [weak self] model in
                            guard let `self` = self else { return }
                            if let model = model {
                                self.imageUrl = model.url
                            }
                        })
                    }
                }
            }
        })
    }
    
    private func configTableView() {
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
            make.height.equalTo(244)
        }
    }
    
    private func configButton() {
        view.addSubview(sureButton)
        sureButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(48)
            make.right.equalToSuperview().offset(-48)
            make.height.equalTo(44)
            var value = 96
            if ScreenWidth == 320 {
                value = 40
            }
            make.top.equalTo(tableView.snp.bottom).offset(value)
        }
        sureButton.addTarget(self, action: #selector(complete), for: .touchUpInside)
    }
    
    @objc func complete() {
        if let value = configData() {
            var info = ["nickName": value.nickname, "gender": value.sexType, "password": value.pd]
            if let url = imageUrl {
                info["avatar"] = url
            }
            PersonCenterFacade.shared.updateUserInfo(value: info).startWithResult { [weak self] result in
                guard let `self` = self else { return }
                guard let value = result.value else { return }
                if value.isSuccess() {
                    LoginState.shared.hasLogin.value = true
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func configData() -> (nickname: String, sexType: String, pd: String)? {
        guard let nickRow: TextfieldInputCellRow = form.rowBy(tag: "nicknameCell") else { return nil }
        guard let sexRow: ChooseSexCellRow = form.rowBy(tag: "sexCell") else { return nil }
        guard let passwordRow: TextfieldInputCellRow = form.rowBy(tag: "secturyCell") else { return nil }
        guard let passwordAgainRow: TextfieldInputCellRow = form.rowBy(tag: "secturyAgainCell") else { return nil }
        if let nickName = nickRow.cell.textFieldText, let sexType = sexRow.cell.sexType, let pd = passwordRow.cell.textFieldText, let pdAgain = passwordAgainRow.cell.textFieldText {
            if pd == pdAgain {
                return (nickname: nickName, sexType: sexType, pd: pd)
            } else {
                HUD.flashError(title: localizedString("errorPD"))
                return nil
            }
        }
        if nickRow.cell.textFieldText == nil {
            HUD.flashError(title: localizedString("inputNickname"))
            return nil
        } else if passwordRow.cell.textFieldText == nil {
            HUD.flashError(title:localizedString(localizedString("inputPD")))
            return nil
        } else {
            HUD.flashError(title: localizedString("makeSurePD"))
            return nil
        }
    }
    
    private func configTableViewCell() {
        form +++ fixHeightHeaderSection(height: 0)
            <<< TextfieldInputCellRow { row in
                row.cell.imageName = "icon_nickname"
                row.cell.placeHolder = localizedString("inputNickname")
                row.tag = "nicknameCell"
                row.cell.height = { 56 }
                row.cell.sectury = false
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< ChooseSexCellRow { row in
                row.tag = "sexCell"
                row.cell.sex = HumanSex.man
                row.cell.onSexChoose = { _ in
                }
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< TextfieldInputCellRow { row in
                row.cell.imageName = "icon_sectury"
                row.cell.placeHolder = localizedString("inputPD")
                row.tag = "secturyCell"
                row.cell.height = { 56 }
                row.cell.sectury = true
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< TextfieldInputCellRow { row in
                row.cell.imageName = "icon_sectury"
                row.cell.placeHolder = localizedString("makeSurePD")
                row.tag = "secturyAgainCell"
                row.cell.height = { 56 }
                row.cell.sectury = true
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 20 }
        return 0.001
    }
    
    private let sureButton: DarkKeyButton = DarkKeyButton(title: localizedString("done"))
}
