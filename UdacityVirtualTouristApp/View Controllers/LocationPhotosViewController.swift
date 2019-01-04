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
    @IBOutlet weak var LocationCollectionView: UICollectionView!
    var tappedPin: Pin?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //As the view is a modal, dismiss not back button.
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    
}
