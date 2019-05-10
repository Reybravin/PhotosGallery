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
    
    var dataSource : [Picture] = []
    
    var numberOfItemsInSection : Int {
        get {
            return dataSource.count
        }
    }
    
    private var currentPictureResponse : PicturesResponse?
    
    private var isUserAuthenticated : Bool {
        get { return api.isAuthenticated }
        set { self.loadImages() }
    }

    
    //Methods:
    
    func loadImages(){
        
        if isUserAuthenticated {
            fetchImages(page: 1, completion: { [weak self] success in
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
    
    func handleEndOfImagesPage(indexPath: IndexPath){
        if !dataSource.isEmpty {
            if indexPath.row == numberOfItemsInSection - 1 {  //numberofitem count
                loadMoreImages()
            }
        }
    }
    
    private func loadMoreImages(){
        
        guard let currentImagesResponse = currentPictureResponse else { return }
        
        if currentImagesResponse.page < currentImagesResponse.pageCount {
            fetchImages(page: currentImagesResponse.page + 1, completion: { [weak self] success in
                if success {
                    self?.didLoadImages?()
                }
            })
        }
    }
    
    private func fetchImages(page: Int, completion: @escaping (_ success: Bool)->Void) {
        
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
