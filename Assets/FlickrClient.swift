//
//  FlickrClient.swift
//  MapView
//
//  Created by Shehryar Bajwa on 2018-08-15.
//  Copyright © 2018 Shehryar. All rights reserved.
//
import UIKit
import Foundation

class FlickrClient: NSObject{
    
    
    static let shared = FlickrClient()
    
    func taskforGetmethod(_ url: URL, _ completionhandler: @escaping(_ data: Data?, _ error: Error?)->Void){
        
        
        let task = URLSession.shared.dataTask(with: url){
            (data, response, error) in
            if let error = error {
                print(error)
            }
            
            guard let response = response as? HTTPURLResponse else {
                return
            }
            var statuscode = response.statusCode
            
            if statuscode == 200 {
                completionhandler(data, nil)
            }
            print(statuscode)
        }
         task.resume()
        }
    
    func flickrurl(_ extras: Bool?, _ bbox:String, _ page:String?)-> URL{
        
        var urlcomponents = URLComponents()
        var queryitems = [URLQueryItem]()
        
        urlcomponents.scheme = FlickrData.Flickr.APIScheme
        urlcomponents.host = FlickrData.Flickr.APIHost
        urlcomponents.path = FlickrData.Flickr.APIPath
        
        queryitems.append(URLQueryItem(name: FlickrData.JSONParameters.Method, value: FlickrData.JSONResponseKeys.SearchMethod))
        queryitems.append(URLQueryItem(name: FlickrData.JSONParameters.APIKey, value: FlickrData.JSONResponseKeys.APIKey))
        queryitems.append(URLQueryItem(name: FlickrData.JSONParameters.Format, value: FlickrData.JSONResponseKeys.ResponseFormat))
        queryitems.append(URLQueryItem(name: FlickrData.JSONParameters.BoundingBox, value: bbox))
        queryitems.append(URLQueryItem(name: FlickrData.JSONParameters.NoJSONCallback, value: FlickrData.JSONResponseKeys.DisableJSONCallback))
        queryitems.append(URLQueryItem(name: FlickrData.JSONParameters.PerPage, value: "30"))
        
        if let page = page {
            queryitems.append(URLQueryItem(name: FlickrData.JSONParameters.Page, value: page))
        }
        
        if (extras!){
            queryitems.append(URLQueryItem(name: FlickrData.JSONParameters.Extras, value: FlickrData.JSONResponseKeys.MediumURL))
        }
        urlcomponents.queryItems = queryitems
        return urlcomponents.url!
    }
    
    func downloadFlickrimages(_ bbox: String , _ page:String?=nil, completionhandler: @escaping (_ totalpages: Int?, _ data: [[String:AnyObject]]?, _ error: NSError?)->Void){
        
        let url = flickrurl(true, bbox, page)
        print(url)
        taskforGetmethod(url) { (data, error) in
            do{
                
                if let error = error {
                    print(error)
                    completionhandler(nil, nil, error as NSError)
                }
                
                guard let data = data else {
                    return
                }
                
                print(data)
                
                guard let parsedResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] , let photosDic = parsedResult["photos"] as? [String: AnyObject], let totalPages = photosDic["total"] as? String, let photosArray = photosDic["photo"] as? [[String: AnyObject]] else {
                    print("no luck")
                    return}
                
                print(parsedResult)
                guard let total = Int(totalPages) else {
                    return
                }
                
                completionhandler(total, photosArray , nil)
                
            } catch let error {
                print(error)
            }
        }
    }
    
    func downloadImagestoDisk(_ photosDictionary : [[String:AnyObject]])->[UIImage]{
        
        
        var imagesarray = [UIImage]()
        
        for array in photosDictionary{
            
            guard let mediumurl = array[FlickrData.JSONResponseKeys.MediumURL] as? String else {
                return imagesarray
            }
            
            guard let url = URL(string: mediumurl) as? URL else {
                return imagesarray
            }
            
            guard let imageData = try? Data(contentsOf: url) else {
                return imagesarray
            }
            
            guard let image = UIImage(data: imageData) else {
                return imagesarray
            }
            
            imagesarray.append(image)
            
            
            
        }
        return imagesarray
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
