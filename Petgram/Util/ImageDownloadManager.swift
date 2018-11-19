//
//  ImageDownloadManager.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import Foundation
import UIKit


class ImageDownloadManager {
    
    static let shared = ImageDownloadManager()
    
    private let imageCache = NSCache<NSString, UIImage>()
    
    func downloadImage(from urlString: String, scaleToScreenDensity: Bool = false, completion: ((_ image: UIImage?, _ instant: Bool) -> ())?) {
        if let url = URL(stripString: urlString) {
            downloadImage(
                from: url,
                scaleToScreenDensity: scaleToScreenDensity,
                completion: completion
            )
        } else {
            completion?(nil, true)
        }
    }
    
    
    func downloadImage(from url: URL, scaleToScreenDensity: Bool = false, completion: ((_ image: UIImage?, _ instant: Bool) -> ())?) {
        downloadImage(
            from: url as URL?,
            scaleToScreenDensity: scaleToScreenDensity,
            completion: completion
        )
    }
    
    private func downloadImage(from optionalURL: URL?, scaleToScreenDensity: Bool = false, completion: ((_ image: UIImage?, _ instant: Bool) -> ())?) {
        guard let url = optionalURL else {
            completion?(nil, true)
            return
        }
        
        if let image = self.imageCache.object(forKey: url.absoluteString as NSString) {
            completion?(image, true)
            return
        }
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let data = data, let image = UIImage(data: data), let cgImage = image.cgImage {
                self.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                
                if !scaleToScreenDensity {
                    completion?(image, false)
                } else {
                    completion?(
                        UIImage(
                            cgImage: cgImage,
                            scale: UIScreen.main.scale,
                            orientation: image.imageOrientation
                        ),
                        false
                    )
                }
            } else {
                completion?(nil, false)
            }
            
        }
        
        task.priority = URLSessionTask.lowPriority
        
        task.resume()
        
    }
    
    func downloadImages(from urlStrings: [String], scaleToScreenDensity: Bool = false, completion: ((_ images: [UIImage?], _ instant: Bool) -> ())?) {
        let urls = urlStrings.map { URL(string: $0) }
        downloadImages(
            from: urls,
            scaleToScreenDensity: scaleToScreenDensity,
            completion: completion
        )
    }
    
    private func downloadImages(from urls: [URL], scaleToScreenDensity: Bool = false, completion: ((_ images: [UIImage?], _ instant: Bool) -> ())?) {
        downloadImages(
            from: urls,
            scaleToScreenDensity: scaleToScreenDensity,
            completion: completion
        )
    }
    
    private func downloadImages(from optionalURLs: [URL?], scaleToScreenDensity: Bool = false, completion: ((_ images: [UIImage?], _ instant: Bool) -> ())?) {
        
        var images = [UIImage?](repeating: nil, count: optionalURLs.count)
        var instants = [Bool](repeating: false, count: optionalURLs.count)
        var returned = [Bool](repeating: false, count: optionalURLs.count)
        
        let lock = 0.0
        
        for (index, url) in optionalURLs.enumerated() {
            
            downloadImage(
                from: url,
                scaleToScreenDensity: scaleToScreenDensity,
                completion: { image, instant in
                    var allDone = false
                    
                    synchronize(lock: lock) {
                        images[index] = image
                        instants[index] = instant
                        returned[index] = true
                        
                        allDone = returned.reduce(true) { $0 && $1 }
                    }
                    
                    if allDone {
                        let instant = instants.reduce(true) { $0 && $1 }
                        completion?(images, instant)
                    }
            }
            )
        }
    }
    
}
