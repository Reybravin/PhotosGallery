//
//  PhotosListViewModel.swift
//  PhotosGallery
//
//  Created by SS on 5/8/19.
//  Copyright © 2019 SergiySachuk. All rights reserved.
//

import Foundation

struct PhotosListViewModel {
    
    var dataSource : [Picture] = []
    
    var currentPictureResponse : PicturesResponse?
    
    var hasMore : Bool {
        get {
            return currentPictureResponse?.hasMore ?? false
        }
    }
    
    var numberOfItemsInSection : Int {
        get {
            return dataSource.count
        }
    }
    
    func fetchImages(){
        //
    }
    
}
