//
//  NewDiscoveryCell.swift
//  Artistries
//
//  Created by Juan Moreno on 6/11/20.
//  Copyright © 2020 Juan Moreno. All rights reserved.
//

import UIKit

class NewDiscoveryCell: UICollectionViewCell {
    
    
    var newDiscovery: Post? {
        
        didSet {
            
            photoImageView.loadImage(urlString: newDiscovery?.imageUrl ?? "")
            print("Se establece una imagen")
            
        }
    }
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBlue
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
