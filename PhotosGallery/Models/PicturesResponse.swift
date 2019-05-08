//
//  PicturesResponse.swift
//  PhotosGallery
//
//  Created by SS on 5/8/19.
//  Copyright © 2019 SergiySachuk. All rights reserved.
//

import Foundation

struct PicturesResponse : Decodable {
    
    var pictures : [Picture]
    var page : Int
    var pageCount : Int
    var hasMore : Bool

}

struct Picture : Decodable {
    var id: String
    var croppedPicture : String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case croppedPicture = "cropped_picture"
    }
}
