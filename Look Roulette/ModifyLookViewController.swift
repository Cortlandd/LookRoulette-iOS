//
//  ModifyLookViewController.swift
//  Look Roulette
//
//  Created by Cortland Walker on 7/1/19.
//  Copyright © 2019 Cortland Walker. All rights reserved.
//

import UIKit
import YoutubePlayerView

protocol LookModifiedDelegate: class {
    func userModifiedLook(modifiedLook: UIImage)
}

class ModifyLookViewController: UIViewController {

    weak var delegate: LookModifiedDelegate? = nil
    
    var items: Items!
    
    var currentImage: UIImage!
    
    @IBOutlet weak var _playerView: YoutubePlayerView!
    
    @IBAction func captureLook(_ sender: Any) {
        _modifiedLook.image = imageWithView(view: _playerView)
    }
    
    @IBAction func closeModifyLook(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveModifiedLook(_ sender: Any) {
        
        // If the user created a modified look save it to details page and exit, or just leave.
        if _modifiedLook.image != nil {
            // Pass image
            delegate?.userModifiedLook(modifiedLook: _modifiedLook.image!)
            
            // Gotta be a better way of doing this
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    @IBOutlet weak var _modifiedLook: UIImageView!
    @IBOutlet weak var _currentLook: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let playerVars: [String: Any] = [
            "controls": 1,
            "modestbranding": 1,
            "playsinline": 1,
            "rel": 0,
            "autoplay": 1
        ]
        
        _playerView.loadWithVideoId(items.id.videoId, with: playerVars)
        _currentLook.image = currentImage
        
    }
    
    func imageWithView(view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        return UIGraphicsGetImageFromCurrentImageContext()
    }

}
