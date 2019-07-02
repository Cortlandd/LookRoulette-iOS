//
//  LookDetailsViewController.swift
//  Look Roulette
//
//  Created by Cortland Walker on 6/30/19.
//  Copyright © 2019 Cortland Walker. All rights reserved.
//

import UIKit
import YoutubePlayerView

class LookDetailsViewController: UIViewController {
    
    var items: Items!
    
    @IBOutlet weak var _videoTitle: UILabel!
    @IBOutlet weak var _playerView: YoutubePlayerView!
    @IBOutlet weak var _thumbnailImage: UIImageView!
    @IBOutlet weak var _defaultImage: UIImageView!
    @IBOutlet weak var _transferImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // set the default image
        getDefaultImage()
        
        _videoTitle.text = items.snippet.title
        _playerView.loadWithVideoId(items.id.videoId)
        _thumbnailImage.load(url: URL(string: items.snippet.thumbnails.high.url)!)
        
        // Thumbnail Tap
        let longTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(modifyLook(longTapGestureRecognizer:)))
        _thumbnailImage.isUserInteractionEnabled = true
        _thumbnailImage.addGestureRecognizer(longTapGestureRecognizer)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        // Need to dispose of everything for memory
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ModifyLook":
            let modifyLookController = segue.destination as! ModifyLookViewController
            modifyLookController.items = self.items
            modifyLookController.currentImage = self._thumbnailImage.image
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
    
    func getDefaultImage() {
        // set the default image
        if UserDefaults.standard.object(forKey: "DefaultImage") != nil {
            let imageData = UserDefaults.standard.object(forKey: "DefaultImage") as! NSData
            _defaultImage.image = UIImage(data: imageData as Data)
        } else {
            _defaultImage.image = #imageLiteral(resourceName: "pyramid-7")
        }
    }
    
    @objc func modifyLook(longTapGestureRecognizer: UILongPressGestureRecognizer) {
        let modifyAlert = UIAlertController(title: nil, message: "Modify the current look for a better Transfer.", preferredStyle: .actionSheet)
        
        let modify = UIAlertAction(title: "Modify Look", style: .default) { (action: UIAlertAction) in
            self.performSegue(withIdentifier: "ModifyLook", sender: self)
            
        }
        
        let crop = UIAlertAction(title: "Crop Look", style: .default) { (action: UIAlertAction) in
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        modifyAlert.addAction(modify)
        modifyAlert.addAction(crop)
        modifyAlert.addAction(cancel)
        self.present(modifyAlert, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
