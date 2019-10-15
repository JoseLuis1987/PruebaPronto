//
//  MasterPresenter.swift
//  SkyMobile
//
//  Created by IOS DEVELOPER on 11/01/18.
//  Copyright © 2018 IOS DEVELOPER. All rights reserved.
import UIKit
import QuartzCore
import ObjectMapper
import Alamofire
public typealias JsonObject = [String: Any]
public typealias JsonArray = [[String: Any]]
open class MyServerTrustPolicyManager: ServerTrustPolicyManager {
    open override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
        return ServerTrustPolicy.disableEvaluation
    }
}
class Ping {
    //Enviar ruta completa: https://www.gooogle.com
    static func toHost(_ fullURL: String) -> Bool{
        let url = URL(string: fullURL)
        let uReq = URLRequest(url: url!)
        let (_, response, _) = URLSession.shared.synchronousDataTask(urlrequest: uReq)
        let httpR = response as? HTTPURLResponse
        //No importa qué responda el servidor, que haya respondido es suficiente
        if httpR != nil {
            return true
        }
        return false
    }
}
extension URLSession {
    func synchronousDataTask(urlrequest: URLRequest) -> (data: Data?, response: URLResponse?, error: Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        let semaphore = DispatchSemaphore(value: 0)
        let dataTask = self.dataTask(with: urlrequest) {
            data = $0
            response = $1
            error = $2
            semaphore.signal()
        }
        dataTask.resume()
        _ = semaphore.wait(timeout: .now() + .seconds(2))
        return (data, response, error)
    }
}
extension URLResponse {
    
    func getStatusCode() -> Int? {
        if let httpResponse = self as? HTTPURLResponse {
            return httpResponse.statusCode
        }
        return nil
    }
}
open class MasterPresenter {
    public static let manager: Alamofire.SessionManager = {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "https://maps.googleapis.com" : .disableEvaluation
        ]
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        configuration.urlCredentialStorage = nil
       // configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.requestCachePolicy = .useProtocolCachePolicy
        configuration.timeoutIntervalForRequest = 60.0
        return Alamofire.SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: MyServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    }()
    
    func errorFromService(with  message: String?, code: Int)->NSError{
        var userInfo: [AnyHashable : Any] =  [:]
        
        if message == nil || message == ""{
            userInfo = [
                NSLocalizedDescriptionKey :  NSLocalizedString("Error", value: "No hay conexión a internet.", comment: "") ,
                NSLocalizedFailureReasonErrorKey : NSLocalizedString("Error", value: "No hay conexión a internet.", comment: "")
            ]
        }else{
            userInfo = [
                NSLocalizedDescriptionKey :  NSLocalizedString("Error", value: message!, comment: "") ,
                NSLocalizedFailureReasonErrorKey : NSLocalizedString("Error", value: message!, comment: "")
            ]
        }
        let err = NSError(domain: "skyAppResponseErrorDomain", code: code, userInfo: userInfo as? [String : Any])
        return err
    }
    private func conexionInternet() -> Bool{
        return Ping.toHost("https://www.google.com")
    }
    private func tiempoExcedido(_ estatusHTTP : Int) -> Bool{
        let codigosTimeOut : [Int] = [408]
        
        if let aux = codigosTimeOut.index(of: estatusHTTP), aux >= 0 {
            return true;
        }
        return false;
    }
    
}

extension MasterPresenter {
    func callRequestAny(urlRequest: URLRequest, completion: @escaping (_ success: Bool , _ fail: String, _ data: Data, _ errorCode:Int ) -> ()) {
        MasterPresenter.manager.request(urlRequest)
            .responseData { (response) in
                var codeError = -1
                if let code = response.response?.statusCode{
                    codeError = code
                }
                switch response.result{
                case .success (let value):
                    if response.response?.statusCode == 200{
                        completion(true, "Exitoso", value, codeError)
                    }else {
                        let comWWW = self.conexionInternet()
                        //Ocurrió un timeout
                        if(self.tiempoExcedido(response.response!.statusCode)){
                           // estatusConexion = .TimeOut;
                            completion(false, "TimeOut", Data.init(), codeError)
                        }
                            //Cualquier otro caso
                        else {
                            completion(false, "Reintentar", Data.init(), codeError)
                            //estatusConexion = .Reintentar;
                        }
                    }
                    break
                case .failure(let error):
                    print("response.response?.errror \( error)")
                    completion(false, error.localizedDescription, Data.init(), codeError)
                    break
            }
        }
    }
    
    func dataJsonLocal(nameFile: String) -> JsonObject {
        let url = Bundle.main.url(forResource: nameFile, withExtension: "json")!
        do {
            let jsonData = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: jsonData)
            return json as! JsonObject
        }catch {
        }
        return ["":""]
    }
}

open class ConectionPresenter: MasterPresenter {
    var sesion: URLSession = URLSession(configuration: .default)
    func isInternetConnectedToURL( urlPin: String , completion: @escaping (_ success: Bool)  -> ()) {
        guard let url = URL(string: urlPin) else {
            print("Error: cannot create URL")
            return
        }
            let urlRequestTest = URLRequest(url: url)
        print("URL To PING --< \(url)")
        Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.requestTimeout), userInfo: nil, repeats: false)
        sesion = URLSession(configuration: URLSessionConfiguration.default)
        let task = sesion.dataTask(with: urlRequestTest, completionHandler:{(data, response, error) -> Void in
//            print(response?.getStatusCode())
//            print(error?.localizedDescription)
            if response?.getStatusCode() == 200 {
                completion(true)
            }else{
                completion(false)
            }
        })
        task.resume()
    }
    @objc func requestTimeout() {
        print("requestTimeout")
        sesion.invalidateAndCancel()
    }
}

open class CheckConnection: UIViewController {
    @objc func validateConection(urlTest: String, completion: @escaping (_ success: Bool) -> ()){
        ConectionPresenter().isInternetConnectedToURL(urlPin: urlTest) { (result) in
            if result {
                completion(true)
            }else{
                completion(false)
            }
        }
    }
}
