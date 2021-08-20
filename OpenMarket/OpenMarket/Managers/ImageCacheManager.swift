//
//  CacheManager.swift
//  OpenMarket
//
//  Created by YongHoon JJo on 2021/08/20.
//

import UIKit

class ImageCacheManager {
    private let cache = NSCache<NSNumber, UIImage>()

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
}
