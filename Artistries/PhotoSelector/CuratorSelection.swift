//
//  CuratorSelection.swift
//  Artistries
//
//  Created by Juan Moreno on 6/10/20.
//  Copyright © 2020 Juan Moreno. All rights reserved.
//

import Foundation
import Firebase


import UIKit
import Photos


class CuratorSelectorController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    let headerId = "headerId"
    
    var selectedImage: UIImage?
    var images = [UIImage]()
     var assets = [PHAsset]()
     var headerImage: UIImage?
     var discoveryPosts = [Post]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        
       
        
        setupNavigationButtons()
        
        collectionView?.register(NewDiscoveryCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.register(NewDiscoveryCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
       // fetchPhotos()
        
        
        fetchUnfollowUserIds()
        
        
         collectionView?.reloadData()
    }
    
    
    
    fileprivate func fetchPhotos() {
        
      //  DispatchQueue.global(qos: .background).async {
            
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 10
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        
        let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        allPhotos.enumerateObjects({ (asset, count, stop) in
            let imageManager = PHImageManager.default()
            let targetSize = CGSize(width: 350, height: 350)
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                
                if let image = image {
                    self.images.append(image)
                    self.assets.append(asset)
                    
                    
                    if self.selectedImage == nil {
                        self.selectedImage = image
                    }
                    
                }
                
                if count == allPhotos.count - 1 {
                    DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    }
                }
                
            })
            
        })
    // }
        
    }
    
     fileprivate func fetchUnfollowUserIds() {
        
        
        var followinUsersIds = [String] ()
        
         guard let uid = Auth.auth().currentUser?.uid else { return }
         Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
             
             guard let userIdsDictionary = snapshot.value as? [String: Int] else { return }
            
             
             userIdsDictionary.forEach({ (key,value) in
                 
                 print("Sigo a este")
                
                 print(key)
                
                followinUsersIds.append(key)

             })
             
 
            Database.database().reference().child("posts").observeSingleEvent(of: .value, with: { (idPosts) in
            
                
//                print("Imprmiendo los key")
//                print(idPosts.key)
//
//                print("Imprmiendo los value")
//                print(idPosts.value)
                
                
                guard let snapshotValue = idPosts.value as? [String:AnyObject] else { return }
                
                print("LLEGO a Convertirlo")
                print(snapshotValue.keys)
                
                snapshotValue.forEach({(key,value) in
                
                    if followinUsersIds.contains(key) {
                        print("Ya lo sigue")
                    } else {
                        
                        let usuarioId = key
                        
                        
                        guard let postNew = value as? [String:AnyObject] else {
                            print("No convierte")
                            return }
                    
                        postNew.forEach { (key,valuor) in
                            print("Key indiviudal del usuario \(usuarioId)")
                            print(key)
                            
                            
                            print("Este es el id de usuario \(usuarioId)")
                            
                            if usuarioId != Auth.auth().currentUser?.uid {
                            Database.database().reference().child("users").child(usuarioId).observeSingleEvent(of: .value, with: { (snapdata) in
                            
                              
                                
//                               print("ESTA BUSCANDO ESTO \(usuarioId)")
//
//                                print(snapdata.value)
                               // print(idPosts.value)
                                
                                let usuarioNuevo = User(uid: usuarioId, dictionary: snapdata.value as! [String:String])
                                
                                let post = Post(user: usuarioNuevo, dictionary: valuor as! [String : Any])
                                
                                self.discoveryPosts.append(post)
                                print("Este es uno de los Post: \(post.creationDate)")
                                
                                self.collectionView.reloadData()
                                
                            })
                                
                            }


                        }
                    
                        

                    }
                
                
                })
               // guard let userIdsDictionary = snapshot.value as? [String: Int] else { return }
              
                // [String:[Post]
                
                
                
                
                
                })
            
            
            
             })
             
     //    }) { (err) in
    //         print("Failed to fetch following user ids:", err)
             
             
     }
     
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.userId = discoveryPosts[indexPath.row].user.uid
        
        userProfileController.hiddenNav = true
        
            navigationController?.pushViewController(userProfileController, animated: true)
        
   
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! NewDiscoveryCell
        
        print("Cuenta estos post: \(discoveryPosts.count)")
        
        if discoveryPosts.count == 0 {
            
            
            
        } else {
       
            header.newDiscovery = discoveryPosts[0]
        
        
        }
        
//        header.photoImageView.image = selectedImage
//
//
//
//       headerImage = selectedImage
//
//
//        if let selectedImage = selectedImage {
//            if let index = self.images.index(of: selectedImage) {
//                let selectedAsset = self.assets[index]
//
//                let imageManager = PHImageManager.default()
//                let targetSize = CGSize(width: 600, height: 600)
//                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .default, options: nil, resultHandler: { (image, info) in
//
//                    header.photoImageView.image = image
//
//                })
//
//            }
   //     }
        
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return discoveryPosts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NewDiscoveryCell
        
        cell.newDiscovery = discoveryPosts[indexPath.row]
       
        
     //   cell.photoImageView.image = discoveryPosts[indexPath.row].imageUrl
        
        return cell
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    fileprivate func setupNavigationButtons() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
    
    @objc func handleNext() {
        let sharePhotoController = SharePhotoController()
        sharePhotoController.selectedImage = headerImage
        navigationController?.pushViewController(sharePhotoController, animated: true)
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
}
