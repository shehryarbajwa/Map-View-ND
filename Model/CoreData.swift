//
//  CoreData.swift
//  MapView
//
//  Created by Shehryar Bajwa on 2018-08-15.
//  Copyright © 2018 Shehryar. All rights reserved.
//

import Foundation
import CoreData

struct CoreDataManager {
    static let share = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MapView")
        container.loadPersistentStores { (storeDescription, err) in
            if let err = err {
                fatalError("Failed to load the database: \(err)")
            }
        }
        return container
    }()
    
    func createPin(_ latitude: Double, _ longitude: Double)->(Pin?, String?){
        let context = CoreDataManager.share.persistentContainer.viewContext
        let pin = NSEntityDescription.insertNewObject(forEntityName: "Pin", into: context) as! Pin
        pin.latitude = latitude
        pin.longitude = longitude
        
        if saveContext(){
            return (pin, nil)
        }
        
        return (nil, "Error to create Pin")
    }
    
    func fetchPins()->[Pin]{
        let context = CoreDataManager.share.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
        
        do{
            let pins = try context.fetch(fetchRequest)
            print("successful")
            return pins
        }catch let error{
            print(error)
        }
        return [Pin]()
    }
    
    func removeObject(_ objects: [NSManagedObject])->Bool{
        let context = CoreDataManager.share.persistentContainer.viewContext
        
        for object in objects{
            context.delete(object)
        }
        
        return saveContext()
    }
    
    func insertPhotos(_ photosDic: [[String:Any]], _ pin: Pin){
        let context = CoreDataManager.share.persistentContainer.viewContext
        
        for dic in photosDic{
            let photo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: context) as! Photo
            photo.flickrID = dic[FlickrData.JSONResponseKeys.ID] as? String
            photo.url = dic[FlickrData.JSONResponseKeys.MediumURL] as? String
            photo.pin = pin
            context.insert(photo)
        }
        _ = saveContext()
    }
    
    func fetchPhotos()->[Photo]{
        let context = CoreDataManager.share.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
        do{
            let photos = try context.fetch(fetchRequest)
            return photos
        }catch let error{
            print(error)
        }
        return [Photo]()
    }
    
    func saveContext()->Bool{
        let context = CoreDataManager.share.persistentContainer.viewContext
        do{
            if context.hasChanges{
                try context.save()
            }
            return true
        } catch let error{
            print(error)
        }
        
        return false
    }
}


