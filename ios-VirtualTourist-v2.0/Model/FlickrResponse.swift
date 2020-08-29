//
//  FlickrResponse.swift
//  ios-VirtualTourist
//
//  Created by Abdullah Khayat on 8/27/20.
//  Copyright © 2020 Abdullah Khayat. All rights reserved.
//

import Foundation

// request
// https://api.flickr.com/services/rest?method=flickr.photos.search&api_key=914f9abe1b3e5c5f260ebd9f1ca43f5d&lat=2.0&long=2.0&accuracy=11&media=photos
/*
 base URL: https://api.flickr.com/services/rest
 api_key: 914f9abe1b3e5c5f260ebd9f1ca43f5d
 secret: 0224f9032da44b62
 method: flickr.photos.search
 format: json
 media: photos
 lat: double
 lon: double
 page: 1, 2, 3, ...
 per_page: 30
 accuracy: 11
 nojsoncallback: 1
 */

// response
/*
 {"photos":
 {"page":1,"pages":28,"perpage":1,"total":"28","photo":[{"id":"16918534776","owner":"49359444@N02","secret":"8a176d5c8d","server":"7591","farm":8,"title":"S\u00e9jour au Vietnam","ispublic":1,"isfriend":0,"isfamily":0}
     ]},"stat":"ok"}
 */

// Photo url
/*
 https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg
     or
 https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}_[mstzb].jpg
     or
 https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{o-secret}_o.(jpg|gif|png)
 Size Suffixes: (mstzb) q: large square 150x150
 */

struct FlickrQueryParams: Codable {
    
    // request parameters
    let apiKey = "914f9abe1b3e5c5f260ebd9f1ca43f5d"
    let secret = "0224f9032da44b62"
    let method = "flickr.photos.search"
    let format = "json"
    let media = "photos"
    let noJSONCallBack = 1
    var latitude = 1.0
    var longitude = 1.0
    var page = 1
    let perPage = 20
    let accuracy = 11
    
    enum CodingKeys: String, CodingKey {
        case apiKey = "api_key"
        case secret
        case method
        case format
        case media
        case noJSONCallBack = "nojsoncallback"
        case latitude = "lat"
        case longitude = "lon"
        case page
        case perPage = "per_page"
        case accuracy
    }
    
    //let query = baseURL + apiKey + secret + method + format + media + lat + lon + page + perPage + accuracy + noJSONCallBack
}

struct FlickrResponse: Codable {
    let photos: FlickrImages
    let stat: String
}

struct FlickrImages: Codable {
    let page: Int
    let pages: Int
    let perPage: Int
    let total: String
    let photo: [FlickrImage]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "perpage"
        case total
        case photo
    }
}

struct FlickrImage: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let isPublic: Int
    let isFriend: Int
    let isFamily: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
    }
}

struct ImageURL {
    
    let farm: Int
    let server: String
    let id: String
    let secret: String
    let size: String
    var url: NSURL {
        let url = NSURLComponents()
        url.scheme = "https"
        url.host = "farm\(farm).staticflickr.com"
        url.path = "/\(server)/\(id)_\(secret)_\(size).jpg"
        return NSURL(string: url.string!)!
    }
}
