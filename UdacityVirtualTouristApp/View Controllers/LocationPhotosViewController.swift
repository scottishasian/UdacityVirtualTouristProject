//
//  LocationPhotosViewController.swift
//  UdacityVirtualTouristApp
//
//  Created by Kynan Song on 04/01/2019.
//  Copyright © 2019 Kynan Song. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class LocationPhotosViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationCollectionView: UICollectionView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var collectionViewFlow: UICollectionViewFlowLayout!
    
    var selectedIndexes = [IndexPath]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    var totalPages: Int? = nil
    
    var tappedPin: Pin?
    var fetchResultsController: NSFetchedResultsController<Photo>!
    var loadedPages: Int? =  nil

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        //display clicked pin location.
        guard let selectedPin = tappedPin else {
            return
        }
        showSelectedPinLocation(selectedPin)
        callFetchedResults(selectedPin)
        
        //show photos of the location.
        if let locationPhotos = selectedPin.photos, locationPhotos.count == 0 {
            fetchPhotosFromFlickr(selectedPin)
        }
        
    }
    
    //As the view is a modal, dismiss not back button.
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func callFetchedResults(_ selectedPin: Pin) {
        
        let fetchRequest = NSFetchRequest<Photo>(entityName: Photo.photoName)
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin == %@", argumentArray: [selectedPin])
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataManager.sharedInstance().pinContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultsController.delegate = self as? NSFetchedResultsControllerDelegate
        
        var error: NSError?
        do {
            try fetchResultsController.performFetch()
        } catch let fetchError as NSError {
            error = fetchError
        }
        
        if let error = error {
            print("\(error)")
        }
    }
    
    func fetchPhotosFromFlickr(_ selectedPin: Pin) {
        
        let latitude = Double(selectedPin.latitude!)!
        let longitude = Double(selectedPin.longitude!)!
        
        //Need a loading indicator to tell the user that photos are being loaded. Useful in cases of slow connections for user exp.
        loadingSpinner.startAnimating()
        
        DataClient.sharedInstance().searchByLatLon(latitude: latitude, longitude: longitude, totalPages: loadedPages) {
            (parsedPhotos, error) in
            self.performUIUpdatesOnMain {
                self.loadingSpinner.stopAnimating()
            }
            if let parsedPhotos = parsedPhotos {
                self.loadedPages = parsedPhotos.photosData.pages
                let photoCount = parsedPhotos.photosData.photo.count
                print("Photos downloaded = \(photoCount)")
                self.storeDownloadedPhotos(parsedPhotos.photosData.photo, selectedPin: selectedPin)
                if photoCount == 0 {
                    print("No photos for this location")
                }
            } else if let error = error {
                print("\(error.localizedDescription)")
                self.showErrorInfo(withTitle: "Error", withMessage: error.localizedDescription)
            }
        }
    }
    
    func storeDownloadedPhotos(_ photos: [PhotoParser], selectedPin: Pin) {
        
        for photo in photos {
            performUIUpdatesOnMain {
                if let photoURL = photo.url {
                    _ = Photo(title: photo.title, imageURL: photoURL, selectedPin: selectedPin, context: DataManager.sharedInstance().pinContext)
                    self.saveData()
                }
            }
        }
    }
    
    func loadFetchedPhotos(using selectedPin: Pin) -> [Photo]? {
        let predicate = NSPredicate(format: "pin == %@", argumentArray: [selectedPin])
        var photosArray: [Photo]?
        
        do {
            try photosArray = DataManager.sharedInstance().fetchRequestForLocationPhotos(predicate,entityName: Photo.photoName)
        } catch {
            fatalError("\(error)")
            showErrorInfo(withTitle: "Error", withMessage: "Error loading saved photos \(error)")
        }
        return photosArray
    }
    
    func showSelectedPinLocation(_ selectedPin: Pin) {
        
        let latitude = Double(selectedPin.latitude!)!
        let longitude = Double(selectedPin.longitude!)!
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let mapAnnotiation = MKPointAnnotation()
        mapAnnotiation.coordinate = coordinates
        
        //Remove old pins then add new ones, as this view should only have a singe pin.
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(mapAnnotiation)
        //Zoom to location.
        mapView.setCenter(coordinates, animated: true)
    }
    
    func updateCollectionFlow(_ collectionViewSize: CGSize) {
        
        let landscapeOrientation = collectionViewSize.width > collectionViewSize.height
        
        //Spacing and item layout if landscape orientation is true.
        let spacing: CGFloat = landscapeOrientation ? 5 : 3
        let collectionItems: CGFloat = landscapeOrientation ? 2 : 3
        
        let dimensions = (collectionViewSize.width - ((collectionItems + 1) * spacing)) / collectionItems
        
        collectionViewFlow?.minimumInteritemSpacing = spacing
        collectionViewFlow?.minimumLineSpacing = spacing
        collectionViewFlow?.itemSize = CGSize(width: dimensions, height: dimensions)
        collectionViewFlow?.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }
    
    
    

    
}
