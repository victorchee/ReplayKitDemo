//
//  MovieClipHandler.swift
//  BroadcastUploadExtension
//
//  Created by VictorChee on 2016/10/25.
//  Copyright © 2016年 VictorChee. All rights reserved.
//

import Foundation
import ReplayKit

class MovieClipHandler: RPBroadcastMP4ClipHandler {
    
    override func processMP4Clip(with mp4ClipURL: URL?, setupInfo: [String : NSObject]?, finished: Bool) {
        // save mp4 clip to group
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.victorchee.broadcaster")
        let destinationURL = groupURL?.appendingPathComponent(mp4ClipURL!.lastPathComponent)
        try? FileManager.default.copyItem(at: mp4ClipURL!, to: destinationURL!)
        
        super.processMP4Clip(with: mp4ClipURL, setupInfo: setupInfo, finished: finished)
        
        /*
        // Get the endpoint url supplied by the UI extension in the service info dictionary
        let url = URL(string: setupInfo!["endpointURL"] as! String)
        
        // Set up the request
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        // Upload the movie file with an upload task
        let session = URLSession.shared
        let uploadTask = session.uploadTask(with: request, fromFile: mp4ClipURL!) { (data, response, error) in
            if (error != nil) {
                // Handle error locally
            }
            
            // Update broadcast settings if necessary
            let broadcastConfiguration = RPBroadcastConfiguration()
            broadcastConfiguration.clipDuration = 5
            
            // Tell ReplayKit that processing is complete for thie clip
            self.finishedProcessingMP4Clip(withUpdatedBroadcastConfiguration: broadcastConfiguration, error: nil)
        }
        
        uploadTask.resume()
        */
    }
    
    override func finishedProcessingMP4Clip(withUpdatedBroadcastConfiguration broadcastConfiguration: RPBroadcastConfiguration?, error: Error?) {
        print("\(broadcastConfiguration):\(error)")
        super.finishedProcessingMP4Clip(withUpdatedBroadcastConfiguration: broadcastConfiguration, error: error)
    }
}
