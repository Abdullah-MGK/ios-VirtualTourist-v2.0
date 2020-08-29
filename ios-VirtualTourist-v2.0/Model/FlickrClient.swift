//
//  FlickrClient.swift
//  ios-VirtualTourist
//
//  Created by Abdullah Khayat on 8/27/20.
//  Copyright © 2020 Abdullah Khayat. All rights reserved.
//

import Foundation
import Alamofire

class FlickrClient {
    
    // MARK:- SEND images reuqest AND GET images URLS
    static func requestImages(latitude: Double, longitude: Double, page: Int = 1, completion: (([NSURL], Int) -> Void)? = nil) {
        
        let baseURL = "https://api.flickr.com/services/rest"
        let queryParams = FlickrQueryParams(latitude: latitude, longitude: longitude, page: page)
        print("page\(page)")
        AF.request(baseURL, method: .get, parameters: queryParams).validate().responseDecodable(of: FlickrResponse.self) { response in
            
            guard let data = response.value else { print("ERROR IN DATA"); return }
            
            let urls = getImagesURLS(flickrImages: data.photos.photo)
            let maxPages = data.photos.pages
            print("in request ", urls.count)
            
            completion?(urls, maxPages)
        }
    }
    
    // basic request
    /*
    static func basicRequestImages(latitude: Double, longitude: Double, page: Int = 1) {
        
        /*
        // make 2 static structs one for keys and the other for values of the URL
        let queryParams = [key: value] as [String: Any]
        let url = URLComponents(string: "https://api.flickr.com/services/rest")
        var components = URLComponents()
        // use a static struct to set those
        components.scheme
        components.host
        components.path
        components.queryItems = [URLQueryItem]()
        for (key, value) in queryParams {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        */
        
        /*
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, repsonse, error) in
                guard let data = data else { print("----- Error in data -----"); return }
         
                let decoder = JSONDecoder()
                do {
                    let responseObject = try decoder.decode(FlickrResponse.self, from: data)
                }
                catch {
                    print("Error")
                }
         
        }
        task.resume()
        */
    }
     */
    
    // MARK:- GET an array of URLS from downlaoded image data
    private static func getImagesURLS(flickrImages: [FlickrImage]) -> [NSURL] {
        
        var urls = [NSURL]()
        
        for flickrImage in flickrImages {
            // https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}_[mstzb].jpg
            
            let imageURL = ImageURL(farm: flickrImage.farm, server: flickrImage.server, id: flickrImage.id, secret: flickrImage.secret, size: "q")
            
            urls.append(imageURL.url)
        }
        
        return urls
    }
    
    static func getLargeImageURL(url: NSURL) -> NSURL {
        let oldPathComponent = url.lastPathComponent!
        let start = oldPathComponent.index(oldPathComponent.endIndex, offsetBy: -5)
        let end = oldPathComponent.endIndex
        let newPathComponent = oldPathComponent.replacingCharacters(in: start..<end, with: "b.jpg")
        let newURL = (url.deletingLastPathComponent)?.appendingPathComponent(newPathComponent)
        
        return NSURL(string: newURL!.absoluteString)!
    }
    
}
