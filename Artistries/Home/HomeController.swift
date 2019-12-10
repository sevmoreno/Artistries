//
//  HomeController.swift
//  Artistries
//
//  Created by Juan Moreno on 12/6/19.
//  Copyright © 2019 Juan Moreno. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    var posts = [Post]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        
        collectionView?.reloadData()
        
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        
        setupNavigationItems()
        
     //   fetchPosts()
        
        porusuario()
        
    }
    
    fileprivate func porusuario() {
        
        let ref = Database.database().reference().child("posts")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
        
            guard let posts = snapshot.value as? [String: Any] else { return }
            print(posts)
            posts.forEach({ (usuario, post) in
                self.fetchPostsTodos(indiviudal: usuario)
            })
        })
        
    }
    
    
    
    fileprivate func fetchPostsTodos(indiviudal: String) {
        
    //    guard let uid = Auth.auth().currentUser?.uid else { return }
        
        
        
        let ref = Database.database().reference().child("posts").child(indiviudal)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            
            print("ESTE ES LO QUE TIENE POST")
            print(userDictionary)
            
            // let user = User(dictionary: userDictionary)
            
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach({ (key, value) in
                
                // EN KEY LEO EL USUARIO
                var user = User(uid: indiviudal, dictionary: dictionaries)
                
                print("Valor de cada Key")
                print(key)
                Database.database().reference().child("users").child(indiviudal).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    print("VALUE DE KEY")
                    print(snapshot.value ?? "")
                    
                    guard let dictionary = snapshot.value as? [String: Any] else { print("Salgo2 en usuario");return }
                    
                    user = User(uid: indiviudal, dictionary: dictionary)
                //    print( User(dictionary: dictionary))
                    
                //    self.navigationItem.title = user.username
                //    print("ESTE ES EL USER")
                //    print(user.username)
                //    print (user.profileImageUrl)
                  
                    // LEO EL VALUE O SEA EL POST PROPIAMENTE DICHO
                    guard let posteado = value as? [String: Any] else { return }
                 //   print(Post(user: user, dictionary: dictionary))
                    let post = Post(user: user, dictionary: posteado)
                    //  let post = Post(dictionary: dictionary)
                    self.posts.append(post)
                 
                   self.collectionView?.reloadData()

                }) { (err) in
                    print("Failed to fetch user:", err)
                }
            
                
                
            
            })
            
            
            
        }) { (err) in
            print("Failed to fetch posts:", err)
        }
        
    }
    
/*
    fileprivate func fetchPosts() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        
        
        let ref = Database.database().reference().child("posts").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            
            print("ESTE ES LO QUE TIENE POST")
            print(userDictionary)
            
           // let user = User(dictionary: userDictionary)
            
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach({ (key, value) in
                
                // EN KEY LEO EL USUARIO
                var user = User(uid: <#String#>, dictionary: dictionaries)
                
                print("Valor de cada Key")
                print(key)
                Database.database().reference().child("users").child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    print("VALUE DE KEY")
                    print(snapshot.value ?? "")
                    
                    guard let dictionary = snapshot.value as? [String: Any] else { print("Salgo2");return }
                    
                    user = User(dictionary: dictionary)
                    print( User(dictionary: dictionary))
                    self.navigationItem.title = user.username
                      print("ESTE ES EL USER")
                      print(user.username)
                      print (user.profileImageUrl)
                      self.collectionView?.reloadData()
                    
                }) { (err) in
                    print("Failed to fetch user:", err)
                }
                
                
                
                // LEO EL VALUE O SEA EL POST PROPIAMENTE DICHO
                guard let dictionary = value as? [String: Any] else { return }
                print(Post(user: user, dictionary: dictionary))
                 let post = Post(user: user, dictionary: dictionary)
              //  let post = Post(dictionary: dictionary)
                self.posts.append(post)
            })
            
            self.collectionView?.reloadData()
            
        }) { (err) in
            print("Failed to fetch posts:", err)
        }
        
    }
 
 */
    
    func setupNavigationItems() {
     //   navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 40 + 8 + 8 //username userprofileimageview
        height += view.frame.width
        height += 50
        height += 60
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        
        cell.post = posts[indexPath.item]
        
        return cell
    }
    
}
