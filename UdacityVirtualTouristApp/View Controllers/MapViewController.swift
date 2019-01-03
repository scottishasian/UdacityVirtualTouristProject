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
    
    var pinPlacement : MKPointAnnotation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    //Pin placement methods
    //https://stackoverflow.com/questions/14580269/get-tapped-coordinates-with-iphone-mapkit
    
    @IBAction func addAPin(_ sender: UILongPressGestureRecognizer) {
        
        let newLocation = sender.location(in: mapView)
        let coordinates = mapView.convert(newLocation, toCoordinateFrom: mapView)
        
        if sender.state == .began {
            
            pinPlacement = MKPointAnnotation()
            pinPlacement!.coordinate = coordinates
            
            mapView.addAnnotation(pinPlacement!)
            print("long prss, \(coordinates.latitude), \(coordinates.longitude)")
        }
       
    }
    

}
