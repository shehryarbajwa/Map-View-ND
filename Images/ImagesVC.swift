//
//  ImagesVC.swift
//  MapView
//
//  Created by Shehryar Bajwa on 2018-08-15.
//  Copyright © 2018 Shehryar. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

class ImagesViewController: UIViewController, MKMapViewDelegate{
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var button: UIButton!
    var annotation: MKAnnotation?
    var pin: Pin?
    var total = 0
    var photos = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.isUserInteractionEnabled = false
        self.collectionView.delegate = self
        self.collectionView.dataSource = self 
        collectionView.allowsMultipleSelection = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let annotation = annotation {
            mapView.addAnnotation(annotation)
            mapView.showAnnotations(mapView.annotations , animated: true)
        }
        
        guard let photoArray = pin?.photo?.allObjects as? [Photo] else{
            return
        }
        
        self.photos = photoArray
        
        if photos.count == 0 {
            loadimages()
        }
        
        
    }
    
    func loadimages(page: String? = nil){
        if let annotation = annotation {
            self.button.isEnabled = false
            
            let bbox = "\(annotation.coordinate.longitude), \(annotation.coordinate.latitude), \(annotation.coordinate.longitude+1), \(annotation.coordinate.latitude+1)"
            
            print(bbox)
            
            FlickrClient.shared.downloadFlickrimages(bbox, page) { (total, photosdictionary, error) in
                if let error = error{
                    print(error)
                    return
                }
                
                guard let total = total else {
                    return
                }
                
                guard let photosdictionary = photosdictionary else {
                    return
                }
                
                print(photosdictionary)
                
                self.total = total
                
                guard let pin = self.pin else {
                    return
                }
                
                CoreDataManager.share.insertPhotos(photosdictionary, pin)
                
                guard let photoArray = pin.photo?.allObjects as? [Photo] else {
                    return
                }
                
                self.photos = photoArray
                
                DispatchQueue.main.async {
                    
                    if (self.photos.count > 0){
                        self.collectionView.reloadData()
                        self.button.isEnabled = true
                    } else {
                        self.emptyalert()
                        self.button.isEnabled = true
                    }
                }
            }
        }
    }
        
        
        func emptyalert(){
            let alert = UIAlertController(title: "Unfortunately, there are no pictures associated with this location", message: "Please try a different location", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .destructive, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true)
        }
    
    func changeButtontitle(){
        
        guard let chosenindex = collectionView.indexPathsForSelectedItems?.count else {
            return
        }
        
        if (chosenindex > 0){
            button.setTitle("Remove Selected Image", for: .normal)
            return
        }
        
        button.setTitle("New Collection View", for: .normal)
    }
    
    @IBAction func newCollection(_ sender: Any) {
        if (button.titleLabel?.text == "New Collection View"){
            if(CoreDataManager.share.removeObject(pin?.photo?.allObjects as! [Photo])){
                loadnewImages()
            }
            return
        }
        removeImage()
    }
    
    func loadnewImages(){
        self.photos.removeAll()
        collectionView.reloadData()
        let randompage = Int(arc4random_uniform(UInt32(20)))
        loadimages(page: "\(randompage)")
    }
    
    func removeImage(){
        guard let chosenIndex = collectionView.indexPathsForSelectedItems else {
            return
        }
        var emptyarray = [Photo]()
        
        for index in chosenIndex{
            emptyarray.append(photos[index.item])
            print("appended photos")
            hightlightCell(index, highlighted: true)
            collectionView.deselectItem(at: index, animated: true)
            changeButtontitle()
        }
        
        if CoreDataManager.share.removeObject(emptyarray){
            guard let photoArray = pin?.photo?.allObjects as? [Photo] else {
                return
            }
            self.photos = photoArray
            collectionView.reloadData()
            changeButtontitle()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
        }else{
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    
    
    
    
    
    
    

}
