//
//  CabinPiece.swift
//  CabinAR
//
//  Created by Pascal Rettig on 3/27/19.
//  Copyright © 2019 Pascal Rettig. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import Kingfisher

struct CabinPiece { 
    var id: Int
    var user_id: Int
    var space_id: Int
    var published: Bool
    var scene: String
    var code: String
    var marker_units: String?
    var marker_width: Float?
    var marker_url: String?
    var marker_image_width: Int?
    var marker_image_height: Int?
    var marker_meter_width: Float?
    var marker_meter_height: Float?
    
    static func create(fromJson: JSON) -> [CabinPiece] {
        var output:[CabinPiece] = []
        
        for json:JSON in fromJson.arrayValue {
            let element = createSingle(json: json)
            output.append(element)
        }
        return output;
    }
    
    static func createSingle(json: JSON) -> CabinPiece {
        
        let piece = CabinPiece(id: json["id"].intValue,
                               user_id: json["user_id"].intValue,
                               space_id: json["space_id"].intValue,
                               published: json["published"].boolValue,
                               scene: json["scene"].stringValue,
                               code: json["code"].stringValue,
                               marker_units: json["marker_units"].string,
                               marker_width: json["marker_width"].float,
                               marker_url: json["marker_url"].string,
                               marker_image_width: json["marker_image_width"].int,
                               marker_image_height: json["marker_image_height"].int,
                               marker_meter_width: json["marker_meter_width"].float,
                               marker_meter_height: json["marker_meter_height"].float)
        return piece
    }
    
}
