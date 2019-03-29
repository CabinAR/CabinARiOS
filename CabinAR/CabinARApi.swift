//
//  CabinARApi.swift
//
import Foundation
import Alamofire
import SwiftyJSON


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
    let baseUrl = "http://localhost:3000/api"
    //#else
    //let baseUrl = "https://www.cabinar.io/api"
    //#endif
    
    func url(_ path:String) -> String {
        return "\(baseUrl)\(path)"
    }

    func getNearbySpaces(callback:@escaping ([CabinSpace]) -> Void) {
        let parameters: Parameters = [:]; // "api_key": userToken!]
        Alamofire.request(url("/spaces"), parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
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
    
    func getSpace(_ id:Int, callback:@escaping (CabinSpace?) -> Void) {
        let parameters: Parameters = [:]; // "api_key": userToken!]
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
    
    /*
    
    func getJournalDetail(_ id:Int, callback:@escaping (JournalEntry?) -> Void) {
        let parameters: Parameters = [ "api_key": userToken!]
        Alamofire.request(url("journals/\(id)"), parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let entry = JournalEntry.createSingle(json: json)
                callback(entry)
            case .failure(let error):
                print(error)
                callback(nil)
            }
        }
        return
    }
    
    func checkLogin(_ callback:@escaping (Bool) -> Void) {
        if let userToken = userToken {
            let parameters: Parameters = [ "api_key": userToken, "device_token": deviceToken ?? "" ]
            Alamofire.request(url("users"), parameters: parameters).validate().responseJSON { response in
                switch response.result {
                case .success(_):
                    callback(true)
                case .failure(let error):
                    print(error)
                    callback(false)
                }
            }
            return
        }
        callback(false)
        return
    }
    
    func getUser(_ callback:@escaping (UserInfo?) -> Void) {
        let parameters: Parameters = [ "api_key": userToken! ]
        Alamofire.request(url("users"), parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let user = UserInfo.create(fromJSON: json["user"])
                callback(user)
            case .failure(_):
                callback(nil)
            }
        }
    }
    
    func updateUser(_ user:UserInfo, callback:@escaping (Bool) -> Void) {
        let parameters: Parameters = [ "api_key": userToken!, "user": user.parameters() ]
        Alamofire.request(url("users"),  method: .put, parameters: parameters).validate().responseJSON() { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let token = json["token"].string
                if token !=  nil {
                    callback(true)
                } else {
                    callback(false)
                }
                return
            case .failure(_):
                callback(false)
                return
            }
        }
    }
    
    func logout() {
        self.userToken = nil
    }
    
    func performLogin(username:String, password:String, callback:@escaping (Bool,String) -> Void) {
        let parameters: Parameters = [ "user" : [ "username": username, "password": password]]
        Alamofire.request(url("users/login"), method: .post,
                          parameters: parameters).validate().responseJSON() { response in
                            switch response.result {
                            case .success(let value):
                                let json = JSON(value)
                                let token = json["token"].string
                                if let token = token {
                                    self.userToken = token
                                    callback(true, "")
                                } else {
                                    let errorMessage = json["error"].stringValue
                                    callback(false, errorMessage)
                                }
                                return
                            case .failure(_):
                                callback(false, "Unable to reach server")
                                return
                            }
        }
    }
    
    
    func register(username:String, password:String, callback:@escaping (Bool,String) -> Void) {
        let parameters: Parameters = [ "user" : [ "username": username, "password": password]]
        
        Alamofire.request(url("users"),  method: .post, parameters: parameters).validate().responseJSON() { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let token = json["token"].string
                if let token = token {
                    self.userToken = token
                    callback(true, "")
                } else {
                    let errorMessage = json["error"].stringValue
                    callback(false, errorMessage)
                }
                return
            case .failure(_):
                callback(false, "Unable to reach server")
                return
            }
        }
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
    
    var enabledNotifications: Bool? {
        get {
            return self._enabledNotifications
        }
        set {
            self._enabledNotifications = newValue
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "enabled_notifications")
        }
    }
    
    var askedAboutNotifications: Bool? {
        get {
            return self._askedAboutNotifications
        }
        set {
            self._askedAboutNotifications = newValue
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "asked_about_notifications")
        }
    }
    
    lazy var dateFormatter:DateFormatter  = {
        var formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("HHmm")
        return formatter
    }()
    
    
    var notificationTime: Date {
        get {
            if let notificationTime = self._notificationTime {
                return dateFormatter.date(from: notificationTime)!
            } else {
                return Date()
            }
        }
        set {
            self._notificationTime = dateFormatter.string(from: newValue)
            let defaults = UserDefaults.standard
            defaults.set(self._notificationTime, forKey: "notification_time")
        }
    }*/
}
