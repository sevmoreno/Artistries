//
//  Post.swift
//  Artistries
//
//  Created by Juan Moreno on 12/5/19.
//  Copyright © 2019 Juan Moreno. All rights reserved.
//

import Foundation

struct Post {
    let imageUrl: String
    init(dictionary: [String: Any]) {
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
    }
}
