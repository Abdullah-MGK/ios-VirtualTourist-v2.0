//
//  ImagesVC.swift
//  ios-VirtualTourist
//
//  Created by Abdullah Khayat on 8/26/20.
//  Copyright © 2020 Abdullah Khayat. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import Kingfisher

class ImagesVC: UIViewController {
    
    // MARK:- Attributes
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //let dataController = DataController.get()
    var dataController: DataController!
    
    var pin: Pin!
    var datasource: [NSURL]!
    
    let spacing: CGFloat = 5.0
    var page = 1
    
    
    // MARK:- Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupNavBar()
        setupMap()
        setupCollectionView()
    }
    
    /// ADD title and update images button
    func setupNavBar() {
        
        navigationItem.title = "Photo Album"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(reloadImages))
    }
    
    // ADD collection view delegates and datasource
    func setupCollectionView() {
        
        collectionView.delegate = self
        collectionView.dataSource = self
        datasource = pin.imagesURLS
    }
    
    /// REQUEST new images
    @objc func reloadImages() {
        
        if page < pin.maxPages { page += 1 }
        else { page = 1 }
        
        FlickrClient.requestImages(page: page, latitude: pin.latitude, longitude: pin.longitude) { (urls, maxPages) in
            
            self.pin.imagesURLS = urls
            self.datasource = urls
            self.collectionView.reloadData()
            try? self.dataController.viewContext.save()
        }
    }
    
}


//MARK:- UICollectionViewDelegate, UICollectionViewDataSource
extension ImagesVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
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


// MARK:- UICollectionViewDelegateFlowLayout
extension ImagesVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // gets the safeArea size
        let viewArea = view.safeAreaLayoutGuide.layoutFrame
        
        let dimension: CGFloat!
        // [(screen width) - (1 spaces in between)] / [2 image columns]
        dimension = (viewArea.size.width - (1 * spacing)) / 2.0
        
        return CGSize(width: dimension, height: dimension)
    }
    
}


// MARK:- Map View
extension ImagesVC {
    
    /// SET map to show selected pin
    func setupMap() {
        
        mapView.isUserInteractionEnabled = false
        let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "title"
        annotation.subtitle = "subtitle"
        mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 20000, longitudinalMeters: 20000)
        mapView.setRegion(region, animated: true)
    }
    
}
