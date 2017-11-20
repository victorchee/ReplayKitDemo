//
//  BroadcastHandlerViewController.swift
//  BroadcastHandler
//
//  Created by Migu on 2016/10/25.
//  Copyright © 2016年 VictorChee. All rights reserved.
//
// http://devstreaming.apple.com/videos/wwdc/2016/601nsio90cd7ylwimk9/601/601_go_live_with_replaykit.pdf
// https://www.qcloud.com/doc/api/258/6460

import UIKit
import AVKit
import AVFoundation

class BroadcastHandlerViewController: UITableViewController {
    
    var mp4Clips = [URL]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: UIControlEvents.valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.refreshControl?.sendActions(for: .valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(_ sender: UIRefreshControl) {
        mp4Clips.removeAll()
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.victorchee.broadcaster")
        let resourceKeys = [URLResourceKey.isDirectoryKey]
        let enumerator = FileManager.default.enumerator(at: groupURL!, includingPropertiesForKeys: resourceKeys, options: [.skipsHiddenFiles], errorHandler: nil)
        for case let fileURL as NSURL in enumerator! {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys), let isDirectory = resourceValues[.isDirectoryKey] as? Bool else {
                    continue
            }
            
            if !isDirectory {
                mp4Clips.append(fileURL as URL)
            }
        }
        
        tableView.reloadData()
        
        sender.endRefreshing()
    }
    
    @IBAction func deleteAllItems(_ sender: UIBarButtonItem) {
        if !mp4Clips.isEmpty {
            for fileURL in mp4Clips {
                try? FileManager.default.removeItem(at: fileURL)
            }
            tableView.refreshControl?.sendActions(for: .valueChanged)
        }
    }
    
    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mp4Clips.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let fileURL = mp4Clips[indexPath.row]
        cell.textLabel?.text = "\(fileURL.lastPathComponent)"
        return cell
    }
    
    // MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let fileURL = mp4Clips[indexPath.row]
        
        let player = AVPlayer(url: fileURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) { 
            player.play()
        }
    }
}

