//
//  Paintins.swift
//  Artistries
//
//  Created by Juan Moreno on 6/19/20.
//  Copyright © 2020 Juan Moreno. All rights reserved.
//

import Foundation

struct JsonPaintins: Codable {
    var data: [Paintines]
}

struct Paintines: Codable {
    
    var title: String
    var image: String
    var width: Int
    var height: Int
}
