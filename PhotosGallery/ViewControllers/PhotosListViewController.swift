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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
//        NetworkingService.shared.authenticateUser(completion: { result in
//            if case .success(let success) = result {
//                //
//            }
//        })
        
//        AgileApi.fetchImagesList(page: 1) { [weak self] (result) in
//            switch result {
//            case .success(let imagesResponse) :
//                print(imagesResponse)
//                self?.viewModel.dataSource = imagesResponse.pictures
//                DispatchQueue.main.async {
//                    self?.collectionView.reloadData()
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
        
        fetchPictures(page: 1)
    }

    // MARK: Methods
    
    private func setupView(){
        self.collectionView!.register(PhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.view.backgroundColor = .cyan
    }
    
    private func fetchPictures(page: Int) {
        
        AgileApi.fetchImagesList(page: page) { [weak self] (result) in
            switch result {
            case .success(let imagesResponse) :
                print(imagesResponse)
                self?.viewModel.currentPictureResponse = imagesResponse
                self?.viewModel.dataSource.append(contentsOf: imagesResponse.pictures)
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    
    private func fetchMoreImages(){
        guard let currentImagesResponse = viewModel.currentPictureResponse else {
            return
        }
        if currentImagesResponse.page < currentImagesResponse.pageCount {
            fetchPictures(page: currentImagesResponse.page + 1)
        }
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
                fetchMoreImages()
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
