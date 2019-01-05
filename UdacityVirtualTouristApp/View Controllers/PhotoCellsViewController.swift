//
//  PhotoCellsViewController.swift
//  UdacityVirtualTouristApp
//
//  Created by Kynan Song on 04/01/2019.
//  Copyright © 2019 Kynan Song. All rights reserved.
//

import UIKit

class PhotoCellsViewController: UICollectionViewCell {
    
    static let cellIdentifier = "PhotoCell"
    
    var imageURL: String = ""
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
}
