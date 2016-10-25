//
//  ViewController.swift
//  Broadcast
//
//  Created by Migu on 2016/10/25.
//  Copyright © 2016年 VictorChee. All rights reserved.
//

import UIKit
import ReplayKit

class ViewController: UIViewController, RPBroadcastActivityViewControllerDelegate, RPBroadcastControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didPressBroadcastButton(_ sender: UIBarButtonItem) {
        RPScreenRecorder.shared().isMicrophoneEnabled = true
        RPBroadcastActivityViewController.load { broadcastActivityViewController, error in
            if let broadcastActivityViewController = broadcastActivityViewController {
                broadcastActivityViewController.delegate = self
                self.present(broadcastActivityViewController, animated: true)
            }
        }
    }
    
    // MARK: RPBroadcastActivityViewControllerDelegate
    func broadcastActivityViewController(_ broadcastActivityViewController: RPBroadcastActivityViewController, didFinishWith broadcastController: RPBroadcastController?, error: Error?) {
        broadcastController?.delegate = self
        broadcastActivityViewController.dismiss(animated: true) {
            broadcastController?.startBroadcast { error in
                // broadcast started
                print("broadcast started")
            }
        }
    }
    
    // MARK: - RPBroadcastControllerDelegate
    func broadcastController(_ broadcastController: RPBroadcastController, didFinishWithError error: Error?) {
        print("broadcast did finish with error: \(error)")
    }
    
    func broadcastController(_ broadcastController: RPBroadcastController, didUpdateServiceInfo serviceInfo: [String : NSCoding & NSObjectProtocol]) {
        print("broadcast did update service info: \(serviceInfo)")
    }
}

