//
//  Extensions.swift
//  UdacityVirtualTouristApp
//
//  Created by Kynan Song on 03/01/2019.
//  Copyright © 2019 Kynan Song. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension ViewController {
    
    func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
    
    func showErrorInfo(withTitle: String = "Info", withMessage: String, action: (() -> Void)? = nil) {
        performUIUpdatesOnMain {
            let ac = UIAlertController(title: withTitle, message: withMessage, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alertAction) in
                action?()
            }))
            self.present(ac, animated: true)
        }
    }
}
    

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
}



