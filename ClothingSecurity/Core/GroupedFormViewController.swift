//
//  GroupedFormViewController.swift
//  ClothingSecurity
//
//  Created by 宋昌鹏 on 2018/10/25.
//  Copyright © 2018 scpUpCloud. All rights reserved.
//

import Foundation
import Core
import Eureka
import ReactiveSwift

public let ScreenWidth = UIScreen.main.bounds.width

public let ScreenHeight = UIScreen.main.bounds.height

class GroupedFormViewController: FormViewController {
    
    init(sectionBackgroundImage _: UIImage? = imageNamed("bg_app_list_hig")) {
        super.init(nibName: nil, bundle: nil)
    }
    
    internal var isGroupdStyle: Bool = {
        return false
    }()
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.clear
        if isGroupdStyle {
            tableView.separatorColor = tableView.backgroundColor
        }
        tableView.rowHeight = 46
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isGroupdStyle {
            configGroupedCell(tableView, willDisplay: cell, forRowAt: indexPath)
        }
    }
    
    func configGroupedCell(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        addBackgroundForSection(cell: cell, indexPath: indexPath)
    }
    
    func removeSelectionStyle() {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeSelectionStyle()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        removeSelectionStyle()
    }
    
    func addBackgroundForSection(cell: UITableViewCell, indexPath: IndexPath) {
        let inset: CGFloat = 10
        cell.separatorInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        let cornerRadius: CGFloat = 4.0
        cell.backgroundColor = UIColor.clear
        let layer = CAShapeLayer()
        let pathRef: CGMutablePath = CGMutablePath()
        let bounds: CGRect = cell.bounds.insetBy(dx: inset, dy: 0)
        var addLine = false
        if bounds.size.height < 2 * cornerRadius {
            return
        }
        if indexPath.row == 0 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            pathRef.addRoundedRect(in: bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: .identity)
        } else if indexPath.row == 0 {
            pathRef.move(to: CGPoint(x: bounds.minX, y: bounds.maxY), transform: .identity)
            pathRef.addArc(tangent1End: CGPoint(x: bounds.minX, y: bounds.minY), tangent2End: CGPoint(x: bounds.midX, y: bounds.minY), radius: cornerRadius, transform: .identity)
            pathRef.addArc(tangent1End: CGPoint(x: bounds.maxX, y: bounds.minY), tangent2End: CGPoint(x: bounds.maxX, y: bounds.midY), radius: cornerRadius, transform: .identity)
            pathRef.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY), transform: .identity)
            addLine = true
        } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            pathRef.move(to: CGPoint(x: bounds.minX, y: bounds.minY), transform: .identity)
            pathRef.addArc(tangent1End: CGPoint(x: bounds.minX, y: bounds.maxY), tangent2End: CGPoint(x: bounds.midX, y: bounds.maxY), radius: cornerRadius, transform: .identity)
            pathRef.addArc(tangent1End: CGPoint(x: bounds.maxX, y: bounds.maxY), tangent2End: CGPoint(x: bounds.maxX, y: bounds.midY), radius: cornerRadius, transform: .identity)
            pathRef.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY), transform: .identity)
            
        } else {
            pathRef.addRect(bounds, transform: .identity)
            addLine = true
        }
        layer.path = pathRef
        layer.fillColor = backgroundColor(section: indexPath.section)?.cgColor
        if addLine == true {
            let lineLayer = CALayer()
            let lineHeight: CGFloat = 0.5
            lineLayer.frame = CGRect(x: bounds.minX + inset, y: bounds.size.height - lineHeight, width: bounds.size.width - 2 * inset, height: lineHeight)
            lineLayer.backgroundColor = cellSeperatorLineColor(indexPath: indexPath).cgColor
            layer.addSublayer(lineLayer)
        }
        let bacgroundView = UIView(frame: bounds)
        bacgroundView.layer.insertSublayer(layer, at: 0)
        bacgroundView.backgroundColor = UIColor.clear
        cell.backgroundView = bacgroundView
        
        let selectedBackgroundView = UIView(frame: bounds)
        let selectedBackgroundLayer: CAShapeLayer = CAShapeLayer()
        selectedBackgroundLayer.path = pathRef
        selectedBackgroundLayer.fillColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        selectedBackgroundView.layer.insertSublayer(selectedBackgroundLayer, at: 0)
        cell.selectedBackgroundView = selectedBackgroundView
    }
    
    func cellSeperatorLineColor(indexPath _: IndexPath) -> UIColor {
        return UIColor.clear
    }
    
    func backgroundColor(section _: Int) -> UIColor? {
        return nil
    }
    
    func fixHeightHeaderSection(height: CGFloat) -> Section {
        return Section { section in
            section.header = {
                var header = HeaderFooterView<UIView>(.callback({
                    let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                    view.backgroundColor = .clear
                    return view
                }))
                header.height = { height }
                return header
            }()
        }
    }
    
    func fixHeightFooterSection() -> Section {
        return Section { section in
            section.footer = {
                var footer = HeaderFooterView<UIView>(.callback({
                    let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                    view.backgroundColor = .clear
                    return view
                }))
                if #available(iOS 11, *) {
                    footer.height = { 20 }
                } else {
                    footer.height = { 1 }
                }
                return footer
            }()
        }
    }
    
    func customHeaderSection(view: UIView) -> Section {
        return Section { section in
            section.header = HeaderFooterView<UIView>(.callback({
                view
            }))
        }
    }
    
    func customTitleHeaderSection(title: String) -> Section {
        return Section { section in
            section.header = {
                var header = HeaderFooterView<UIView>(.callback({
                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 35))
                    label.text = "  " + title
                    label.font = systemFontSize(fontSize: 14)
                    label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
                    return label
                }))
                header.height = { 35 }
                return header
            }()
        }
    }
}
