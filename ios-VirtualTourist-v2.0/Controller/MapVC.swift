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

class MapVC: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController2: DataController!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupNavBar()
        setupMap()
        setupLongPressGesture()
    }
    
    // MARK:- ADD title and back button TO navigation bar
    func setupNavBar() {
        
        navigationItem.title = "Virtual Tourist"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    }
    
    
    // MARK:- SAVE new annotation TO core data
    func saveAnnotation(coordinate: CLLocationCoordinate2D, completion: ((Pin) -> Void)? = nil) {
        
        let pin = Pin(context: dataController2.viewContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        
        FlickrClient.requestImages(latitude: pin.latitude, longitude: pin.longitude, search: "") { (urls, maxPages) in
            
            pin.imagesURLS = urls
            pin.maxPages = Int16(maxPages)
            completion?(pin)
            try? self.dataController2.viewContext.save()
        }
    }
    
    // MARK:- ADD loaded annotations from core data AND new annotation TO map annotations
    func addAnnotations(pins: [Pin]) {
        
        guard !pins.isEmpty else {
            return
        }
        
        var annotations = [MKPointAnnotation]()
        
        for pin in pins {
            let annotation = CustomMKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            annotation.title = "title"
            annotation.subtitle = "subtitle"
            annotation.pin = pin
            annotations.append(annotation)
        }
        
        //mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
    }
    
    // MARK:- SET annotation view
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
    
    // MARK:- SELECT annotation
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let imagesVC = storyboard?.instantiateViewController(identifier: "ImagesVC") as! ImagesVC
        imagesVC.pin = (view.annotation as! CustomMKPointAnnotation).pin
        imagesVC.dataController2 = dataController2
        navigationController?.pushViewController(imagesVC, animated: true)
    }
    
    // MARK:- CHANGE map region
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        setMapDefaults()
    }
    
    // MARK:- SET new map defaults
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
    
}


// MARK: Setup Map
extension MapVC {
    
    // MARK:- LOAD map defaults AND annotations
    func setupMap() {
        
        mapView.delegate = self
        loadMapDefaults()
        let pins = loadAnnotations()
        addAnnotations(pins: pins)
    }
    
    // MARK:- GET map defaults
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
    
    // MARK:- GET map annotations FROM core data
    func loadAnnotations() -> [Pin] {
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        if let pins = try? dataController2.viewContext.fetch(fetchRequest) {
            return pins
        }
        
        return [Pin]()
    }
    
}


// MARK:- Map Gesture Recognizer
extension MapVC: UIGestureRecognizerDelegate {
    
    // MARK:- ADD long press gesture recognizer TO map
    func setupLongPressGesture() {
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(sender:)))
        longPressGesture.delegate = self
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    // MARK:- SAVE AND ADD annotation TO map
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
    
    // MARK:- ALLOW adding annotations one after the other
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}


// MARK:- CustomMKPointAnnotation with Pin
class CustomMKPointAnnotation: MKPointAnnotation {
    var pin: Pin!
}
