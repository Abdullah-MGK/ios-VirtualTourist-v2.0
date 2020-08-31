//
//  ImageDetailsVC.swift
//  ios-VirtualTourist-v2.0
//
//  Created by Abdullah Khayat on 8/29/20.
//  Copyright © 2020 Abdullah Khayat. All rights reserved.
//

import UIKit
import Kingfisher

class ImageDetailsVC: UIViewController {
    
    // MARK:- Attributes
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var placeholder: UIImage?
    var imageURL: NSURL!
    
    
    // MARK:- Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupNavbar()
        setupImage()
        setupScrollView()
        setupDoubleTapGesture()
    }
    
    /// ADD title and share image button
    func setupNavbar() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareImage))
        enableShareBTN(isEnabled: false)
    }
    
    /// GET Image from Flickr
    func setupImage() {
        
        print(imageURL.absoluteURL!)
        
        if placeholder == nil {
            placeholder = #imageLiteral(resourceName: "placeholder")
        }
        
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: imageURL.absoluteURL!, placeholder: placeholder, options: [.transition(.fade(0.2))]) { _ in
            self.enableShareBTN(isEnabled: true)
        }
    }
    
    /// SET UIActivityViewController
    @objc func shareImage() {
        
        let image = imageView.image!
        
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        present(controller, animated: true, completion: nil)
    }
    
    /// TOGGLE share button
    func enableShareBTN(isEnabled: Bool?) {

        if let isEnabled = isEnabled {
            navigationItem.rightBarButtonItem?.isEnabled = isEnabled
        }
        else {
            navigationItem.rightBarButtonItem?.isEnabled = !(navigationItem.rightBarButtonItem!.isEnabled)
        }
    }
    
}


// MARK:- UIScrollViewDelegate
extension ImageDetailsVC: UIScrollViewDelegate {
    
    /// SET scroll view properties
    func setupScrollView() {
        
        scrollView.delegate = self
        scrollView.maximumZoomScale = 3
        scrollView.minimumZoomScale = 1
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bouncesZoom = true
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
}


// MARK:- UIGestureRecognizerDelegate
extension ImageDetailsVC: UIGestureRecognizerDelegate {
    
    /// ADD double tap gesture recognizer
    func setupDoubleTapGesture() {
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapGesture(sender:)))
        doubleTapGesture.delegate = self
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
    }
    
    /// SET zoom scale
    @objc func handleDoubleTapGesture(sender: UITapGestureRecognizer) {
        
        if scrollView.zoomScale == 1 {
            scrollView.setZoomScale(2, animated: true)
        }
        else if scrollView.zoomScale == 2 {
            scrollView.setZoomScale(3, animated: true)
        }
        else {
            scrollView.setZoomScale(1, animated: true)
        }
    }
    
}
