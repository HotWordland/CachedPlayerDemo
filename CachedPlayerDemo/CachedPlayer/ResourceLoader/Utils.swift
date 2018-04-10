//
//  Utils.swift
//  CachedPlayerDemo
//
//  Created by 廖雷 on 2018/4/10.
//  Copyright © 2018年 廖雷. All rights reserved.
//

import Foundation

extension URL {
    var fileSize: Int64 {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: path) {
            if let size = attributes[FileAttributeKey.size] as? Int64 {
                return size
            }
        }
        return 0
    }
}

extension String {
    func md5() -> String {
        return ""
    }
}

class Utils {
    static func destinationURL(by sourceURL: URL) -> URL {
        let fileURL = cacheDirectory().appendingPathComponent(sourceURL.absoluteString.md5() + ".cache")
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        }
        return fileURL
    }
    static func contentInfoURL(by sourceURL: URL) -> URL {
        return cacheDirectory().appendingPathComponent(sourceURL.absoluteString.md5() + ".header");
    }
    static func cacheDirectory() -> URL {
        let directory = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!).appendingPathComponent("video_cache")
        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }
        return directory
    }
}
