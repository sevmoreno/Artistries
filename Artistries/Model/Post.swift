//
//  Post.swift
//  Artistries
//
//  Created by Juan Moreno on 12/5/19.
//  Copyright © 2019 Juan Moreno. All rights reserved.
//

struct Post {
    
    let user: User
    let imageUrl: String
    let caption: String
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""
    }
}
