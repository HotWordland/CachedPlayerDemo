//
//  CachedPlayer.swift
//  CachedPlayerDemo
//
//  Created by 廖雷 on 2018/4/9.
//  Copyright © 2018年 廖雷. All rights reserved.
//

import Foundation
import AVFoundation

class CachedPlayer: NSObject {
    enum Status {
        case unknown        // 初始状态
        case buffering      // 加载中
        case playing        // 播放中
        case paused         // 暂停
        case end            // 播放到末尾
        case error          // 播放出错
    }
    var statusDidChangeHandler: ((Status) -> Void)?
    var playedDurationDidChangeHandler: ((TimeInterval, TimeInterval) -> Void)?
    
    var currentItem: AVPlayerItem?
    private(set) var duration: TimeInterval = 0
    private(set) var playedDuration: TimeInterval = 0 {
        didSet {
            playedDurationDidChangeHandler?(playedDuration, duration)
        }
    }
    private(set) var status = Status.unknown {
        didSet {
            guard status != oldValue else {
                return
            }
            statusDidChangeHandler?(status)
        }
    }
    
    private var observerContext = "CachedPlayer.KVO.Context"
    private var timeObserver: Any?
    
    private let player = AVPlayer()
    
    deinit {
        removeNotifications()
        removeItemObservers()
        removePlayerObservers()
    }
    override init() {
        super.init()
        
        addNotifications()
        addPlayerObservers()
    }
}

extension CachedPlayer {
    func replace(with url: URL) {
        currentItem = AVPlayerItem(url: url)
        addItemObservers()
        player.replaceCurrentItem(with: currentItem)
    }
    func stop() {
        removeItemObservers()
        currentItem = nil
        player.replaceCurrentItem(with: nil)
        
        status = .unknown
    }
    func play() {
        player.play()
    }
    func pause() {
        player.pause()
    }
    func seek(to time: TimeInterval) {
        player.seek(to: CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
    }
    func bind(to playerLayer: AVPlayerLayer) {
        playerLayer.player = player
    }
}

extension CachedPlayer {
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationPlayDidEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    private func addPlayerObservers() {
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.main, using: { [unowned self] (time) in
            self.updateStatus()
            
            guard let total = self.currentItem?.duration.seconds else {
                return
            }
            if total.isNaN || total.isZero {
                return
            }
            self.duration = total
            self.playedDuration = time.seconds
        })
        player.addObserver(self, forKeyPath: "rate", options: [.new], context: &observerContext)
        player.addObserver(self, forKeyPath: "status", options: [.new], context: &observerContext)
        if #available(iOS 10, *) {
            player.addObserver(self, forKeyPath: "timeControlStatus", options: .new, context: &observerContext)
        }
    }
    private func removePlayerObservers() {
        guard let timeObserver = timeObserver else {
            return
        }
        player.removeTimeObserver(timeObserver)
        player.removeObserver(self, forKeyPath: "rate", context: &observerContext)
        player.removeObserver(self, forKeyPath: "status", context: &observerContext)
        if #available(iOS 10, *) {
            player.removeObserver(self, forKeyPath: "timeControlStatus", context: &observerContext)
        }
    }
    private func addItemObservers() {
        currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: &observerContext)
        currentItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: &observerContext)
        currentItem?.addObserver(self, forKeyPath: "isPlaybackBufferEmpty", options: .new, context: &observerContext)
        currentItem?.addObserver(self, forKeyPath: "isPlaybackBufferFull", options: .new, context: &observerContext)
    }
    private func removeItemObservers() {
        currentItem?.removeObserver(self, forKeyPath: "status")
        currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        currentItem?.removeObserver(self, forKeyPath: "isPlaybackBufferEmpty")
        currentItem?.removeObserver(self, forKeyPath: "isPlaybackBufferFull")
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &observerContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        updateStatus()
    }
}

extension CachedPlayer {
    @objc private func onNotificationPlayDidEnd(_ notification: Notification) {
        guard (notification.object as? AVPlayerItem) == self.currentItem && self.currentItem != nil else {
            return
        }
        status = .end
    }
    private func updateStatus() {
        DispatchQueue.main.async {
            guard let currentItem = self.currentItem else {
                return
            }
            if self.player.error != nil || currentItem.error != nil {
                self.status = .error
                
                return
            }
            if #available(iOS 10, *) {
                switch self.player.timeControlStatus {
                case .playing:
                    self.status = .playing
                case .paused:
                    self.status = .paused
                case .waitingToPlayAtSpecifiedRate:
                    self.status = .buffering
                }
            } else {
                if self.player.rate != 0 {
                    if currentItem.isPlaybackLikelyToKeepUp {
                        self.status = .playing
                    } else {
                        self.status = .buffering
                    }
                } else {
                    self.status = .paused
                }
            }
        }
    }
}
