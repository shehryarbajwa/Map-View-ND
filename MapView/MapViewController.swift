//
//  ViewController.swift
//  MapView
//
//  Created by Shehryar Bajwa on 2018-08-15.
//  Copyright © 2018 Shehryar. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    var istheuserediting = false
    var pins = [Pin]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(addpinsonthemap)))
        
        pins =   CoreDataManager.share.fetchPins()
        populatePinsonMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func addpinsonthemap(sender: UIGestureRecognizer){
        if sender.state == .began {
            let point = sender.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let anonotation = MKPointAnnotation()
            anonotation.coordinate = coordinate
            mapView.addAnnotation(anonotation)
            let datacreation = CoreDataManager.share.createPin(Double(coordinate.latitude), Double(coordinate.longitude))
            
            guard let pin = datacreation.0 else {return}
            pins.append(pin)
        }
    }
    
    @IBAction func editButton(_ sender: Any) {
        istheuserediting = true
        let alert = UIAlertController(title: "Are you sure you want to delete an existing pin?", message: "Once finished deleting, please click the finish editing button", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .destructive) { (UIAlertAction) in
            self.istheuserediting = true
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            self.istheuserediting = false
        }
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
    
    @IBAction func finished(_ sender: Any) {
        istheuserediting = false
        
        let alert = UIAlertController(title: "Editing finished", message: "Your pins have been deleted", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true)
        
    }
    
}


