//
//  UtilsRequest.swift
//  Prueba
//
//  Created by IOS DEVELOPER on 10/14/19.
//  Copyright © 2019 Pronto. All rights reserved.
//

import Foundation

enum ErrorResult: Error {
    case network(string: String)
    case parser(string: String)
    case custom(string: String)
     func get() -> String {
        switch self {
        case .network(let red):
            return red
        case .parser(let par):
            return par
        case .custom(let custo):
            return custo
        }
    }
}

open class UtilRequest {
    func creaRequesBase(urlService:String, bodyRequest: [String: Any], operacion:String, params:[String:Any]? = nil, origen:String? = nil ) -> URLRequest {
        do {
            let urlString:String = "\("https://maps.googleapis.com/maps/api/place/nearbysearch/json?")\(urlService)"
             //let urlString:String = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=19.395951,-99.1789056&radius=1500&type=restaurant&keyword=%@&key=AIzaSyB00BsWrcR6n1KBk8ap9_Zqm2GPYBtJbdk"
            print("\(urlString)")
            var request = URLRequest(url: URL(string: urlString)!)
            request.httpMethod = "POST"
            return request
        } catch {
            print("JSON serialization failed: ", error)
        }
        return URLRequest.init(url: URL.init(string: "")!)
    }
}
