//
//  ViewController.swift
//  Broadcast
//
//  Created by Migu on 2016/10/25.
//  Copyright © 2016年 VictorChee. All rights reserved.
//

import UIKit
import ReplayKit

class ViewController: UIViewController {
    
    var broadcastController: RPBroadcastController?

    @IBOutlet weak var pauseBarButton: UIBarButtonItem!
    @IBOutlet weak var resumeBarButton: UIBarButtonItem!
    @IBOutlet weak var finishBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func broadcast(_ sender: UIBarButtonItem) {
        RPBroadcastActivityViewController.load { broadcastActivityViewController, error in
            if let broadcastActivityViewController = broadcastActivityViewController {
                broadcastActivityViewController.delegate = self
                self.present(broadcastActivityViewController, animated: true)
            }
        }
    }
    
    @IBAction func pauseBroadcast(_ sender: UIBarButtonItem) {
        broadcastController?.pauseBroadcast()
        
        sender.isEnabled = false
        self.resumeBarButton.isEnabled = true
        self.finishBarButton.isEnabled = true
    }
    
    @IBAction func resumeBroadcast(_ sender: UIBarButtonItem) {
        if let broadcast = broadcastController , broadcast.isPaused {
            broadcast.resumeBroadcast()
            
            self.pauseBarButton.isEnabled = true
            sender.isEnabled = false
            self.finishBarButton.isEnabled = true
        }
    }
    
    @IBAction func finishBroadcast(_ sender: UIBarButtonItem) {
        broadcastController?.finishBroadcast { [unowned self] error in
            print("finish broadcast with error: \(error)")
            
            self.pauseBarButton.isEnabled = false
            self.resumeBarButton.isEnabled = false
            sender.isEnabled = false
        }
    }
}

extension ViewController: RPBroadcastActivityViewControllerDelegate {
    func broadcastActivityViewController(_ broadcastActivityViewController: RPBroadcastActivityViewController, didFinishWith broadcastController: RPBroadcastController?, error: Error?) {
        self.broadcastController = broadcastController
        self.broadcastController?.delegate = self
        broadcastActivityViewController.dismiss(animated: true) {
            self.broadcastController?.startBroadcast { [unowned self] error in
                // broadcast started
                print("broadcast started with error: \(error)")
                self.pauseBarButton.isEnabled = true
                self.resumeBarButton.isEnabled = false
                self.finishBarButton.isEnabled = true
            }
        }
    }
}

extension ViewController: RPBroadcastControllerDelegate {
    func broadcastController(_ broadcastController: RPBroadcastController, didFinishWithError error: Error?) {
        print("broadcast did finish with error: \(error)")
    }
    
    func broadcastController(_ broadcastController: RPBroadcastController, didUpdateServiceInfo serviceInfo: [String : NSCoding & NSObjectProtocol]) {
        print("broadcast did update service info: \(serviceInfo)")
    }
}
