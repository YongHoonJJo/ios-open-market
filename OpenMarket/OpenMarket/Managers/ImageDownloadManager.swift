//
//  ImageDownloadManager.swift
//  OpenMarket
//
//  Created by YongHoon JJo on 2021/08/20.
//

import UIKit

class ImageDownloadManager {
    private var downloadTasks: [URLSessionTask] = []
    
    func downloadImage(at index: Int, with url: String, completion: @escaping (IndexPath)
      -> Void) {
        guard ImageCacheManager.shared.loadCachedData(key: url) == nil else {
            return
        }
        
        guard let targetUrl = URL(string: url) else {
            return
        }
        
        guard !downloadTasks.contains(where: { $0.originalRequest?.url == targetUrl }) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: targetUrl) { (data, response, error) in
            guard error == nil else {
                return
            }
            
            if let data = data,
               let image = UIImage(data: data) {
                ImageCacheManager.shared.setData(image, key: url)
                let reloadTargetIndexPath = IndexPath(row: index, section: 0)
                completion(reloadTargetIndexPath)
                self.completeTask()
            }
        }
        task.resume()
        downloadTasks.append(task)
    }
    
    func completeTask() {
        downloadTasks = downloadTasks.filter { $0.state != .completed }
    }
}
