//
//  MapViewController.swift
//  UdacityVirtualTouristApp
//
//  Created by Kynan Song on 03/01/2019.
//  Copyright © 2019 Kynan Song. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deleteInstructions: UILabel!
    
    //var dataManager: DataManager!
    
    var pinPlacement : MKPointAnnotation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        //Adding a means to delete pins - existing edit button.
        navigationItem.rightBarButtonItem = editButtonItem
        //Edit button state will determine if the instructions are shown or not.
        deleteInstructions.isHidden = true
        
        if let savedPins = loadSavedPins() {
            displaySavedPins(savedPins)
        }
    }
    
    //Pin placement methods
    //https://stackoverflow.com/questions/14580269/get-tapped-coordinates-with-iphone-mapkit
    //https://www.youtube.com/watch?v=pt_hbo85OkI
    
    @IBAction func addAPin(_ sender: UILongPressGestureRecognizer) {
        
        let newLocation = sender.location(in: mapView)
        let coordinates = mapView.convert(newLocation, toCoordinateFrom: mapView)
        
        if sender.state == .began {
            
            pinPlacement = MKPointAnnotation()
            pinPlacement!.coordinate = coordinates
            pinPlacement?.title = ("\(coordinates.latitude), \(coordinates.longitude)")
            
            mapView.addAnnotation(pinPlacement!)
            print("long press test, \(coordinates.latitude), \(coordinates.longitude)")
            
        } else if sender.state == .changed {
            pinPlacement?.coordinate = coordinates
            
        } else if sender.state == .ended {
            
            _ = Pin(latitude: String(pinPlacement!.coordinate.latitude),
                    longitude: String(pinPlacement!.coordinate.longitude),
                    context: DataManager.sharedInstance().pinContext)
            
            saveData()
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        deleteInstructions.isHidden = !editing
    }
    
    //Segue performed when pin is tapped.
    //https://stackoverflow.com/questions/33053832/swift-perform-segue-from-map-annotation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LocationPhotos" {
            guard let selectedPin = sender as? Pin else {
                return
            }
            let segueController = segue.destination as! LocationPhotosViewController
            segueController.tappedPin = selectedPin
        }
    }
    
    //https://stackoverflow.com/questions/2026649/nspredicate-dont-work-with-double-values-f
    func loadPinLocation(latitude: String, longitude: String) -> Pin? {
        let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", latitude, longitude)
        var loadedPin: Pin?
        
        do {
            try loadedPin = DataManager.sharedInstance().fetchRequestForPin(predicate, entityName: Pin.pinName)
        } catch {
            fatalError("\(error)")
        }
        return loadedPin
    }
    
    func loadSavedPins() -> [Pin]? {
        var savedPins: [Pin]?
        do {
            try savedPins = DataManager.sharedInstance().fetchRequestForSavedPins(entityName: Pin.pinName)
        } catch {
            fatalError("\(error)")
        }
        return savedPins
    }
    
    func displaySavedPins(_ savedPins: [Pin]) {
        for pin in savedPins where pin.latitude != nil && pin.longitude != nil {
            let mapAnnotation = MKPointAnnotation()
            let latitude = Double(pin.latitude!)!
            let longitude = Double(pin.longitude!)!
            mapAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            mapView.addAnnotation(mapAnnotation)
        }
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
}
