//
//  ViewController.swift
//  MestTest
//
//  Created by kingxt on 6/16/17.
//  Copyright © 2017 liao. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import Mesh
import enum Result.Result

struct RequestIntervalModifier: RequestModifier {
    func modified(for request: URLRequest, tryStep: Int) -> (URLRequest, TimeInterval)? {
        if tryStep == 1 {
            return (URLRequest(url: URL(string: "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1497619793067&di=bc13e78d27d3ede8f86f9603dce6052b&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2F0b46f21fbe096b63eb14747c06338744ebf8ac88.jpg")!), 0)
        }
        return (request, 0)
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        test1()
//        test2()
//        testGif()
//        print(URL(string: "http://www.chaoxin.com/aa/a.png")!.deletingPathExtension().appendingPathExtension("gif"))
    }
    
    func test1() {
        Mesh.meshDownloadModify = RequestIntervalModifier()
        Mesh.meshRetryTimes = 2
        // Do any additional setup after loading the view, typically from a nib.
        
        let imageView = UIImageView(frame: CGRect(x: 100, y: 100, width: 300, height: 300))
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        
        imageView.kf.setImage(with: URL(string: "https://r.chaoxin.com/a81259c/2017-12-13_11/62e39/509e7/1513134069_224539_640_640.jpg"))
        
        let url = URL(string: "https://r.chaoxin.com/d29889e/2016-08-05_11/940e6/26e10/1470369012_380646_169_300.mp4")!
        
        FileDownloader.default.watch(url: url).startWithResult { (result: Result<(url: URL, percent: Double?, destination: URL?, completed: Bool), NSError>) in
            print(result.value?.percent ?? -1)
        }
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("temp.mp4")
        FileDownloader.default.download(with: url, destination: fileURL) { (_, _, _) in
            print("result")
        }
    }
    
    let queue = OperationQueue()
    
    func test2() {
        queue.maxConcurrentOperationCount = 1
        let q1 = WaitingOperation()
        q1.completionBlock = { (Void) in
            print("q1 completion")
        }
        let q2 = WaitingOperation()
        q2.completionBlock = { (Void) in
            print("q2 completion")
        }
        let q3 = WaitingOperation()
        q3.completionBlock = { (Void) in
            print("q3 completion \(q3.isCancelled)")
        }
        let q4 = WaitingOperation()
        q4.completionBlock = { (Void) in
            print("q4 completion")
        }
        queue.addOperation(q1)
        queue.addOperation(q2)
        queue.addOperation(q3)
        queue.addOperation(q4)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            q1.isWaiting = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            q2.isWaiting = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            q3.isWaiting = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            q4.isWaiting = false
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
//            q3.cancel()
//        }
    }
    
    func testGif() {
        let imageView = AcceleratedAnimationImageView(frame: CGRect(x: 100, y: 100, width: 200, height: 200))
        let url = URL(string: "https://raw.githubusercontent.com/liyong03/YLGIFImage/master/YLGIFImageDemo/YLGIFImageDemo/joy.gif")!
        imageView.setGifImage(with: url)
        view.addSubview(imageView)
        
        let when = DispatchTime.now() + 5
        DispatchQueue.main.asyncAfter(deadline: when) { 
            imageView.prepareForRecycle()
        }
    }
}

