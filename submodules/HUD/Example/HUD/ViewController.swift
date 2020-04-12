//
//  ViewController.swift
//  HUD
//
//  Created by kingxt on 08/07/2017.
//  Copyright (c) 2017 kingxt. All rights reserved.
//

import UIKit
import HUD

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        HUD.show(.progress)
//        HUD.show(.tip(text: "hahah"), dimsBackground: false)
        HUD.show(.label("please retry later please retry later please retry later please retry later"))
//        HUD.tip(text: "哈哈哈哈哈哈哈", textColor: UIColor.white, backgroundColor: UIColor.red)
        
        let field = UITextField(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        field.backgroundColor = UIColor.red
        view.addSubview(field)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

