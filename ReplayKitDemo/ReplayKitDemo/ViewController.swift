//
//  ViewController.swift
//  ReplayKitDemo
//
//  Created by qihaijun on 12/18/15.
//  Copyright © 2015 VictorChee. All rights reserved.
//

import UIKit
import ReplayKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .Plain, target: self, action: "startRecording")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func startRecording() {
        let recorder = RPScreenRecorder.sharedRecorder()
        
        recorder.startRecordingWithMicrophoneEnabled(true) { (error) -> Void in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Stop", style: .Plain, target: self, action: "stopRecording")
            }
        }
    }
    
    func stopRecording() {
        let recorder = RPScreenRecorder.sharedRecorder()
        
        recorder.stopRecordingWithHandler { (previewController, error) -> Void in
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .Plain, target: self, action: "startRecording")
            
            if let preview = previewController {
                preview.previewControllerDelegate = self
                self.presentViewController(preview, animated: true, completion: nil)
            }
        }
    }
}

extension ViewController: RPPreviewViewControllerDelegate {
    func previewControllerDidFinish(previewController: RPPreviewViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

