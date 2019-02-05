//
//  CollectionViewCell.swift
//  VirtualTourist
//
//  Created by Raghad Almatrodi on 1/29/19.
//  Copyright © 2019 raghad almatrodi. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    static let identifier = "CollectionViewCell"
    
    var imageUrl: String = ""
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
}
