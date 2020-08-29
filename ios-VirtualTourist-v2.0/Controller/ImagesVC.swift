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

class ImagesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //let dataController = DataController.get()
    var dataController2: DataController!
    
    var pin: Pin!
    var datasource: [NSURL]!
    
    let spacing: CGFloat = 5.0
    var page = 1
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupNavBar()
        setupMap()
        setupCollectionView()
    }
    
    // MARK:- ADD title and update images button
    func setupNavBar() {
        
        navigationItem.title = "Photo Album"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(reloadImages))
    }
    
    // MARK:- ADD collection view delegates and datasource
    func setupCollectionView() {
        
        collectionView.delegate = self
        collectionView.dataSource = self
        datasource = pin.imagesURLS
    }
    
    // MARK:- UPDATE images
    @objc func reloadImages() {
        
        if page < pin.maxPages { page += 1 }
        else { page = 1 }
        
        FlickrClient.requestImages(latitude: pin.latitude, longitude: pin.longitude, page: page) { (urls, maxPages) in
            
            self.pin.imagesURLS = urls
            self.datasource = urls
            self.collectionView.reloadData()
            try? self.dataController2.viewContext.save()
        }
    }
    
    // MARK:- SET collection view number of items
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        datasource.count
    }
    
    // MARK:- SET collection view cell for item
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        
        cell.imageView.image = #imageLiteral(resourceName: "placeholder")
        cell.imageView.kf.indicatorType = .activity
        let url = datasource[indexPath.row].absoluteURL
        cell.imageView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
        
        return cell
    }
    
    //MARK:- REMOVE selcted item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        datasource.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
    }
    
}

// MARK:- Map View
extension ImagesVC {
    
    // MARK:- SET map to show selected pin
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

// MARK:- UICollectionViewDelegateFlowLayout
extension ImagesVC: UICollectionViewDelegateFlowLayout {
    
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
