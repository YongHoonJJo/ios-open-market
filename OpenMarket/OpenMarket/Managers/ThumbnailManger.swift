//
//  Landscape.swift
//  OpenMarket
//
//  Created by YongHoon JJo on 2021/08/20.
//

import UIKit

class ThumbnailManger {
    let urlString: String
    
    var url: URL {
        guard let url = URL(string: urlString) else {
            fatalError("invalid URL")
        }
        return url
    }
    
    var image: UIImage?
    
    
    init(urlString: String) {
        self.urlString = urlString
    }
}
