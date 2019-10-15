//
//  ConsultaRestaurantsResponse.swift
//  Prueba
//
//  Created by Pronto on 10/14/19.
//  Copyright © 2019 Pronto. All rights reserved.
//

import Foundation
import ObjectMapper

class ConsultaRestaurantsResponse: Mappable {
    var results: [RestDetail]?
    var statusRes: String?
    required init?(map: Map) {
    }
    func mapping(map: Map) {
        self.results <- map["results"]
        self.statusRes <- map["status"]
    }
}

class RestDetail: Mappable {
    var latitude: Double?
    var longitude: Double?
    var icon : String?
    var name : String?
    var vicinity : String?

    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
    self.latitude <- map["geometry.location.lat"]
    self.longitude <- map["geometry.location.lng"]
    self.icon <- map["icon"]
    self.name <- map["name"]
    self.vicinity <- map["vicinity"]
    }
}
