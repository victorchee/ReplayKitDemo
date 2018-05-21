//
//  RecordViewController.swift
//  Record
//
//  Created by Migu on 2016/10/25.
//  Copyright © 2016年 VictorChee. All rights reserved.
//

import UIKit
import ReplayKit

class RecordViewController: UIViewController {
    
    @IBOutlet weak var itemView: UIView!
    
    var animator: UIDynamicAnimator!
    var snapBehavior: UISnapBehavior?
    
    @IBOutlet weak var recordBarButton: UIBarButtonItem!
    @IBOutlet weak var stopBarButton: UIBarButtonItem!
    @IBOutlet weak var discardBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        animator = UIDynamicAnimator(referenceView: self.view)
        
        if RPScreenRecorder.shared().isAvailable {
            recordBarButton.isEnabled = true
        }
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
    
    @IBAction func startRecording(_ sender: UIBarButtonItem) {
        let recorder = RPScreenRecorder.shared()
        recorder.isMicrophoneEnabled = true
        recorder.isCameraEnabled = true
        recorder.delegate = self;
        
        recorder.startRecording { [unowned self] error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                sender.isEnabled = false
                self.stopBarButton.isEnabled = true
                self.discardBarButton.isEnabled = true
                
                if let cameraPreviewView = recorder.cameraPreviewView {
                    cameraPreviewView.frame = CGRect(x: 0, y: self.topLayoutGuide.length, width: 100, height: 100)
                    self.view.addSubview(cameraPreviewView)
                }
            }
        }
    }
    
    @IBAction func stopRecording(_ sender: UIBarButtonItem) {
        let recorder = RPScreenRecorder.shared()
        
        recorder.stopRecording { [unowned self] previewController, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                sender.isEnabled = false
                self.recordBarButton.isEnabled = true
                self.discardBarButton.isEnabled = false
                
                if let preview = previewController {
                    preview.previewControllerDelegate = self
                    
                    preview.modalPresentationStyle = .fullScreen
                    
                    if let popover = preview.popoverPresentationController {
                        popover.barButtonItem = sender
                        popover.permittedArrowDirections = .any
                    }
                    
                    self.present(preview, animated: true)
                }
            }
        }
    }
    
    /// When you are all done with the recording. You can also just start a new recording and the old one will be discarded automatically.
    @IBAction func discardRecording(_ sender: UIBarButtonItem) {
        let recorder = RPScreenRecorder.shared()
        
        recorder.discardRecording { [unowned self] in
            sender.isEnabled = false
            self.recordBarButton.isEnabled = true
            self.stopBarButton.isEnabled = false
        }
    }
}

extension RecordViewController: RPScreenRecorderDelegate {
    func screenRecorderDidChangeAvailability(_ screenRecorder: RPScreenRecorder) {
        print("screen recorder did change availability")
    }
    
    func screenRecorder(_ screenRecorder: RPScreenRecorder, didStopRecordingWith previewViewController: RPPreviewViewController?, error: Error?) {
        print("screen recorder did stop recording : \(String(describing: error?.localizedDescription))")
    }
}

extension RecordViewController: RPPreviewViewControllerDelegate {
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        print("preview controller did finish")
        self.dismiss(animated: true, completion: nil)
    }
    
    func previewController(_ previewController: RPPreviewViewController, didFinishWithActivityTypes activityTypes: Set<String>) {
        print("preview controller did finish with activity types : \(activityTypes)")
        if activityTypes.contains(UIActivityType.saveToCameraRoll.rawValue) {
            // video has saved to camera roll
        } else {
            // cancel
        }
    }
}

