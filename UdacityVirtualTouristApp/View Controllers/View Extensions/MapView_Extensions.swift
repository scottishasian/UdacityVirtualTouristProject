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

//http://swiftdeveloperblog.com/code-examples/drop-a-mkpointannotation-pin-on-a-mapview-at-users-current-location/
//https://www.raywenderlich.com/548-mapkit-tutorial-getting-started
//https://stackoverflow.com/questions/37247220/how-can-i-perform-an-action-when-i-tap-on-a-pin-from-mapkit-ios9-swift-2

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
//        if control == view.rightCalloutAccessoryView {
//            //If segue is placed here, then the user has to tap on the Callout Accessory.
//            performSegue(withIdentifier: "LocationPhotos", sender: self)
//        } else {
//            self.showErrorInfo(withMessage: "No links available with location.")
//        }
        self.showErrorInfo(withMessage: "No links available with location.")
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //If segue is placed here, then the user can tap on the pin to proceed.
        print("Pin tapped")
        
        guard let pinPlacement = view.annotation else {
            return
        }
        
        mapView.deselectAnnotation(pinPlacement, animated: true)
        let latitude = String(pinPlacement.coordinate.latitude)
        let longitude = String(pinPlacement.coordinate.longitude)
        
        if let pin = loadPinLocation(latitude: latitude, longitude: longitude) {
            if isEditing {
                print("Is editing")
                mapView.removeAnnotation(pinPlacement)
                DataManager.sharedInstance().pinContext.delete(pin)
                //Need to save the data after deletion or pins will re-appear.
                saveData()
                return
            }
            performSegue(withIdentifier: "LocationPhotos", sender: pin)
        }
    }
}
