//
//  BroadcastViewController.swift
//  BroadcastUploadExtensionUI
//
//  Created by Migu on 2016/10/25.
//  Copyright © 2016年 VictorChee. All rights reserved.
//

import ReplayKit

class BroadcastViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBAction func broadcast(_ sender: UIButton) {
        guard let username = usernameTextField.text else {
            let alert = UIAlertController(title: "Alert", message: "cancel broadcast?", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Confirm", style: .destructive, handler: { [unowned self] (action) in
                self.userDidCancelSetup()
            })
            let cancelAction = UIAlertAction(title: "NO", style: .cancel, handler: { (action) in
            })
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
            return
        }
        userDidFinishSetup()
    }

    // Called when the user has finished interacting with the view controller and a broadcast stream can start
    func userDidFinishSetup() {
        // Broadcast url that will be returned to the application
        let broadcastURL = URL(string:"http://broadcastURL_example/stream1")
        
        // Service specific broadcast data example which will be supplied to the process extension during broadcast
        let userID = "user1"
        let endpointURL = "http://broadcastURL_example/stream1/upload"
        let setupInfo: [String: NSCoding & NSObjectProtocol] =  [ "userID" : userID as NSString, "endpointURL" : endpointURL as NSString ]
        
        // Set broadcast settings
        let broadcastConfiguration = RPBroadcastConfiguration()
        broadcastConfiguration.clipDuration = 5
        
        // Tell ReplayKit that the extension is finished setting up and can begin broadcasting
        self.extensionContext?.completeRequest(withBroadcast: broadcastURL!, broadcastConfiguration: broadcastConfiguration, setupInfo: setupInfo)
    }
    
    func userDidCancelSetup() {
        let error = NSError(domain: "com.victorchee.broadcast", code: -1, userInfo: nil)
        // Tell ReplayKit that the extension was cancelled by the user
        self.extensionContext?.cancelRequest(withError: error)
    }
}
