//
//  HomeController.swift
//  Artistries
//
//  Created by Juan Moreno on 12/6/19.
//  Copyright © 2019 Juan Moreno. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomePostCellDelegate {
    
    
    func didBookmarked(cell: HomePostCell) {
        
        guard let indice = collectionView?.indexPath(for: cell) else { return }
        
        var post = self.posts[indice.row]
        
        guard let id = post.id else { return }
        
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        
        //                                                 uid                                         id -LwK937fnFjty_bYkLhV

        Database.database().reference().child("posts").child(uid).child(id).observeSingleEvent(of: .value) { (dataSnap) in
            
            print("usuario")
            print(uid)
            print("Data Snap que tenemso")
            print(dataSnap.value)
            
            // si dataSnap es null agregamos este post a los post del usuario.... mmmm es un porfolio no te mares
            //  
            
            let userPostRef = Database.database().reference().child("posts").child(uid)
            let ref = userPostRef.childByAutoId()
            
            let values = ["imageUrl": post.imageUrl, "caption": post.caption, "creationDate": Date().timeIntervalSince1970, "artist":post.artist] as [String : Any]
            
            ref.updateChildValues(values) { (err, ref) in
                if let err = err {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    print("Failed to save post to DB", err)
                    return
                }
                
                print("Successfully saved post to DB")
               // self.dismiss(animated: true, completion: nil)
              //  NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
              //  _ = self.navigationController?.popViewController(animated: true)
                
            }
        }
        
        
        
        
        
    }
    

    
    
    func didLike(for cell: HomePostCell) {
        
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        
        var post = self.posts[indexPath.item]
        print(post.caption)
        
        
        guard let postId = post.id else { return }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = [uid: post.hasLiked == true ? 0 : 1]
        Database.database().reference().child("likes").child(postId).updateChildValues(values) { (err, _) in
            
            if let err = err {
                print("Failed to like post:", err)
                return
            }
            
            print("Successfully liked post.")
            
            post.hasLiked = !post.hasLiked
            
            self.posts[indexPath.item] = post
            
            self.collectionView?.reloadItems(at: [indexPath])
            
        }
    }
    
    
    func didTapComment(post: Post) {
        print("Message coming from HomeController")
        print(post.caption)
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    
    
   
    let cellId = "cellId"
    var posts = [Post]()
    
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName, object: nil)
        super.viewDidLoad()
        // collectionView?.backgroundColor = .white
        
     //   collectionView?.backgroundColor = .rgb(red: 249, green: 230, blue: 220)
        
        navigationItem.title = "Artistries"
        
        collectionView?.backgroundColor = .white
        
        collectionView?.reloadData()
        
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        
        setupNavigationItems()
        
     //   fetchPosts()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        fetchFollowingUserIds()
        //porusuario()
        
    }
    
    func setupNavigationItems() {
  
    
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "upload").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handlePost))
    }
    
    @objc func handleCamera() {
        print("Showing camera")
        
        let cameraController = CameraController()
        present(cameraController, animated: true, completion: nil)
    }
    
    
    @objc func handlePost() {
        print("Showing camera")
        let layout2 = UICollectionViewFlowLayout()
        let photoSelectorController = PhotoSelectorController(collectionViewLayout: layout2)
        let homeNavController = UINavigationController(rootViewController: photoSelectorController)
       // let cameraController = CameraController()
        present(homeNavController, animated: true, completion: nil)
    }
    
    @objc func handleUpdateFeed() {
        
        posts.removeAll()
        fetchFollowingUserIds()
    }
    
    @objc func handleRefresh() {
        posts.removeAll()
        fetchFollowingUserIds()
    }
    
    fileprivate func fetchFollowingUserIds() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userIdsDictionary = snapshot.value as? [String: Int] else { return }
            
            userIdsDictionary.forEach({ (key,value) in
                
                print("Sigo a este")
                print(key)
               self.fetchPostsTodos(indiviudal: key)
            })
            
   //         userIdsDictionary.forEach({ (key, value) in
   //             Database.fetchUserWithUID(uid: key, completion: { (user) in
    //                self.fetchPostsWithUser(user: user)
   //             })
            })
            
    //    }) { (err) in
   //         print("Failed to fetch following user ids:", err)
            
            
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
                    var post = Post(user: user, dictionary: posteado)
                    post.id = key
                    
                    guard let uid = Auth.auth().currentUser?.uid else { return }
                    Database.database().reference().child("likes").child(key).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        print(snapshot)
                        
                        if let value = snapshot.value as? Int, value == 1 {
                            post.hasLiked = true
                        } else {
                            post.hasLiked = false
                        }
                        
                        self.posts.append(post)
                        self.posts.sort(by: { (p1, p2) -> Bool in
                            return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                        })
                        self.collectionView?.reloadData()
                        
                    }, withCancel: { (err) in
                        print("Failed to fetch like info for post:", err)
                    })
                    
                    //  let post = Post(dictionary: dictionary)
                 //   self.posts.append(post)
                 
                 //  self.collectionView?.reloadData()
                  //self.collectionView?.refreshControl?.endRefreshing()

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
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
   //     let photoTemp = CustomImageView()
      //  photoTemp.loadImage(urlString: posts[indexPath.row].imageUrl)
   //     let altura = photoTemp.image!.size.height
        
       // var height: CGFloat = 40 + 8 + 8 //username userprofileimageview
        var height: CGFloat = 40 + 8 + 8 //username userprofileimageview
        height += view.frame.width
        height += 50
        height += 60
        
        return CGSize(width: view.frame.width, height: height)
 
   /*
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = HomePostCell(frame: frame)
       // dummyCell.comment = comments[indexPath.item]
        let photoTemp = CustomImageView()
        photoTemp.loadImage(urlString: posts[indexPath.row].imageUrl)
        dummyCell.photoImageView = photoTemp
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40 + 8 + 8, estimatedSize.height)
        return CGSize(width: view.frame.width, height: height)
*/
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        
        cell.post = posts[indexPath.item]
        
        cell.delegate = self
        
        return cell
    }
    
}
