//
//  ViewController.swift
//  Core
//
//  Created by kingxt on 08/07/2017.
//  Copyright (c) 2017 kingxt. All rights reserved.
//

import UIKit
import Core
import SnapKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let request = UIButton()
        request.setTitle("Outgoing", for: .normal)
        request.addTarget(self, action: #selector(requestDidClick), for: .touchUpInside)
        request.backgroundColor = UIColor.green
        view.addSubview(request)
        
        let response = UIButton()
        response.setTitle("Incoming", for: .normal)
        response.addTarget(self, action: #selector(responseDidClick), for: .touchUpInside)
        response.backgroundColor = UIColor.blue
        view.addSubview(response)
        
        request.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(100)
        }
        response.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(request.snp.bottom).offset(50)
        }
        
        print("aabb".substring(with: NSRange(location: 0, length: 2)))
    }
    
    @objc private func requestDidClick(sender: UIButton) {
        showOutgoing()
    }
    
    @objc private func responseDidClick(sender: UIButton) {
        showIncoming()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: Call kit test
extension ViewController {
    
    func showIncoming() {
        Haptic.impact(.medium).generate()
        if #available(iOS 10.0, *) {
            let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                print("begin background task for show incoming")
//                _ = CallKitManager.shared.reportIncomingCall(contact: CallContact(name: "dylan", phoneNumber: "131672073831") ) { err in
//                    print("show Incoming call back")
//                    if let err = err {
//                        print(err)
//                    }
//                    UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
//                }
            })
        }
    }
    
    func showOutgoing() {
        if #available(iOS 10.0, *) {
//            _ = CallKitManager.shared.reportOutgoingCall(contact: CallContact(name: "dylan Incoming", phoneNumber: "13167207831")) { err in
//                print("show outgoing call back")
//                if let err = err {
//                    print(err)
//                }
//            }
        }
    }
}
