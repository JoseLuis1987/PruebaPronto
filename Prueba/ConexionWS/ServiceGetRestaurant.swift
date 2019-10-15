//
//  ServiceGetRestaurant.swift
//  Prueba
//
//  Created by IOS DEVELOPER on 10/14/19.
//  Copyright © 2019 Pronto. All rights reserved.
//

import Foundation
import ObjectMapper

protocol ServiceConsultaRestaurantsProtocol : class {
    func fetchConsultaRestaurants(datosTo: String , _ completion: @escaping ((Result<ConsultaRestaurantsResponse, ErrorResult>) -> Void))
}
final class ServiceConsultaRestaurants : MasterPresenter, ServiceConsultaRestaurantsProtocol {
    static let shared = ServiceConsultaRestaurants()
    func fetchConsultaRestaurants(datosTo: String , _ completion: @escaping ((Result<ConsultaRestaurantsResponse, ErrorResult>) -> Void)) {

        MasterPresenter().callRequestAny(urlRequest:UtilRequest().creaRequesBase(urlService: datosTo, bodyRequest: ["":""], operacion: "") ){ (success, fail , data, codeError) in
            print(codeError)
            if success{
                if let strDatos = String(data: data, encoding: String.Encoding.utf8), let responseDataRest = Mapper<ConsultaRestaurantsResponse>().map(JSONString: strDatos){
                    print(strDatos)
                        completion(.success(responseDataRest))
                }else{
                    completion(.failure(.custom(string: "No se pudo mapear!!!")))
                }
            }else{
                if let responseDataRest = Mapper<ConsultaRestaurantsResponse>().map(JSON: MasterPresenter().dataJsonLocal(nameFile: "responserestaurants")) {
                    completion(.success(responseDataRest))
                }
                //completion(.failure(.network(string: fail)))
            }
        }
      }
}
