//
//  RestaurantPin.swift
//  Prueba
//
//  Created by IOS DEVELOPER on 10/14/19.
//  Copyright © 2019 Pronto. All rights reserved.
//

import Foundation
import MapKit

class RestaurantPin : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var iconName: String?
    var index: Int?
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String , iconName:String , index:Int) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.index = index
    }
}
