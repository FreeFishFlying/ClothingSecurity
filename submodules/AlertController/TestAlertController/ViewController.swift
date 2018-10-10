//
//  ViewController.swift
//  TestAlertController
//
//  Created by kingxt on 8/1/17.
//  Copyright © 2017 liao. All rights reserved.
//

import UIKit
import AlertController

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton()
        button.setTitle("Test", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.frame = CGRect(origin: CGPoint(x: 200, y: 200), size: CGSize(width: 200, height: 40))
        view.addSubview(button)
        button.addTarget(self, action: #selector(test), for: .touchUpInside)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func test() {
        let alert = AlertController(title: "kim test test", message: "kim test testkim test testkim test testkim test testkim test testim test testkim test testkim test testkim test testkim test testim test testkim test testkim test testkim test testkim test test", preferredStyle: .alert)
        alert.attributedTitle = NSAttributedString(string: "你好")
        let visualStyle = AlertVisualStyle(alertStyle: .alert)
        visualStyle.backgroundImage = UIImage(named: "test")?.stretchableImage(withLeftCapWidth: 20, topCapHeight: 20)
        visualStyle.backgroundColor = UIColor.clear
        visualStyle.actionViewSeparatorColor = UIColor.clear
        alert.visualStyle = visualStyle
        alert.add(title: "Confirm", style: .normal, handler: nil)
        alert.add(title: "Cancel", style: .preferred, handler: nil)
        present(alert, animated: true, completion: nil)
    }
}

