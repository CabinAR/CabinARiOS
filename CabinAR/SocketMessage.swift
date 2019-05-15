//
//  SocketMessage.swift
//  CabinAR
//
//  Created by Pascal Rettig on 3/27/19.
//  Copyright © 2019 Pascal Rettig. All rights reserved.
//

import Foundation
import Foundation
import SwiftyJSON
import Alamofire

struct SocketMessage {
    var type: String
    var data: JSON?
    
    static func create(_ fromJsonString: String) -> SocketMessage {
        
        var fromJson = JSON.init(parseJSON:fromJsonString)
        
        var subMessage: String?
        var data:JSON?
        
        if fromJson["message"]["message"].string != nil {
            subMessage = fromJson["message"]["message"].string
            data = fromJson["message"]["data"]
        }
        

        let output = SocketMessage(type: fromJson["type"].string ?? subMessage ?? "message",
                                   data: data)
    
        return output;
    }
    
}
