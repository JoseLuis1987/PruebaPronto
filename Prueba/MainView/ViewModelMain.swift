//
//  ViewModelMain.swift
//  Prueba
//
//  Created by IOS DEVELOPER on 10/14/19.
//  Copyright © 2019 Pronto. All rights reserved.
//

import Foundation
import ObjectMapper
import MapKit
struct MiViewModel {
    var sesion: URLSession = URLSession(configuration: .default)
    var onErrorHandling : ((ErrorResult?) -> Void)?
    weak var serviceConsultRestaurants: ServiceConsultaRestaurants?
    weak var dataSource : GenericDataSource<DatosToSetTable>?
    var responseResultSearch: Dynamic<ConsultaRestaurantsResponse?> = Dynamic<ConsultaRestaurantsResponse?>(nil)
    init(serviceConsultaRestaurant: ServiceConsultaRestaurantsProtocol = ServiceConsultaRestaurants.shared, dataSource : GenericDataSource<DatosToSetTable>?) {
        self.serviceConsultRestaurants = (serviceConsultaRestaurant as! ServiceConsultaRestaurants)
        self.dataSource = dataSource
    }
    func fetchData(textToSearch:String , current: CLLocationCoordinate2D){
        /*if let response = Mapper<ConsultaRestaurantsResponse>().map(JSON: MasterPresenter().dataJsonLocal(nameFile: "responserestaurants")) {
            responseResultSearch.value = response
            var dataRestNames:[DatosToSetTable] = [DatosToSetTable]()
            if response.results!.count > 0 {
                for data in response.results! {
                    dataRestNames.append(DatosToSetTable(name: data.name!))
                }
            }
            dataSource?.data.value = dataRestNames
        }*/
       
        guard let serviceConsultRestaurants = serviceConsultRestaurants else {
                   onErrorHandling?(ErrorResult.custom(string: "Missing service"))
                   return
               }
        serviceConsultRestaurants.fetchConsultaRestaurants(datosTo: String(format: "location=%f,%f&radius=1500&type=restaurant&keyword=%@&key=AIzaSyB00BsWrcR6n1KBk8ap9_Zqm2GPYBtJbdk",current.latitude,current.longitude ,textToSearch) ) { (result) in
            switch result {
            case .success(let resultRestaurant):
                self.responseResultSearch.value = resultRestaurant
            case .failure(let error):
            self.onErrorHandling?(.custom(string: "Error al obtener los datos" ))
            }
        }
    }
 
}
