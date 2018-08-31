//
//  CollectionViewCell.swift
//  MapView
//
//  Created by Shehryar Bajwa on 2018-08-15.
//  Copyright © 2018 Shehryar. All rights reserved.
//

import UIKit
import Foundation

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var mainImage: CollectionCellImages!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var highlightView: UIView!
    
    
    var photo: Photo?{
    
    didSet{
        guard let url = photo?.url else {
            return
        }
        self.showActivityIndicator(true)
        
        if let imageData = photo?.image {
            self.showActivityIndicator(false)
            let image = UIImage(data: imageData)
            mainImage.image = image
        } else {
            print("No existing photos found")
            downloadimage(url)
        }
        
    
    }
}
    
    func showActivityIndicator(_ status: Bool){
        self.activityView.isHidden = !status
        
        if status == true {
            self.activityView.startAnimating()
        }
        if status == false {
            self.activityView.stopAnimating()
        }
    }
    
    func downloadimage(_ urlString: String){
        self.isUserInteractionEnabled = false
        print(urlString)
        
        mainImage.downloadImage(stringURL: urlString){
            guard let image = self.mainImage.image else { return }
            
            let imageData = UIImageJPEGRepresentation(image, 1.0)
            self.photo?.image = imageData
            
            if CoreDataManager.share.saveContext(){
                self.showActivityIndicator(false)
                self.isUserInteractionEnabled = true
            }
            
            
        }
        
        
        
    }
}
