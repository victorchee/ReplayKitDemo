//
//  ViewController.swift
//  Record
//
//  Created by Migu on 2016/10/25.
//  Copyright © 2016年 VictorChee. All rights reserved.
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(ViewController.startRecording))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self.view)
        if let snap = snapBehavior {
            animator.removeBehavior(snap)
        }
        snapBehavior = UISnapBehavior(item: itemView, snapTo: point)
        animator.addBehavior(snapBehavior!)
    }
    
    func startRecording() {
        let recorder = RPScreenRecorder.shared()
        recorder.isMicrophoneEnabled = true
        recorder.isCameraEnabled = true
        recorder.delegate = self;
        
        recorder.startRecording { error in
            if let error = error {
                print(error.localizedDescription)
                self.alert(error.localizedDescription)
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Stop", style: .plain, target: self, action: #selector(ViewController.stopRecording))
            }
        }
    }
    
    func stopRecording() {
        let recorder = RPScreenRecorder.shared()
        
        recorder.stopRecording { previewController, error in
            if let error = error {
                print(error.localizedDescription)
                self.alert(error.localizedDescription)
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(ViewController.startRecording))
                
                if let preview = previewController {
                    preview.previewControllerDelegate = self
                    self.present(preview, animated: true, completion: nil)
                }
            }
        }
    }
    
    func alert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: RPScreenRecorderDelegate {
    func screenRecorderDidChangeAvailability(_ screenRecorder: RPScreenRecorder) {
        print("screen recorder did change availability")
    }
    
    func screenRecorder(_ screenRecorder: RPScreenRecorder, didStopRecordingWithError error: Error, previewViewController: RPPreviewViewController?) {
        print("screen recorder did stop recording : \(error.localizedDescription)")
    }
}

extension ViewController: RPPreviewViewControllerDelegate {
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        print("preview controller did finish")
        self.dismiss(animated: true, completion: nil)
    }
    
    func previewController(_ previewController: RPPreviewViewController, didFinishWithActivityTypes activityTypes: Set<String>) {
        print("preview controller did finish with activity types : \(activityTypes)")
        if activityTypes.contains("com.apple.UIKit.activity.SaveToCameraRoll") {
            // video has saved to camera roll
        } else {
            // cancel
        }
    }
}

