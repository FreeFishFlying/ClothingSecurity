//
//  ChangePasswordViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/31.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import UIKit
import Core
import Eureka
import HUD
class ChangePasswordViewController: GroupedFormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        title = localizedString("changePD")
        tableView.separatorStyle = .none
        tableView.snp.remakeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(210)
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< NormalSafeAccountCellRow { row in
                row.cell.title = localizedString("oldPD")
                row.tag = "oldCell"
                row.cell.placeHolder = localizedString("inputOldPD")
                row.cell.height =  { 67 }
                row.cell.textField.isSecureTextEntry = true
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< NormalSafeAccountCellRow { row in
                row.cell.title = localizedString("NewPD")
                row.tag = "newCell"
                row.cell.placeHolder = localizedString("inputNewPD")
                row.cell.height =  { 67 }
                row.cell.textField.isSecureTextEntry = true
        }
        form +++ fixHeightHeaderSection(height: 0)
            <<< NormalSafeAccountCellRow { row in
                row.cell.title = localizedString("makeSurePD")
                row.tag = "newAgainCell"
                row.cell.placeHolder = localizedString("inputAgain")
                row.cell.height =  { 67 }
                row.cell.textField.isSecureTextEntry = true
        }
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(48)
            make.right.equalToSuperview().offset(-48)
            make.height.equalTo(44)
            make.top.equalTo(tableView.snp.bottom).offset(40)
        }
        button.addTarget(self, action: #selector(changeMobile), for: .touchUpInside)
    }
    
    @objc func changeMobile() {
        guard let oldRow: NormalSafeAccountCellRow = form.rowBy(tag: "oldCell") as? NormalSafeAccountCellRow else { return }
        guard let newRow: NormalSafeAccountCellRow = form.rowBy(tag: "newCell") as? NormalSafeAccountCellRow else { return }
        guard let newAgainRow: NormalSafeAccountCellRow = form.rowBy(tag: "newAgainCell") as? NormalSafeAccountCellRow else { return }
        var oldPD: String = ""
        var newPD: String = ""
        var newAgainPD: String = ""
        if let old = oldRow.cell.content, !old.isEmpty {
            oldPD = old
        } else {
            HUD.flashError(title: localizedString("inputOldPD"))
            return
        }
        if let new = newRow.cell.content, !new.isEmpty {
            newPD = new
        } else {
            HUD.flashError(title: localizedString("inputNewPD"))
            return
        }
        if let newAgain = newAgainRow.cell.content, !newAgain.isEmpty {
            newAgainPD = newAgain
        } else {
            HUD.flashError(title: localizedString("makeSurePD"))
            return
        }
        if newPD != newAgainPD {
            HUD.flashError(title: localizedString("errorPD"))
            return
        }
        HUD.show(.progress)
        PersonCenterFacade.shared.changePassword(old: oldPD, new: newPD).startWithResult { [weak self] result in
            HUD.hide()
            guard let `self` = self else { return }
            guard let value = result.value else { return }
            if value.isSuccess() {
                self.navigationController?.popViewController(animated: true)
            } else {
                if let message = value.tipMesage() {
                    HUD.flashError(title: message)
                }
            }
        }
    }
    
    private let button: DarkKeyButton = DarkKeyButton(title: localizedString("sure"))
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}
