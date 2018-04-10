//
//  CommonVideoView.swift
//  CachedPlayerDemo
//
//  Created by 廖雷 on 2018/4/10.
//  Copyright © 2018年 廖雷. All rights reserved.
//

import UIKit
import AVFoundation

class CachedPlayerView: UIView {
    private(set) var player = CachedPlayer()
    
    override class var layerClass: AnyClass {
        get {
            return AVPlayerLayer.self
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        player.bind(to: layer as! AVPlayerLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
