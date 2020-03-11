//
//  CoreDataManager.swift
//  GrainChain_iOS
//
//  Created by Guzmán, Omar (Cognizant) on 3/8/20.
//  Copyright © 2020 Guzmán, Omar. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

protocol CoreDataManagerProtocol {
    func loadTracks() -> [TrackInfo]?
    func saveTrack(trackInfo: [CLLocationCoordinate2D], distance: Double, name: String, duration: Double) -> Bool
    func removeTrack(trackInfo: TrackTableCellViewModel) -> Bool
}

class CoreDataManager: CoreDataManagerProtocol {

    static let shared = CoreDataManager()
    
    var storeType = NSSQLiteStoreType
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GrainChain_iOS")
        if let descriptionContainer = container.persistentStoreDescriptions.first {
            descriptionContainer.type = self.storeType
        }
        
        container.loadPersistentStores(completionHandler: { (_, error) in
            guard let error = error as NSError? else {
                return
            }
            fatalError("Unresolved Error: \(error), \(error.userInfo)")
        })
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
    func saveContext () {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // error handling implementation
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    /*Insert*/
    func saveTrack(trackInfo: [CLLocationCoordinate2D], distance: Double, name: String, duration: Double) -> Bool {
        /*1.
         Before you can save or retrieve anything from your Core Data store, you first need to get your hands on an NSManagedObjectContext. You can consider a managed object context as an in-memory “scratchpad” for working with managed objects.
         Think of saving a new managed object to Core Data as a two-step process: first, you insert a new managed object into a managed object context; then, after you’re happy with your shiny new managed object, you “commit” the changes in your managed object context to save it to disk.
         Xcode has already generated a managed object context as part of the new project’s template. Remember, this only happens if you check the Use Core Data checkbox at the beginning. This default managed object context lives as a property of the NSPersistentContainer in the application delegate. To access it, you first get a reference to the app delegate.
         */
        let managedContext = CoreDataManager.shared.persistentContainer.viewContext
        
        /*
         An NSEntityDescription object is associated with a specific class instance
         Class
         NSEntityDescription
         A description of an entity in Core Data.
         
         Retrieving an Entity with a Given Name here
         */
        let entity = NSEntityDescription.entity(forEntityName: "Track", in: managedContext)!
        
        /*
         Initializes a managed object and inserts it into the specified managed object context.
         
         init(entity: NSEntityDescription,
         insertInto context: NSManagedObjectContext?)
         */
        let track = NSManagedObject(entity: entity, insertInto: managedContext)
        
        /*
         With an NSManagedObject in hand, you set the name attribute using key-value coding. You must spell the KVC key (name in this case) exactly as it appears in your Data Model
         */
        var pts = [Array<Double>]()
        
        for track in trackInfo {
            let arr = [track.latitude, track.longitude]
            pts.append(arr)
        }
        
        track.setValue(pts, forKey: "points")
        track.setValue(distance, forKey: "distance")
        track.setValue(name, forKey: "name")
        track.setValue(duration, forKey: "duration")
        
        /*
         You commit your changes and save to disk by calling save on the managed object context. Note save can throw an error, which is why you call it using the try keyword within a do-catch block. Finally, insert the new managed object into the people array so it shows up when the table view reloads.
         */
        do {
            try managedContext.save()
            return true
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return false
        }
    }
    
    /*Load*/
    func loadTracks() -> [TrackInfo]? {
        /*Before you can do anything with Core Data, you need a managed object context. */
        let managedContext = CoreDataManager.shared.persistentContainer.viewContext
        
        /*As the name suggests, NSFetchRequest is the class responsible for fetching from Core Data.
         
         Initializing a fetch request with init(entityName:), fetches all objects of a particular entity.
         */
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Track")
        
        /*You hand the fetch request over to the managed object context to do the heavy lifting. fetch(_:) returns an array of managed objects meeting the criteria specified by the fetch request.*/
        
        do {
            var trackInfo = [TrackInfo]()
            let tracks = try managedContext.fetch(fetchRequest)
            
            for track in tracks {
                let dataPoint = track.value(forKey: "points") as! Array<Array<Any>>
                let distancePoint = track.value(forKey: "distance") as! Double
                let name = track.value(forKey: "name") as! String
                let duration = track.value(forKey: "duration") as! Double
                var track = [CLLocationCoordinate2D]()
                for point in dataPoint {
                    if let first = point.first as? Double, let last = point.last as? Double {
                        let location = CLLocationCoordinate2D(latitude: first, longitude: last)
                        track.append(location)
                    }
                }
                let trackData = TrackInfo(track: track, distance: distancePoint, name: name, time: duration)
                trackInfo.append(trackData)
            }
            return trackInfo
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    /*Remove*/
    func removeTrack(trackInfo: TrackTableCellViewModel) -> Bool {
        let managedContext = CoreDataManager.shared.persistentContainer.viewContext
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Track")
        if let result = try? managedContext.fetch(request) {
            for obj in result {
                if let trackName = (obj as! Track).name {
                    if trackName == trackInfo.nameText {
                        managedContext.delete(obj as! NSManagedObject)
                        break
                    }
                }
            }
        }
        do {
            try managedContext.save()
            return true
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return false
        }
    }
}

