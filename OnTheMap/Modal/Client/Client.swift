//
//  Client.swift
//  OnTheMap
//
//  Created by Agnidhra Gangopadhyay on 3/3/20.
//  Copyright © 2020 Agnidhra Gangopadhyay. All rights reserved.
//

import Foundation

class Client {
    
    struct userDetails {
        static var sessionID: String = ""
        static var accountKey: String = ""
    }
    
    static var studentLocationDetails : [Result] = []
    
    enum Endpoints {
        static let basicURL = "https://onthemap-api.udacity.com/v1/"
        
        case auth
        case getStudentLocation(String, String)
        case postStudentLocation
        
        var stringValue: String {
            switch self {
                case .auth: return Endpoints.basicURL+"session"
                case .getStudentLocation(let limit, let orderBy): return Endpoints.basicURL+"StudentLocation" + "?limit=\(limit)" + "&order=\(orderBy)"
                case .postStudentLocation: return Endpoints.basicURL + "StudentLocation"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    
    class func authenticateUser(username: String, password: String, completion: @escaping (Bool, String?, Error?) -> Void) {
        taskForPOSTRequest(url: Endpoints.auth.url, body: AuthBody(udacity: Udacity(username: username, password: password)),
                           successResponseType: AuthSuccess.self,
                           failureResponseType: FailureType.self) { (successData, failureData, error) in
                            if let error = error {
                                completion(false, nil, error)
                            }
                            if let successData = successData {
                                Client.userDetails.accountKey = successData.account.key
                                Client.userDetails.sessionID = successData.session.id
                                completion(true,nil, nil)
                            }
                            if let failureData = failureData {
                                completion(true,failureData.error, nil)
                            }
        }
    }
    
    class func getStudentLocationDetails(limit: String, orderBy: String, completion: @escaping (StudentLocationDetails?, Error?) -> Void)  {
        taskForGETRequest(url: Endpoints.getStudentLocation(limit, orderBy).url, responseType: StudentLocationDetails.self) { (responseData, error) in
            guard let responseData = responseData else {
                completion(nil, error)
                return
            }
            self.studentLocationDetails = responseData.results
            completion(responseData, nil)
        }
    }
    
    class func postStudentLocation(latitude: Double, longitude: Double, address: String, mediaURL: String, completion: @escaping (PostSuccessResponse?, FailureType?, Error?)-> Void ) {
        
        
        taskForPOSTRequest(url: Endpoints.postStudentLocation.url,
                           body: PostLocation(uniqueKey: "\(arc4random_uniform(5000))", firstName: "Gapuchi", lastName: "Papa", mapString: address, mediaURL: mediaURL, latitude: latitude, longitude: longitude),
                           successResponseType: PostSuccessResponse.self,
                           failureResponseType: FailureType.self) { (data, failure, error) in
                            if let error = error, data == nil, failure == nil {
                                completion(nil,nil,error)
                            } else if(data != nil) {
                                completion(data, nil, error)
                            } else {
                                completion(nil, failure, error)
                            }
        }

        
    }
    
    
    
    //MARK: Reusable function for post call
    class func taskForPOSTRequest<RequestType: Encodable, successResponseType: Decodable, failureResponseType: Decodable>(url: URL, body: RequestType,
               successResponseType: successResponseType.Type, failureResponseType: failureResponseType.Type, completion: @escaping(successResponseType?, failureResponseType?, Error?) -> Void){
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try! JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil,nil,error)
                }
                return
            }
            
            let range: Range = (5..<data.count)
            var updatedData = data.subdata(in: range)
            if(url == Endpoints.postStudentLocation.url) {
                updatedData = data
            }
            let httpResponse = response as! HTTPURLResponse
            if(httpResponse.statusCode == 200) {
                do{
                    let responseData = try JSONDecoder().decode(successResponseType.self, from: updatedData)
                    DispatchQueue.main.async {
                        completion(responseData, nil, nil)
                    }
                } catch {}
            } else {
                do{
                    let responseData = try JSONDecoder().decode(failureResponseType.self, from: updatedData)
                    DispatchQueue.main.async {
                        completion(nil, responseData, nil)
                    }
                } catch {}
            }
        }
        task.resume()
    }
    
    
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
            }
        }
        task.resume()
        return task
    }
    
    class func deleteSession() {
        var request = URLRequest(url: Endpoints.auth.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                return
            }
        }
        task.resume()
    }
    
    class func logOut(){
        self.userDetails.sessionID = ""
        self.userDetails.accountKey = ""
        Client.deleteSession()
        
    }
    
    
    
}
