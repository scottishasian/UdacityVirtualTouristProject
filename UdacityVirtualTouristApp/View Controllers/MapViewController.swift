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
    
    var dataManager: DataManager!
    
    var pinPlacement : MKPointAnnotation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
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
            _ = Pin(context: DataManager.sharedInstance().pinContext)
            savePin()
        }
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
}
