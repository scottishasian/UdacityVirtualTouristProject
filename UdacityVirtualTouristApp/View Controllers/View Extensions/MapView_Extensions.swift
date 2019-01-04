//
//  MapView_Extensions.swift
//  UdacityVirtualTouristApp
//
//  Created by Kynan Song on 04/01/2019.
//  Copyright © 2019 Kynan Song. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension MapViewController {
    
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            self.showErrorInfo(withMessage: "No link defined.")
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Pin tapped")
    }
}
