//
//  ApiServices.swift
//  KashApp
//
//  Created by Apple on 23/02/2018.
//  Copyright © 2018 Senarios. All rights reserved.
//

import Foundation

import Alamofire

class ApiServices{
    
    func getRequest (serviceName :String, success: @escaping (_ data:[String:AnyObject]) -> Void, failure: @escaping (_ data:[String:AnyObject]) -> Void){
        
        print(serviceName)
  //      var param = [String:String]()

        Alamofire.request(serviceName, method: .get, parameters: nil, encoding: JSONEncoding.default, headers:nil)
            .responseJSON { response in

            if response.result.value != nil{
                print(response)
                let data = response.result.value as! [String : AnyObject]
                print("Success")
                print(data)
                success(data)
            }
            else
            {
                print("Failed : \(response)")
            }
        }
    }
    
    func postRequest (serviceName :String, param : [String : String], success: @escaping (_ data:[String:AnyObject]) -> Void, failure: @escaping (_ data:[String:AnyObject]) -> Void){
        //var url =  serviceName
        var url = "\(serviceName)?\(param.myDesc)"
        
        url = self.replaceUrl(oldString: url)
        print(url)
        
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers:nil)
            .responseJSON { response in
                
                if response.result.value != nil{
                    let data = response.result.value as! [String : AnyObject]
                    print("Success")
                    print(data)
                    success(data)
                }else{
                    print("Failure \(response.result)")
                    failure(["Error":"error to server" as AnyObject])
                }
        }
    }
    
    func postRequest (serviceName :String, param : [String : Any], header : [String : String], success: @escaping (_ data:[String:AnyObject]) -> Void, failure: @escaping (_ data:[String:AnyObject]) -> Void){
        
        //var url =  serviceName
        var url = "\(serviceName)?\(param.myDesc)"
        print(url)
        url = self.replaceUrl(oldString: url)
//        //print(param)
//       //URLEncoding(destination: .httpBody)
//        let configuration = URLSessionConfiguration.default
//        configuration.timeoutIntervalForRequest = 60
//        configuration.timeoutIntervalForResource = 60
//        let alamoFireManager = Alamofire.SessionManager(configuration: configuration) // not in this line

//        alamoFireManager.request("my_url", method: .post, parameters: parameters).responseJSON { response in

        Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers:header)// URLEncoding(destination: .httpBody)
            .responseJSON { response in
                if response.result.value != nil{
                    let data = response.result.value as! [String : AnyObject]
                    print("Success")
                    print(data)
                    success(data)
                } else {
                    print("Failure \(response.result)")
                    failure(["Error":"error to server" as AnyObject])
                }
        }
    }
    
    func postRequest_Encoding (serviceName :String, param : [String : Any], header : [String : String], success: @escaping (_ data:[String:AnyObject]) -> Void, failure: @escaping (_ data:[String:AnyObject]) -> Void){
        
        //var url =  serviceName
        var url = "\(serviceName)?\(param.myDesc)"
        print(url)
        url = self.replaceUrl(oldString: url)
        print(param)
        
        Alamofire.request(url, method: .post, parameters: param, encoding: URLEncoding(destination: .httpBody), headers:header)// URLEncoding(destination: .httpBody)
            .responseJSON { response in
                
                if response.result.value != nil{
                    let data = response.result.value as! [String : AnyObject]
                    print("Success")
                    print(data)
                    success(data)
                }else{
                    print("Failure \(response.result)")
                    failure(["Error":"error to server" as AnyObject])
                }
        }
    }
    
    func postRequestAny (serviceName :String, param : [String : Any], header : [String : String], success: @escaping (_ data:[String:AnyObject]) -> Void, failure: @escaping (_ data:[String:AnyObject]) -> Void){
        
        //var url =  serviceName
        var url = "\(serviceName)?\(param.myDesc)"
        print(url)
        url = self.replaceUrl(oldString: url)
        print(param)
        
        Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers:header)
            .responseJSON { response in
                
                if response.result.value != nil{
                    let data = response.result.value as! [String : AnyObject]
                    print("Success")
                    print(data)
                    success(data)
                }else{
                    print("Failure \(response.result)")
                    failure(["Error":"error to server" as AnyObject])
                }
        }
    }
    
    func postRequestAPI (serviceName :String, param : [String : String], success: @escaping (_ data:[String:AnyObject]) -> Void, failure: @escaping (_ data:[String:AnyObject]) -> Void){
        
        Alamofire.request(serviceName, method: .post, parameters: param, encoding: JSONEncoding.default, headers:nil)
            .responseJSON { response in
                
                if response.result.value != nil{
                    let data = response.result.value as! [String : AnyObject]
                    print("Success")
                    print(data)
                    success(data)
                }else{
                    print("Failed")
                    failure(["Error":"error to server" as AnyObject])
                }
        }
    }
    
    func postRequestStringReturn (serviceName :String, param : [String : String], success: @escaping (_ data:[String:AnyObject]) -> Void, failure: @escaping (_ data:[String:AnyObject]) -> Void){
        
        var url = "\(serviceName)?\(param.myDesc)"
        url = self.replaceUrl(oldString: url)
        print("after replacement :: \(url)")
        
        Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers:nil)
            .responseString { response in
                
                if response.result.value != nil{
                    let json = response.result.value!.replacingOccurrences(of: "\n", with: "")
                    let data = self.convertToDictionary( text: json)
                    print("Success postRequest")
                    if data != nil{
                        success(data as! [String : AnyObject])
                    }else{
                        failure(["Error":"error to server" as AnyObject])
                    }
                    
                }else{
                    print("Failed postRequest")
                    failure(["Error":"error to server" as AnyObject])
                }
        }
    }
    
    func postRequestUpload (serviceName :String, param : [String : AnyObject], success: @escaping (_ data:[String:AnyObject]) -> Void, failure: @escaping (_ data:[String:AnyObject]) -> Void){
        
        var url = "\(serviceName)?\(param.myDesc)"
        print(url)
        url = self.replaceUrl(oldString: url)
        print(url)
        Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers:nil)
            .responseJSON { response in
                
                if response.result.value != nil{
                    let data = response.result.value as! [String : AnyObject]
                    print("Success")
                    print(data)
                    success(data)
                }else{
                    print("Failure \(response.result)")
                    failure(["Error":"error to server" as AnyObject])
                }
        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func replaceUrl(oldString : String) -> String{
        return oldString.replacingOccurrences(of: " ", with: "%20")
    }
}
