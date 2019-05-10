//
//  PhotoCell.swift
//  PhotosGallery
//
//  Created by SS on 5/8/19.
//  Copyright © 2019 SergiySachuk. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    var imageView : PhotoImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(){
        imageView = PhotoImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        imageView.backgroundColor = .lightGray //.yellow
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
    }
    
}

