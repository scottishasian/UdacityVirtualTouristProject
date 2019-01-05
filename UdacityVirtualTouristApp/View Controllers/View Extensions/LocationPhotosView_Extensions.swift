//
//  LocationPhotosView_Extensions.swift
//  UdacityVirtualTouristApp
//
//  Created by Kynan Song on 05/01/2019.
//  Copyright © 2019 Kynan Song. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

extension LocationPhotosViewController {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reusablePin = "pin"
        
        var placedPins = mapView.dequeueReusableAnnotationView(withIdentifier: reusablePin) as? MKPinAnnotationView
        
        if placedPins == nil {
            placedPins = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reusablePin)
            placedPins?.canShowCallout = true
            placedPins?.pinTintColor = .blue
            placedPins?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            placedPins?.annotation = annotation
        }
        
        return placedPins
    }
}

extension LocationPhotosViewController: NSFetchedResultsControllerDelegate {
    
    //Called when the fetchedResultContoller has been notified there are changes. Should updated affected rows.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            case .insert: insertedIndexPaths.append(newIndexPath!)
            case .delete: deletedIndexPaths.append(indexPath!)
            case .update: updatedIndexPaths.append(indexPath!)
            case .move:
                fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). .move not possible")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        locationCollectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.locationCollectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.locationCollectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.locationCollectionView.reloadItems(at: [indexPath])
            }
            
        }, completion: nil)
    }
    
}
