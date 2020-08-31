//
//  SearchVC.swift
//  ios-VirtualTourist-v2.0
//
//  Created by Abdullah Khayat on 8/31/20.
//  Copyright © 2020 Abdullah Khayat. All rights reserved.
//

import UIKit
import Kingfisher

class SearchVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    let searchController = UISearchController(searchResultsController: nil)
    
    var datasource = [NSURL]()
    let spacing: CGFloat = 5.0
    var page = 1
    var maxPages = 5

    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupNavBar()
        setupSearch()
        setupCollectionView()
    }
    
    // MARK:- ADD title and update images button
    func setupNavBar() {
        
        navigationItem.title = "Search"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(reloadImages))
    }
    
    func setupSearch() {
        
        // (delegate)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        // transparent background
        searchController.obscuresBackgroundDuringPresentation = false
        
        // navigation bar should be hidden when searching
        searchController.hidesNavigationBarDuringPresentation = false
        
        // placeholder
        searchController.searchBar.placeholder = "looking for something?"
        
        // takes out the search when moving between screens
        definesPresentationContext = true
        
        // always show searchbar
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // add search controller to navbar
        navigationItem.searchController = searchController
    }
    
    @objc func reloadImages() {
        
        if page < maxPages { page += 1 }
        else { page = 1 }
        
        FlickrClient.requestImages(page: page, search: "") { (urls, maxPages) in
            
//            self.pin.imagesURLS = urls
//            self.datasource = urls
            self.collectionView.reloadData()
        }
    }
    
    // MARK:- ADD collection view delegates and datasource
    func setupCollectionView() {
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        
        let url = datasource[indexPath.row].absoluteURL
        
        cell.imageView.kf.indicatorType = .activity
        cell.imageView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = storyboard?.instantiateViewController(identifier: "ImageDetailsVC") as! ImageDetailsVC
        let url = FlickrClient.getLargeImageURL(url: datasource[indexPath.row])
        vc.imageURL = url
        vc.placeholder = (collectionView.cellForItem(at: indexPath) as! ImageCell).imageView.image
        navigationController?.pushViewController(vc, animated: true)
    }

}

// MARK:- UISearchBarDelegate
extension SearchVC: UISearchBarDelegate, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        collectionView.reloadData()
    }
    
}

// MARK:- UICollectionViewDelegateFlowLayout
extension SearchVC: UICollectionViewDelegateFlowLayout {
    
    // MARK:- SET spacing between collection items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        spacing
    }
    
    // MARK:- SET spacing between collection items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        spacing
    }
    
    // MARK:- SET item size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // gets the safeArea size
        let viewArea = view.safeAreaLayoutGuide.layoutFrame
        
        let dimension: CGFloat!
        // [(screen width) - (1 spaces in between)] / [2 image columns]
        dimension = (viewArea.size.width - (1 * spacing)) / 2.0
        
        return CGSize(width: dimension, height: dimension)
    }
    
}

