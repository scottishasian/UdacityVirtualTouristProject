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

extension UIViewController {
    
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
    
    func savePin() {
        do {
            try DataManager.sharedInstance().savePinContext()
        } catch {
            showErrorInfo(withTitle: "Saving Error", withMessage: "\(error)")
        }
    }
}






