//
//  users.swift
//  Artistries
//
//  Created by Juan Moreno on 12/4/19.
//  Copyright © 2019 Juan Moreno. All rights reserved.
//

import Foundation

struct User {
    let uid: String
    let username: String
    let profileImageUrl: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["photo"]  as? String ?? ""
        self.uid = uid 
    }
}
