//
//  ViewController.swift
//  CachedPlayerDemo
//
//  Created by 廖雷 on 2018/4/9.
//  Copyright © 2018年 廖雷. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
//    let playerView = CachedPlayerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let playerView = CachedPlayerView()
        playerView.player.statusDidChangeHandler = { status in
            print(status)
        }
        playerView.player.playedDurationDidChangeHandler = { (played, total) in
            print("\(played)/\(total)")
        }
        playerView.frame = view.bounds
        playerView.player.replace(with: URL(string: "https://mvvideo5.meitudata.com/56ea0e90d6cb2653.mp4")!)
        playerView.player.play()
        
        
        view.addSubview(playerView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

