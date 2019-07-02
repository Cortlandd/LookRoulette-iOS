//
//  FirstViewController.swift
//  Look Roulette
//
//  Created by Cortland Walker on 6/29/19.
//  Copyright © 2019 Cortland Walker. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var _defaultImage: UIImageView!
    
    var imagePicker: ImagePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        let longTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(imageLongTapped(longTapGestureRecognizer:)))
        longTapGestureRecognizer.minimumPressDuration = 0.3
        _defaultImage.isUserInteractionEnabled = true
        
        if UserDefaults.standard.object(forKey: "DefaultImage") != nil {
            let imageData = UserDefaults.standard.object(forKey: "DefaultImage") as! NSData
            _defaultImage.image = UIImage(data: imageData as Data)
            _defaultImage.addGestureRecognizer(tapGestureRecognizer)
            _defaultImage.addGestureRecognizer(longTapGestureRecognizer)
        } else {
            // Set image to pyramid if no preferences
            _defaultImage.image = #imageLiteral(resourceName: "pyramid-7")
            _defaultImage.addGestureRecognizer(longTapGestureRecognizer)
        }
        
        
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        print("Tapped")
        //self.imagePicker.present(from: tappedImage)
    }
    
    @objc func imageLongTapped(longTapGestureRecognizer: UILongPressGestureRecognizer) {
        let tappedImage = longTapGestureRecognizer.view as! UIImageView
        self.imagePicker.present(from: tappedImage)
    }

}

extension HomeViewController: ImagePickerDelegate {
    
    func didSelect(image: UIImage?) {
        let defaults = UserDefaults.standard
        let imageData: NSData = image!.pngData()! as NSData
        
        defaults.set(imageData, forKey: "DefaultImage")
        
        self._defaultImage.image = image
    }
}

