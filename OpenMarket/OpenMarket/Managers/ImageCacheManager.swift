//
//  CacheManager.swift
//  OpenMarket
//
//  Created by YongHoon JJo on 2021/08/20.
//

import UIKit

class ImageCacheManager {
    private let cache = NSCache<NSNumber, UIImage>()
    private let cacheUrl = NSCache<NSString, UIImage>()

    static let shared: ImageCacheManager = ImageCacheManager.init()
    
    private init() {}
    
    func loadCachedData(key: Int) -> UIImage? {
        let itemNumber = NSNumber(value: key)
        return cache.object(forKey: itemNumber)
    }

    func setData(_ image: UIImage, key: Int) {
        let itemNumber = NSNumber(value: key)
        cache.setObject(image, forKey: itemNumber)
    }
    
    func loadCachedData(key: String) -> UIImage? {
        let itemUrl = NSString(string: key)
        return cacheUrl.object(forKey: itemUrl)
    }
    
    func setData(_ image: UIImage, key: String) {
        let itemUrl = NSString(string: key)
        cacheUrl.setObject(image, forKey: itemUrl)
    }
    
}
