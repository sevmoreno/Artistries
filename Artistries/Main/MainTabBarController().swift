//
//  MainTabBarController().swift
//  Artistries
//
//  Created by Juan Moreno on 12/3/19.
//  Copyright © 2019 Juan Moreno. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
 /*
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        /*
        let index = viewControllers?.firstIndex(of: viewController)
        if index == 2 {
            
            let layout = UICollectionViewFlowLayout()
            let photoSelectorController = PhotoSelectorController(collectionViewLayout: layout)
            let navController = UINavigationController(rootViewController: photoSelectorController)
            
            present(navController, animated: true, completion: nil)
            
            return false
        }
 
 */
        
        
        return true
    }
 
 */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser == nil {
            //show if not logged in
            DispatchQueue.main.async {
                let loginController = LoginViewController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
            }
            
            return
        }
        
        
        
         setUpViewControllers ()
    }
    
    func setUpViewControllers () {
        
        
        // real  homie
   
        
        let layout3 = UICollectionViewFlowLayout()
        let photoSelectorController1 = HomeController(collectionViewLayout: layout3)
        let homeNavController2 = UINavigationController(rootViewController: photoSelectorController1)
        photoSelectorController1.tabBarItem.image = UIImage(named: "profile_selected")
        
        // ------
        
     //   let layout = UICollectionViewFlowLayout()
      //  let userProfileController = UserProfileController(collectionViewLayout: layout)
     //   let controlladorProfile = UINavigationController(rootViewController: userProfileController)
     //   userProfileController.tabBarItem.image = UIImage(named: "profile_selected")
        
        let layoutA = UICollectionViewFlowLayout()
        let photoSelectorControllerA = UserProfileController(collectionViewLayout: layoutA)
        let homeNavControllerA = UINavigationController(rootViewController: photoSelectorControllerA)
        photoSelectorControllerA.tabBarItem.image = UIImage(named: "profile_selected")
        
        
        // Home
        
        let layout2 = UICollectionViewFlowLayout()
        let photoSelectorController = PhotoSelectorController(collectionViewLayout: layout2)
        let homeNavController = UINavigationController(rootViewController: photoSelectorController)
        photoSelectorController.tabBarItem.image = UIImage(named: "profile_selected")
      //
        // Search
        
        let layoutSearch = UICollectionViewLayout ()
        let searchViewController = SearchViewController(collectionViewLayout: layoutSearch)
        let searchNavController = UINavigationController(rootViewController: searchViewController)
        searchViewController.tabBarItem.image = UIImage(named: "profile_selected")
        // Profile
      // let navController = UINavigationController(rootViewController: userProfileController)
        
       // navController.tabBarItem.image = UIImage(named: "profile_selected")
        //  navController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
        
        tabBar.tintColor = .black
        
        viewControllers = [homeNavController2,
                           homeNavControllerA,
                           homeNavController,
                           searchNavController]
        
        // CORRECT CENTRADO DE TAB BAR
        
        guard let items = tabBar.items else { return }
        
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: -4)
        }
    }
    
}
