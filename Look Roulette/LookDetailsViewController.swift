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
import CropViewController
import GSImageViewerController

class LookDetailsViewController: UIViewController, LookModifiedDelegate {
    
    
    func userModifiedLook(modifiedLook: UIImage) {
        _thumbnailImage.image = modifiedLook
    }
    
    var items: Items!
    
    var modifiedLook: UIImage!
    
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
            
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any] {
                    self._transferImage.load(url: URL(string: json["transferImage"] as! String)!)
                    transferAlert.dismiss(animated: true, completion: nil)
                }
            case .failure:
                transferAlert.dismiss(animated: false, completion: nil)
                let alertController = UIAlertController(title: "Transfer", message:
                    "There was an error during Transfer. Check your Default Image or Look. If the error persists, contact support.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self.present(alertController, animated: true, completion: nil)
                break
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the default image
        getDefaultImage()
        
        _playerView.loadWithVideoId(items.id.videoId)
        _thumbnailImage.load(url: URL(string: items.snippet.thumbnails.high.url)!)
        
        // Thumbnail Tap
        let longTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(modifyLook(longTapGestureRecognizer:)))
        _thumbnailImage.addGestureRecognizer(longTapGestureRecognizer)
        
        _thumbnailImage.addGestureRecognizer(setImageTapGesture())
        _defaultImage.addGestureRecognizer(setImageTapGesture())
        _transferImage.addGestureRecognizer(setImageTapGesture())
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
    
    @objc func modifyLook(longTapGestureRecognizer: UILongPressGestureRecognizer) {
        let modifyAlert = UIAlertController(title: nil, message: "Modify the current look for a better Transfer.", preferredStyle: .actionSheet)
        
        // TODO: Remove until I can figure out capturing on device
//        let modify = UIAlertAction(title: "Modify Look", style: .default) { (action: UIAlertAction) in
//            self.performSegue(withIdentifier: "ModifyLook", sender: self)
//
//        }
        
        let crop = UIAlertAction(title: "Crop Look", style: .default) { (action: UIAlertAction) in
            self.cropLook()
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        //modifyAlert.addAction(modify)
        modifyAlert.addAction(crop)
        modifyAlert.addAction(cancel)
        self.present(modifyAlert, animated: true, completion: nil)
    }
    
    func cropLook() {
        let cropViewController = CropViewController(image: self._thumbnailImage.image!)
        cropViewController.delegate = self
        self.present(cropViewController, animated: true, completion: nil)
    }
    
    func setImageTapGesture() -> UITapGestureRecognizer {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedImage(tapGesture:)))
        return tapGesture
    }
    
    @objc func tappedImage(tapGesture: UITapGestureRecognizer) {
        if let image = tapGesture.view as? UIImageView {
            let imgInfo = GSImageInfo(image: image.image!, imageMode: .aspectFit)
            let imgTransitionInfo = GSTransitionInfo(fromView: self.view)
            let imgViewer = GSImageViewerController(imageInfo: imgInfo, transitionInfo: imgTransitionInfo)
            present(imgViewer, animated: true, completion: nil)
            
        }
    }
    

}

extension LookDetailsViewController: CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self._thumbnailImage.image = image
        dismiss(animated: true, completion: nil)
    }
}
