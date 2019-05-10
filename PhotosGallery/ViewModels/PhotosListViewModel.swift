//
//  PhotosListViewModel.swift
//  PhotosGallery
//
//  Created by SS on 5/8/19.
//  Copyright © 2019 SergiySachuk. All rights reserved.
//

import Foundation

class PhotosListViewModel {
    
    //Callbacks:
    var didLoadImages : (()->Void)?
    
    //Dependecies
    private let api = AgileApi.shared

    //Properties
    private var isUserAuthenticated : Bool {
        get { return api.isAuthenticated }
        set { self.loadImages() }
    }
    
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
    
    func handleEndOfImagesList(indexPath: IndexPath){
        if !dataSource.isEmpty {
            if indexPath.row == numberOfItemsInSection - 1 {  //numberofitem count
                loadMoreImages()
            }
        }
    }
    
    func loadImages(){
        
        if isUserAuthenticated {
            fetchPictures(page: 1, completion: { [weak self] success in
                if success {
                    self?.didLoadImages?()
                }
            })
            
        } else {
            api.authenticateUser { [weak self] (result) in
                if case .success (_ ) = result {
                    self?.isUserAuthenticated = true
                }
            }
        }
        
    }
    
    private func loadMoreImages(){
        
        guard let currentImagesResponse = currentPictureResponse else {
            return
        }
        
        if currentImagesResponse.page < currentImagesResponse.pageCount {
            fetchPictures(page: currentImagesResponse.page + 1, completion: { [weak self] success in
                if success {
                    self?.didLoadImages?()
                }
                
            })
        }
    }
    
    func fetchPictures(page: Int, completion: @escaping (_ success: Bool)->Void) {
        
        api.fetchImagesList(page: page) { (result) in
            
            switch result {
                
            case .success(let imagesResponse):
                //print(imagesResponse)
                self.saveImagesResponse(imagesResponse)
                completion(true)
                
            case .failure(let error):
                //print(error)
                if self.isAuthError(error) {
                    self.api.deleteAccessToken()
                }
                completion(false)
            }
        }
    }
    
    private func saveImagesResponse(_ response : PicturesResponse){
        currentPictureResponse = response
        dataSource.append(contentsOf: response.pictures)
    }
    
    private func isAuthError(_ error: Error)->Bool {
        if let error = error as? NetworkError {
            return error == .authError || error == .noToken
        }
        return false
    }
    
}
