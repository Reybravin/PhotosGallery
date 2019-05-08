//
//  PhotoImageView.swift
//  PhotosGallery
//
//  Created by SS on 5/8/19.
//  Copyright © 2019 SergiySachuk. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject,AnyObject>()

class PhotoImageView : UIImageView {
    
    var imageUrlString : String?
    
    func loadImage(urlString: String) {
        
        imageUrlString = urlString
        
        self.image = nil
        
        //1. Try to get the image from cache
        let key = urlString
        
        if let imageFromCache = imageCache.object(forKey: key as AnyObject) as? UIImage {
            self.image = imageFromCache
            return
        }
        
        //2. Download if not found in cache
        NetworkingService.shared.loadImage(urlString: urlString) { [weak self] (image) in
            
            if let image = image {
                
                if self?.imageUrlString == urlString {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
                imageCache.setObject(image, forKey: key as AnyObject)
                return
            }
           
        }
        
    }
    
}
