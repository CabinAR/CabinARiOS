//
//  CabinSpace.swift
//  CabinAR
//
//  Created by Pascal Rettig on 3/27/19.
//  Copyright © 2019 Pascal Rettig. All rights reserved.
//

import Foundation
import Foundation
import SwiftyJSON
import Alamofire

struct CabinSpace {
    var id: Int
    var name: String
    var icon_url: URL?
    var tagline: String?

    var pieces:  Dictionary<Int, CabinPiece>
    
    init(id: Int,
         name: String,
         icon_url: String?,
         tagline: String?,
         pieces: Dictionary<Int,CabinPiece>) {
        self.id = id
        self.name = name
        self.tagline = tagline
        if icon_url != nil {
            self.icon_url = URL(string: icon_url!)
        }
        self.pieces = pieces
    }
    
    
    static func create(fromJson: JSON) -> [CabinSpace] {
        var output:[CabinSpace] = []
        
        for json:JSON in fromJson.arrayValue {
            let element = createSingle(fromJson: json)
            output.append(element)
        }
        
        return output;
    }
    
    static func createSingle(fromJson: JSON) -> CabinSpace {
        
        var pieces:Dictionary<Int,CabinPiece> = [:]
        
        if fromJson["pieces"].array != nil {
            let pieceArr = CabinPiece.create(fromJson: fromJson["pieces"])
            pieceArr.forEach { piece in
                pieces[piece.id] = piece
            }
        }
        
        let space = CabinSpace(id: fromJson["id"].intValue,
                                  name: fromJson["name"].stringValue,
                                  icon_url: fromJson["icon_url"].string,
                                  tagline: fromJson["tagline"].string,
                                  pieces: pieces)
        return space
    }
    
    /*func parameters() -> Parameters {
        let params:Parameters = [
            "name": body,
            "image_delete": image_delete ? "1" : "0"
        ]
        
        return params
    }*/
    
}
