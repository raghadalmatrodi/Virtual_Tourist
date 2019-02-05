//
//  PhotosParser.swift
//  VirtualTourist
//
//  Created by Raghad Almatrodi on 1/31/19.
//  Copyright © 2019 raghad almatrodi. All rights reserved.
//



import Foundation

struct PhotosParser: Codable {
    let photos: PhotosS
}

struct PhotosS: Codable {
    let pages: Int
    let photo: [PhotoParser]
}

struct PhotoParser: Codable {
    
    let url: String?
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case url = "url_n"
        case title
    }
}
