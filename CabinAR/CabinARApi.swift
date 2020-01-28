//
//  CabinARApi.swift
//
import Foundation
import Alamofire
import SwiftyJSON
import Starscream
import CoreLocation

class CabinARApi {
    
    static let api = CabinARApi()
    
    private var _deviceToken: String?
    private var _userToken: String?
    private var _askedAboutNotifications: Bool?
    private var _enabledNotifications: Bool?
    
    
    private init() {
        let defaults = UserDefaults.standard
        self._userToken = defaults.string(forKey: "user_token")
        self._deviceToken = defaults.string(forKey: "device_token")
        self._askedAboutNotifications = defaults.bool(forKey: "asked_about_notifications")
        self._enabledNotifications = defaults.bool(forKey: "enabled_notifications" )
    }
    
    var userToken: String? {
        get {
            return self._userToken
        }
        set {
            self._userToken = newValue
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "user_token")
        }
    }
    
    var deviceToken: String? {
        get {
            return self._deviceToken
        }
        set {
            self._deviceToken = newValue
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "device_token")
        }
    }
    
    //#if DEBUG
    //let PROTOCOL = "http"
    //let HOST = "192.168.1.12:3000"
    //let HOST = "localhost:3000"
    //let PROTOCOL = "http"
    //let HOST = "localhost:3000"

    let PROTOCOL = "https"
    let HOST = "www.cabin-ar.com"
    //let HOST = "cabinar-staging.herokuapp.com"
    //let baseUrl = "http://192.168.1.15:3000/api"
    //#else
    //let baseUrl = "https://www.cabinar.io/api"
    //#endif
    
    func connectSocket(_ delegate: WebSocketDelegate) -> WebSocket {
        let socket = WebSocket(url: socketUrl())
        socket.delegate = delegate
        socket.connect()
        return socket
    }
    
    
    
    func url(_ path:String) -> String {
        return "\(PROTOCOL)://\(HOST)/api\(path)"
    }
    
    func socketUrl() -> URL {
        return URL(string: "ws://\(HOST)/cable")!
    }
        
    func getNearbySpaces(_ location:CLLocationCoordinate2D?, callback:@escaping ([CabinSpace]) -> Void) {
        let parameters: Parameters = ["api_key": userToken ?? "",
                                      "latitude": location?.latitude ?? 0.0 ,
                                      "longitude": location?.longitude ?? 0.0 ]
    
        Alamofire.request(url("/spaces"), parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                print(value)
                let json = JSON(value)
                let entries = CabinSpace.create(fromJson: json)
                callback(entries)
            case .failure(let error):
                print(error)
                callback([])
            }
        }
        return
    }
    
    func getSpace(_ id:Int, api_key:String? = nil, callback:@escaping (CabinSpace?) -> Void) {
        let parameters: Parameters = ["api_key": api_key ?? userToken ?? ""]
        Alamofire.request(url("/spaces/" + String(id)), parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let entry = CabinSpace.createSingle(fromJson: json)
                callback(entry)
            case .failure(let error):
                print(error)
                callback(nil)
            }
        }
        return
    }
    
    
    
    func getUser(_ callback:@escaping (UserInfo?) -> Void) {
        if(userToken == nil) {
            callback(nil)
            return
        }
        let parameters: Parameters = [ "api_key": userToken! ]
        Alamofire.request(url("/logins"), parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let user = UserInfo.create(fromJSON: json)
                callback(user)
            case .failure(_):
                callback(nil)
            }
        }
    }
    
    
    func logout() {
        self.userToken = nil
    }
    
    func performLogin(api_key:String, callback:@escaping (Bool,String?, UserInfo?) -> Void) {
        let parameters: Parameters = [ "api_key": api_key ]
        Alamofire.request(url("/logins"), method: .post,
                          parameters: parameters).validate().responseJSON() { response in
                            switch response.result {
                            case .success(let value):
                                let json = JSON(value)
                                let token = json["api_token"].string
                                if let token = token {
                                    self.userToken = token
                                    callback(true, nil, UserInfo.create(fromJSON: json))
                                } else {
                                    let errorMessage = json["error"].stringValue
                                    callback(false, errorMessage, nil)
                                }
                                return
                            case .failure(_):
                                callback(false, "Unable to reach server", nil)
                                return
                            }
        }
    }
    
    
}
