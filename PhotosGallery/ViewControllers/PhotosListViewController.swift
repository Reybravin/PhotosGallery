//
//  PhotosListViewController.swift
//  PhotosGallery
//
//  Created by SS on 5/8/19.
//  Copyright © 2019 SergiySachuk. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"


class PhotosListViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var viewModel = PhotosListViewModel()
    
    let defaultSpacing : CGFloat = 10
    
    private let api = AgileApi.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadImages()
        //fetchPictures(page: 1)
    }

    // MARK: Methods
    
    private func setupView(){
        self.collectionView!.register(PhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.view.backgroundColor = .cyan
    }
    
    private func loadImages(){
        
        fetchPictures(page: 1, completion: { success in
            if success {
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } else {
                print("Images loading error")
                //show error message to the user
            }
        })
    }
    
    private func fetchPictures(page: Int, completion: @escaping (_ success: Bool)->Void) {
        
        api.fetchImagesList(page: page) { [weak self] (result) in
            
            guard let strongSelf = self else { return }
            
            switch result {
                
            case .success(let imagesResponse):
                print(imagesResponse)
                strongSelf.saveImagesResponse(imagesResponse)
                completion(true)
                
            case .failure(let error):
                
                print(error)
                
                if strongSelf.isAuthError(error) {
                    
                    strongSelf.api.authenticateUser(completion: { (result) in
                        
                        if case .success (_ ) = result {
                            
                            strongSelf.api.fetchImagesList(page: page, completion: { (result) in
                                
                                if case .success (let imagesResponse) = result {
                                    strongSelf.saveImagesResponse(imagesResponse)
                                    completion(true)
                                    return
                                } else {
                                    completion(false)
                                }
                            })
                        } else {
                            completion(false)
                        }
                    })
                } else {
                    completion(false)
                }
            }
        }
    }
    
    private func isAuthError(_ error: Error)->Bool {
        if let error = error as? NetworkError {
            return error == .authError || error == .noToken
        }
        return false
    }
    
    private func loadMoreImages(){
        guard let currentImagesResponse = viewModel.currentPictureResponse else {
            return
        }
        if currentImagesResponse.page < currentImagesResponse.pageCount {
            fetchPictures(page: currentImagesResponse.page + 1, completion: { success in
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            })
        }
    }
    
    private func saveImagesResponse(_ response : PicturesResponse){
        viewModel.currentPictureResponse = response
        viewModel.dataSource.append(contentsOf: response.pictures)
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
        let picture = viewModel.dataSource[indexPath.row]
        cell.imageView.loadImage(urlString: picture.croppedPicture)
        return cell
    }

    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (self.view.frame.width - (defaultSpacing * 3)) / 2
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: defaultSpacing, left: defaultSpacing, bottom: defaultSpacing, right: defaultSpacing)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !viewModel.dataSource.isEmpty {
            if indexPath.row == viewModel.numberOfItemsInSection - 1 {  //numberofitem count
                loadMoreImages()
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.dataSource[indexPath.row]
        print("item:" , item)
    }
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    //        return defaultSpacing
    //    }
    //
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    //        return defaultSpacing
    //    }

}
