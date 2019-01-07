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

extension LocationPhotosViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sectionInformation = self.fetchResultsController.sections?[section] {
            return sectionInformation.numberOfObjects
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCellsViewController.cellIdentifier, for: indexPath) as! PhotoCellsViewController
        photoCell.cellImage.image = nil
        
        return photoCell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = fetchResultsController.object(at: indexPath)
        DataManager.sharedInstance().pinContext.delete(photoToDelete)
        saveData()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = fetchResultsController.object(at: indexPath)
        let photoCell = cell as! PhotoCellsViewController
        photoCell.imageURL = photo.imageURL!
        configureImageLoading(using: photoCell, photo: photo, collectionView: collectionView, index: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying: UICollectionViewCell, forItemAt: IndexPath) {
        
        if collectionView.cellForItem(at: forItemAt) == nil {
            return
        }
        
        let photo = fetchResultsController.object(at: forItemAt)
        if let imageUrl = photo.imageURL {
            DataClient.sharedInstance().cancelDownloadInProgress(imageUrl)
        }
    }

    private func configureImageLoading(using cell: PhotoCellsViewController, photo: Photo, collectionView: UICollectionView, index: IndexPath) {
        if let imageData = photo.image {
            cell.cellImage.image = UIImage(data: Data(referencing: imageData as NSData))
            cell.loadingSpinner.stopAnimating()
        } else {
            if let imageUrl = photo.imageURL {
                DataClient.sharedInstance().downloadImage(imagePath: imageUrl, completionHandler: { (data, error) in
                    if let _ = error {
                        self.performUIUpdatesOnMain {
                            cell.loadingSpinner.stopAnimating()
                            self.errorForImageUrl(imageUrl)
                        }
                        return
                    } else if let data = data {
                        self.performUIUpdatesOnMain {
                            
                            if let currentCell = collectionView.cellForItem(at: index) as? PhotoCellsViewController {
                                if currentCell.imageURL == imageUrl {
                                    currentCell.cellImage.image = UIImage(data: data)
                                    cell.loadingSpinner.stopAnimating()
                                }
                            }
                            photo.image = NSData(data: data) as Data
                            DispatchQueue.global(qos: .background).async {
                                self.saveData()
                            }
                        }
                    }
                })
            }
        }
    }
    
    private func errorForImageUrl(_ imageUrl: String) {
        self.showErrorInfo(withTitle: "Error", withMessage: "Error while fetching image for URL: \(imageUrl)")
    }
    
}

extension LocationPhotosViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    //Called when the fetchedResultContoller has been notified there are changes. Should updated affected rows.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            case .insert: insertedIndexPaths.append(newIndexPath!)
                break
            case .delete: deletedIndexPaths.append(indexPath!)
                break
            case .update: updatedIndexPaths.append(indexPath!)
                break
            case .move:
                fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). .move not possible")
                break
        }
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
