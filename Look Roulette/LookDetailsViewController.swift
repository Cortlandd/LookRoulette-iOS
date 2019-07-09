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
import AWSS3

class LookDetailsViewController: UIViewController, LookModifiedDelegate {
    
    func userModifiedLook(modifiedLook: UIImage) {
        _thumbnailImage.image = modifiedLook
    }
    
    var transferAlert: UIAlertController!
    
    var items: Items!
    
    var modifiedLook: UIImage!
    
    var nomakeupImgURL: String!
    var makeupImgURL: String!
    
    @IBOutlet weak var _playerView: YoutubePlayerView!
    @IBOutlet weak var _thumbnailImage: UIImageView!
    @IBOutlet weak var _defaultImage: UIImageView!
    @IBOutlet weak var _transferImage: UIImageView!
    
    @IBAction func transferImage(_ sender: Any) {
        
        present(transferAlert, animated: true, completion: nil)
        
        let group = DispatchGroup()
        
        group.enter()
        DispatchQueue.main.async {
            self.uploadNoMakeupImage(image: self._defaultImage) { publicUrl, error in
                if let error = error {
                    print("error: \(error)")
                }
                
                if let url = publicUrl {
                    self.nomakeupImgURL = url
                    group.leave()
                }
            }
        }
        
        group.enter()
        DispatchQueue.main.async {
            self.uploadMakeupImage(image: self._thumbnailImage) { publicUrl, error in
                if let error = error {
                    print("error: \(error)")
                }
                
                if let url = publicUrl {
                    self.makeupImgURL = url
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            // Run transfer
            self.transfer()
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
        
        initTransferAlert()
        
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
        /*
        let modify = UIAlertAction(title: "Modify Look", style: .default) { (action: UIAlertAction) in
            self.performSegue(withIdentifier: "ModifyLook", sender: self)

        }
         */
        
        let crop = UIAlertAction(title: "Crop Look", style: .default) { (action: UIAlertAction) in
            self.cropLook()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        //modifyAlert.addAction(modify)
        modifyAlert.addAction(crop)
        modifyAlert.addAction(cancel)
        self.present(modifyAlert, animated: true, completion: nil)
    }
    
    func uploadNoMakeupImage(image: UIImageView, uploadCompletion: @escaping (_ publicUrl: String?, _ error: String?) -> ()) {
        
        print("Uploading No Makeup Image...")
        
        let ranTransferName = "nomakeup-\(randomString(length: 6)).png"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ranTransferName)
        let nomakeupData = image.image?.pngData()
        
        do {
            try nomakeupData?.write(to: fileURL)
        } catch let error {
            print(error)
        }
        
        let uploadExpression = AWSS3TransferUtilityUploadExpression()
        uploadExpression.setValue("public-read", forRequestHeader: "x-amz-acl")
        
        let completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock = { (task, error) -> Void in
            if let error = error {
                uploadCompletion(nil, error.localizedDescription)
            } else {
                let url = AWSS3.default().configuration.endpoint.url.absoluteURL
                let publicURL = url.appendingPathComponent(task.bucket).appendingPathComponent(task.key)
                uploadCompletion(publicURL.absoluteString, nil)
            }
            
        }
        
        let transferManager = AWSS3TransferUtility.default()
        
        transferManager.uploadFile(fileURL, bucket: "lookru-bucket", key: ranTransferName, contentType: "image/png", expression: uploadExpression, completionHandler: completionHandler)
        
    }
    
    func uploadMakeupImage(image: UIImageView, uploadCompletion: @escaping (_ publicUrl: String?, _ error: String?) -> ()) {
        
        let ranTransferName = "makeup-\(randomString(length: 6)).png"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ranTransferName)
        let makeupData = image.image?.pngData()
        
        do {
            try makeupData?.write(to: fileURL)
        } catch let error {
            print(error)
        }
        
        let uploadExpression = AWSS3TransferUtilityUploadExpression()
        uploadExpression.setValue("public-read", forRequestHeader: "x-amz-acl")
        
        let completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock = { (task, error) -> Void in
            if let error = error {
                uploadCompletion(nil, error.localizedDescription)
            } else {
                let url = AWSS3.default().configuration.endpoint.url.absoluteURL
                let publicURL = url.appendingPathComponent(task.bucket).appendingPathComponent(task.key)
                uploadCompletion(publicURL.absoluteString, nil)
            }
            
        }
        
        let transferManager = AWSS3TransferUtility.default()
        
        transferManager.uploadFile(fileURL, bucket: "lookru-bucket", key: ranTransferName, contentType: "image/png", expression: uploadExpression, completionHandler: completionHandler)
        
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
    
    func initTransferAlert() {
        transferAlert = UIAlertController(title: nil, message: "Transferring Look", preferredStyle: .alert)
        transferAlert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .gray
        loadingIndicator.startAnimating()
        transferAlert.view.addSubview(loadingIndicator)
    }
    
    func transfer() {
        
        let session = Alamofire.SessionManager()
        
        let params: Parameters = [
            "nomakeup_url": self.nomakeupImgURL!.description,
            "makeup_url": self.makeupImgURL!.description
        ]
        
        let headers = [
            "Content-Type": "text/html; charset=utf-8"
        ]
        
        if nomakeupImgURL != nil && makeupImgURL != nil {
            Alamofire.request("https://lookroulette.herokuapp.com/api/v1/makeup_transfer", method: .post, parameters: params, encoding: URLEncoding.queryString, headers: headers).responseJSON { (response) in
                print("No Makeup url: \(self.nomakeupImgURL!)")
                print("Makeup url: \(self.makeupImgURL!)")
                switch response.result {
                case .success(let value):
                    print("Successful Transfer")
                    if let json = value as? [String: Any] {
                        self._transferImage.load(url: URL(string: json["transferImage"] as! String)!)
                        self.transferAlert.dismiss(animated: true, completion: nil)
                    }
                case .failure:
                    print("Failed Transfer")
                    self.transferAlert.dismiss(animated: false, completion: nil)
                    let alertController = UIAlertController(title: "Transfer", message:
                        "There was an error during Transfer. Check your Default Image or Look. If the error persists, contact support.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                    break
                }
                
            }
        } else {
            self.transferAlert.dismiss(animated: false, completion: nil)
            let alertController = UIAlertController(title: "Transfer", message:
                "An error occurred. Check your Default Image and Look.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func tappedImage(tapGesture: UITapGestureRecognizer) {
        if let image = tapGesture.view as? UIImageView {
            let imgInfo = GSImageInfo(image: image.image!, imageMode: .aspectFit)
            let imgTransitionInfo = GSTransitionInfo(fromView: self.view)
            let imgViewer = GSImageViewerController(imageInfo: imgInfo, transitionInfo: imgTransitionInfo)
            present(imgViewer, animated: true, completion: nil)
            
        }
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    

}

extension LookDetailsViewController: CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self._thumbnailImage.image = image
        dismiss(animated: true, completion: nil)
    }
}
