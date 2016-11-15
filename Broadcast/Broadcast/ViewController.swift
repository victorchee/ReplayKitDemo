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
        
        let recorder = RPScreenRecorder.shared()
        recorder.isMicrophoneEnabled = true
        recorder.isCameraEnabled = true
        AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
            
        }
        
        let emitterLayer = CAEmitterLayer()
        emitterLayer.frame = view.bounds
        emitterLayer.renderMode = kCAEmitterLayerAdditive
        emitterLayer.emitterPosition = view.center
        emitterLayer.emitterCells = [emitterCell(color: UIColor.orange)]
//        view.layer.addSublayer(emitterLayer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func emitterCell(color: UIColor) -> CAEmitterCell {
        let emitterCell = CAEmitterCell()
        emitterCell.contents = UIImage(named: "image")?.cgImage
        emitterCell.birthRate = 150
        emitterCell.lifetime = 5
        emitterCell.color = color.cgColor
        emitterCell.velocity = 50
        emitterCell.velocityRange = 50
        emitterCell.emissionRange = CGFloat(M_PI * 2.0)
        return emitterCell
    }

    @IBAction func broadcast(_ sender: UIBarButtonItem) {
        if RPScreenRecorder.shared().isRecording {
            broadcastController?.finishBroadcast { [unowned self] error in
                print("finish broadcast with error: \(error)")
                
                self.pauseBarButton.isEnabled = false
                self.resumeBarButton.isEnabled = false
                sender.isEnabled = false
            }
        } else {
            RPBroadcastActivityViewController.load { broadcastActivityViewController, error in
                if let broadcastActivityViewController = broadcastActivityViewController {
                    broadcastActivityViewController.delegate = self
                    
                    broadcastActivityViewController.modalPresentationStyle = .popover
                    
                    if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                        broadcastActivityViewController.popoverPresentationController?.barButtonItem = sender
                    }
                    
                    self.present(broadcastActivityViewController, animated: true)
                }
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
        RPScreenRecorder.shared().stopRecording { (previewViewController, error) in
            
        }
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
                
                if let cameraPreviewView = RPScreenRecorder.shared().cameraPreviewView {
                    cameraPreviewView.frame = CGRect(x: 0, y: self.topLayoutGuide.length, width: 200, height: 200)
                    self.view.addSubview(cameraPreviewView)
                }
                
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
