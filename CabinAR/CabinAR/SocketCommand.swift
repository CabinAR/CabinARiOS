//
//  SocketCommand.swift
//  CabinAR
//
//  Created by Pascal Rettig on 4/1/19.
//  Copyright © 2019 Pascal Rettig. All rights reserved.
//

import Foundation
import Foundation
import SwiftyJSON
import Alamofire

struct SocketCommand {
    var command: String
    var space_id: Int
    
    
    func toString() -> String {        
        var identifier:JSON = [
            "identifier": "SpaceUpdates",
            "space_id": self.space_id
        ]
                
        var json:JSON = [
            "command": self.command,
            "identifier": identifier.rawString()
        ]
        
        return json.rawString()!
    }
    
}
