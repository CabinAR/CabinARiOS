//
//  UserInfo.swift
//  CabinAR
//
//  Created by Pascal Rettig on 4/3/19.
//  Copyright © 2019 Pascal Rettig. All rights reserved.
//


import Foundation
import SwiftyJSON
import Alamofire

struct UserInfo  {
    var email: String
    
    static func create(fromJSON: JSON) -> UserInfo {
        let element = UserInfo(email: fromJSON["email"].stringValue)
        return element
    }
    
    
    func parameters() -> Parameters {
        let params:Parameters = [
            "email": email
        ]
        
        return params
    }
}
