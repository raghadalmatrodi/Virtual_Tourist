//
//  Connect.swift
//  VirtualTourist
//
//  Created by Raghad Almatrodi on 2/4/19.
//  Copyright © 2019 raghad almatrodi. All rights reserved.
//

import UIKit
import CoreData
class Connect{
    
    
    var session = URLSession.shared
    private var tasks: [String: URLSessionDataTask] = [:]
    
    class func shared() -> Connect {
        struct Singleton {
            static var shared = Connect()
        }
        return Singleton.shared
    }
    
    func searchBy(latitude: Double, longitude: Double, totalPages: Int?, completion: @escaping (_ result: PhotosParser?, _ error: Error?) -> Void) {
        var page: Int {
            if let totalPages = totalPages {
                let page = min(totalPages, 4000/Connect.FlickrParameterValues.PhotosPerPage)
                return Int(arc4random_uniform(UInt32(page)) + 1)
            }
            return 1
        }
        let bbox = stringBbox(latitude: latitude, longitude: longitude)
        
        let parameters = [
            Connect.FlickrParameterKeys.Method           : Connect.FlickrParameterValues.SearchMethod
            , Connect.FlickrParameterKeys.APIKey         : Connect.FlickrParameterValues.APIKey
            , Connect.FlickrParameterKeys.Format         : Connect.FlickrParameterValues.ResponseFormat
            , Connect.FlickrParameterKeys.Extras         : Connect.FlickrParameterValues.MediumURL
            , Connect.FlickrParameterKeys.NoJSONCallback : Connect.FlickrParameterValues.DisableJSONCallback
            , Connect.FlickrParameterKeys.SafeSearch     : Connect.FlickrParameterValues.UseSafeSearch
            , Connect.FlickrParameterKeys.BoundingBox    : bbox
            , Connect.FlickrParameterKeys.PhotosPerPage  : "\(Connect.FlickrParameterValues.PhotosPerPage)"
            , Connect.FlickrParameterKeys.Page           : "\(page)"
        ]
        
        _ = taskForGETMethod(parameters: parameters) { (data, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey : "Could not retrieve data."]
                completion(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
                return
            }
            
            do {
                let photosParser = try JSONDecoder().decode(PhotosParser.self, from: data)
                completion(photosParser, nil)
            } catch {
                print("\(#function) error: \(error)")
                completion(nil, error)
            }
        }
    }
    
    func downloadImage(imageUrl: String, result: @escaping (_ result: Data?, _ error: NSError?) -> Void) {
        guard let url = URL(string: imageUrl) else {
            return
        }
        let task = taskForGETMethod(nil, url, parameters: [:]) { (data, error) in
            result(data, error)
            self.tasks.removeValue(forKey: imageUrl)
        }
        
        if tasks[imageUrl] == nil {
            tasks[imageUrl] = task
        }
    }
    
    func cancelDownload(_ imageUrl: String) {
        tasks[imageUrl]?.cancel()
        
    }
    
    func stringBbox(latitude: Double, longitude: Double) -> String {
        let minimumLon = max(longitude - Connect.Flickr.SearchBBoxHalfWidth, Connect.Flickr.SearchLonRange.0)
        let minimumLat = max(latitude  - Connect.Flickr.SearchBBoxHalfHeight, Connect.Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + Connect.Flickr.SearchBBoxHalfWidth, Connect.Flickr.SearchLonRange.1)
        let maximumLat = min(latitude  + Connect.Flickr.SearchBBoxHalfHeight, Connect.Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    func taskForGETMethod(
        _ method               : String? = nil,
        _ customUrl            : URL? = nil,
        parameters             : [String: String],
        completionHandlerForGET: @escaping (_ result: Data?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        let request: NSMutableURLRequest!
        if let customUrl = customUrl {
            request = NSMutableURLRequest(url: customUrl)
        } else {
            request = NSMutableURLRequest(url: getUrl(parameters, withPathExtension: method))
        }
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            if let error = error {
                if (error as NSError).code == URLError.cancelled.rawValue {
                    completionHandlerForGET(nil, nil)
                } else {
                    sendError(error.localizedDescription)
                }
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode < 300 else {
                sendError("error connection")
                return
            }
            
            guard let data = data else {
                sendError("No data")
                return
            }
            
            completionHandlerForGET(data, nil)
            
        }
        
        task.resume()
        
        return task
    }
    private func getUrl(_ parameters: [String: String], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Connect.Flickr.APIScheme
        components.host = Connect.Flickr.APIHost
        components.path = Connect.Flickr.APIPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: value)
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
}

