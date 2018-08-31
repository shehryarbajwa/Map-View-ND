//
//  Extensions.swift
//  MapView
//
//  Created by Shehryar Bajwa on 2018-08-15.
//  Copyright © 2018 Shehryar. All rights reserved.
//



import Foundation
import MapKit

extension MapViewController{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else {return}
        mapView.deselectAnnotation(annotation, animated: true)
        
       
    }
    
    func populatePinsonMap(){
        var annotations = [MKAnnotation]()
        for pin in pins{
            let latitude = CLLocationDegrees(pin.latitude)
            let longitude = CLLocationDegrees(pin.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }
    
    func deletepin(_ annotation: MKAnnotation){
        guard let pin = getindividualpins(annotation) else {
            return
        }
        
        if (CoreDataManager.share.removeObject([pin])){
            mapView.removeAnnotation(annotation)
            
        }
    }
    
    func getindividualpins(_ annotation: MKAnnotation)->Pin? {
        
        for pin in pins{
            if pin.latitude == Double(annotation.coordinate.latitude) && pin.longitude == Double(annotation.coordinate.longitude){
                return pin
            }
        }
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imagesVC"{
            let destination = segue.destination as! ImagesViewController
            
            guard let annotationView = sender as? MKAnnotationView else {
                return
            }
            
            guard let annotation = annotationView.annotation else {
                return
            }
            
            guard let pin = getindividualpins(annotation)  else {
                return
            }
            destination.pin = pin
            destination.annotation = annotationView.annotation
            
        }
    }
}

