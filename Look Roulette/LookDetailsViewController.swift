//
//  LookDetailsViewController.swift
//  Look Roulette
//
//  Created by Cortland Walker on 6/30/19.
//  Copyright © 2019 Cortland Walker. All rights reserved.
//

import UIKit
import YoutubePlayerView
import Alamofire.Swift

class LookDetailsViewController: UIViewController, LookModifiedDelegate {
    
    func userModifiedLook(modifiedLook: UIImage) {
        _thumbnailImage.image = modifiedLook
    }
    
    var items: Items!
    
    var modifiedLook: UIImage!
    
    @IBOutlet weak var _videoTitle: UILabel!
    @IBOutlet weak var _playerView: YoutubePlayerView!
    @IBOutlet weak var _thumbnailImage: UIImageView!
    @IBOutlet weak var _defaultImage: UIImageView!
    @IBOutlet weak var _transferImage: UIImageView!
    
    @IBAction func transferImage(_ sender: Any) {
        
        let transferAlert = UIAlertController(title: nil, message: "Transferring Look...", preferredStyle: .alert)
        transferAlert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .gray
        loadingIndicator.startAnimating()
        transferAlert.view.addSubview(loadingIndicator)
        present(transferAlert, animated: true, completion: nil)
        
        let nomakeupData = _defaultImage.image!.pngData()
        let makeupData = _thumbnailImage.image!.pngData()
        
        let session = Alamofire.Session.default

        session.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(nomakeupData!, withName: "nomakeup_file", fileName: "nomakeup.png", mimeType: "image/png")
                multipartFormData.append(makeupData!, withName: "makeup_file", fileName: "makeup.png", mimeType: "image/png")
        }, usingThreshold: UInt64(0),
           to: "https://lookroulette.herokuapp.com/api/v1/makeup_transfer").responseJSON { (response) in
            
            //debugPrint(response)
            
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any] {
                    self._transferImage.load(url: URL(string: json["transferImage"] as! String)!)
                    transferAlert.dismiss(animated: true, completion: nil)
                }
            case .failure:
                break
            }
            
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the default image
        getDefaultImage()
        
        _videoTitle.text = items.snippet.title
        _playerView.loadWithVideoId(items.id.videoId)
        _thumbnailImage.load(url: URL(string: items.snippet.thumbnails.high.url)!)
        
        // Thumbnail Tap
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(modifyLook(tapGestureRecognizer:)))
        _thumbnailImage.isUserInteractionEnabled = true
        _thumbnailImage.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
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
            
            modifyLookController.delegate = self
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
    
    @objc func modifyLook(tapGestureRecognizer: UIGestureRecognizer) {
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
