//
//  MapVC.swift
//  ios-VirtualTourist
//
//  Created by Abdullah Khayat on 8/26/20.
//  Copyright © 2020 Abdullah Khayat. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapVC: UIViewController {
    
    // MARK:- Variables
    
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController: DataController!
    var deletingAnnotations = [CustomMKPointAnnotation]()
    
    
    // MARK:- Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupNavBar()
        setupMap()
        setupLongPressGesture()
    }
    
    /// ADD title and back button TO navigation bar
    func setupNavBar() {
        
        navigationItem.title = "Virtual Tourist"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.rightBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelChanges))
        navigationItem.leftBarButtonItem?.isEnabled = false
    }
    
    /// ADD deleted pins
    @objc func cancelChanges() {
        
        // unnecssary if stmnt
        if !deletingAnnotations.isEmpty {
            mapView.addAnnotations(deletingAnnotations)
            deletingAnnotations = []
        }
        setEditing(false, animated: true)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if !editing {
            navigationItem.leftBarButtonItem?.isEnabled = false
            
            // unnecssary if stmnt
            if !deletingAnnotations.isEmpty {
                for annotation in deletingAnnotations {
                    dataController.viewContext.delete(annotation.pin)
                }
                deletingAnnotations = []
                try? dataController.viewContext.save()
            }
            editButtonItem.isEnabled = !mapView.annotations.isEmpty
            print("done")
        }
        else {
            editButtonItem.isEnabled = false
            navigationItem.leftBarButtonItem?.isEnabled = true
            print(editing)
        }
    }
    
}


// MARK:- MKMapViewDelegate
extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let pinId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: pinId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinId)
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if isEditing {
            let annotation = view.annotation as! CustomMKPointAnnotation
            deletingAnnotations.append(annotation)
            mapView.removeAnnotation(annotation)
            editButtonItem.isEnabled = true
            //dataController.viewContext.delete(annotation.pin)
            return
        }
        
        let imagesVC = storyboard?.instantiateViewController(identifier: "ImagesVC") as! ImagesVC
        imagesVC.pin = (view.annotation as! CustomMKPointAnnotation).pin
        imagesVC.dataController = dataController
        navigationController?.pushViewController(imagesVC, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if isEditing {
            return
        }
        
        setMapDefaults()
    }
    
}


// MARK: Setup Map
extension MapVC {
    
    /// LOAD map defaults AND annotations
    func setupMap() {
        
        mapView.delegate = self
        loadMapDefaults()
        let pins = loadAnnotations()
        addAnnotations(pins: pins)
    }
    
    /// GET map defaults
    func loadMapDefaults() {
        
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        
        if hasLaunchedBefore {
            
            let latitude = UserDefaults.standard.value(forKey: "x") as! Double
            let longitude = UserDefaults.standard.value(forKey: "y") as! Double
            let latitudeDelta = UserDefaults.standard.value(forKey: "z") as! Double
            let longitudeDelta = UserDefaults.standard.value(forKey: "w") as! Double
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
            
            mapView.setRegion(region, animated: true)
        }
        else {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            setMapDefaults()
        }
    }
    
    /// SAVE new annotation TO core data
    func saveAnnotation(coordinate: CLLocationCoordinate2D, completion: ((Pin) -> Void)? = nil) {
        
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        
        FlickrClient.requestImages(latitude: pin.latitude, longitude: pin.longitude) { (urls, maxPages) in
            
            pin.imagesURLS = urls
            pin.maxPages = Int16(maxPages)
            completion?(pin)
            try? self.dataController.viewContext.save()
        }
    }
    
    /// ADD loaded annotations from core data AND new annotation TO map annotations
    func addAnnotations(pins: [Pin]) {
        
        var annotations = [CustomMKPointAnnotation]()
        
        for pin in pins {
            let annotation = CustomMKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            annotation.title = "title"
            annotation.subtitle = "subtitle"
            annotation.pin = pin
            annotations.append(annotation)
        }
        
        editButtonItem.isEnabled = !annotations.isEmpty
        mapView.addAnnotations(annotations)
    }
    
    /// SET new map defaults
    func setMapDefaults() {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        let latitudeDelta =  mapView.region.span.latitudeDelta
        let longitudeDelta = mapView.region.span.longitudeDelta
        
        UserDefaults.standard.set(latitude, forKey: "x")
        UserDefaults.standard.set(longitude, forKey: "y")
        UserDefaults.standard.set(latitudeDelta, forKey: "z")
        UserDefaults.standard.set(longitudeDelta, forKey: "w")
    }
    
    /// GET map annotations FROM core data
    func loadAnnotations() -> [Pin] {
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        if let pins = try? dataController.viewContext.fetch(fetchRequest) {
            return pins
        }
        
        return [Pin]()
    }
    
}


// MARK:- UIGestureRecognizerDelegate
extension MapVC: UIGestureRecognizerDelegate {
    
    /// ADD long press gesture recognizer TO map
    func setupLongPressGesture() {
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(sender:)))
        longPressGesture.delegate = self
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    /// SAVE AND ADD annotation TO map
    @objc func handleLongPressGesture(sender: UILongPressGestureRecognizer) {
        
        switch sender.state {
            
        case .began:
            print("began")
            
            // get location and coordinate
            let location = sender.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            saveAnnotation(coordinate: coordinate) { (pin) in
                self.addAnnotations(pins: [pin])
                print("final", pin.imagesURLS!.count)
            }
            
        case .ended:
            print("ended")
            
        default: ()
        }
    }
    
    /// ALLOW adding annotations one after the other
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}


// MARK:- CustomMKPointAnnotation with Pin
class CustomMKPointAnnotation: MKPointAnnotation {
    var pin: Pin!
}
