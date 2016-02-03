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
    
    @IBOutlet weak var itemView: UIView!
    
    var animator: UIDynamicAnimator!
    var snapBehavior: UISnapBehavior?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        animator = UIDynamicAnimator(referenceView: self.view)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .Plain, target: self, action: "startRecording")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tap(sender: UITapGestureRecognizer) {
        let point = sender.locationInView(self.view)
        if let snap = snapBehavior {
            animator.removeBehavior(snap)
        }
        snapBehavior = UISnapBehavior(item: itemView, snapToPoint: point)
        animator.addBehavior(snapBehavior!)
    }
    
    func startRecording() {
        let recorder = RPScreenRecorder.sharedRecorder()
        recorder.delegate = self;
        
        recorder.startRecordingWithMicrophoneEnabled(true) { (error) -> Void in
            if let error = error {
                print(error.localizedDescription)
                self.alert(error.localizedDescription)
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Stop", style: .Plain, target: self, action: "stopRecording")
            }
        }
    }
    
    func stopRecording() {
        let recorder = RPScreenRecorder.sharedRecorder()
        
        recorder.stopRecordingWithHandler { (previewController, error) -> Void in
            if let error = error {
                print(error.localizedDescription)
                self.alert(error.localizedDescription)
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .Plain, target: self, action: "startRecording")
                
                if let preview = previewController {
                    preview.previewControllerDelegate = self
                    self.presentViewController(preview, animated: true, completion: nil)
                }
            }
        }
    }
    
    func alert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

extension ViewController: RPScreenRecorderDelegate {
    func screenRecorderDidChangeAvailability(screenRecorder: RPScreenRecorder) {
        print("screen recorder did change availability")
    }
    
    func screenRecorder(screenRecorder: RPScreenRecorder, didStopRecordingWithError error: NSError, previewViewController: RPPreviewViewController?) {
        print("screen recorder did stop recording : \(error.localizedDescription)")
    }
}

extension ViewController: RPPreviewViewControllerDelegate {
    func previewControllerDidFinish(previewController: RPPreviewViewController) {
        print("preview controller did finish")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func previewController(previewController: RPPreviewViewController, didFinishWithActivityTypes activityTypes: Set<String>) {
        print("preview controller did finish with activity types : \(activityTypes)")
        if activityTypes.contains("com.apple.UIKit.activity.SaveToCameraRoll") {
            // video has saved to camera roll
        } else {
            // cancel
        }
    }
}

