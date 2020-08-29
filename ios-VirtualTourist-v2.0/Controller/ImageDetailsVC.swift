//
//  ImageDetailsVC.swift
//  ios-VirtualTourist-v2.0
//
//  Created by Abdullah Khayat on 8/29/20.
//  Copyright © 2020 Abdullah Khayat. All rights reserved.
//

import UIKit

class ImageDetailsVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavbar()
        setupImage()
    }
    
    func setupNavbar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareImage))
    }
    
    func setupImage() {
        imageView.image = image
    }
    
    @objc func shareImage() {
        
    }
    
}
