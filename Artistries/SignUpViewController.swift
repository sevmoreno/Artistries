//
//  ViewController.swift
//  Artistries
//
//  Created by Juan Moreno on 12/3/19.
//  Copyright © 2019 Juan Moreno. All rights reserved.
//

import UIKit

import Firebase

class SignUpViewController: UIViewController {
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
      //  button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        
        button.addTarget(self, action: #selector(clickphoto), for: .touchUpInside)
        return button
    }()
    
    @objc func clickphoto () {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        
        button.addTarget(self, action: #selector (hadlesingup), for: .touchUpInside)
        
        return button
    }()
    
    @objc func hadlesingup () {
       
        
        guard let email = emailTextField.text, email.count > 0 else {return}
        guard let password = passwordTextField.text, password.count > 0 else {return}
        guard let username = usernameTextField.text, username.count > 0 else {return}
        
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            
            
            if let erro = error {
                print(erro.localizedDescription)
            }
            
            guard let image = self.plusPhotoButton.imageView?.image else { return }
            
            guard let uploadData = image.jpegData(compressionQuality: 0.3) else { return }
            
            let filename = NSUUID().uuidString
            
            let storageRef = Storage.storage().reference().child("profile_images").child(filename)
            
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, err) in
                
                if let err = err {
                    print("Failed to upload profile image:", err)
                    return
                }
                
                // Firebase 5 Update: Must now retrieve downloadURL
                storageRef.downloadURL(completion: { (downloadURL, err) in
                    if let err = err {
                        print("Failed to fetch downloadURL:", err)
                        return
                    }
                    
                    guard let profileImageUrl = downloadURL?.absoluteString else { return }
                    
                    guard let uid = authResult?.user.uid else {return}
                    
                    let usuariovalores = ["username":username, "photo":profileImageUrl]
                    let valores = [uid:usuariovalores]
                    
                    print(authResult?.user.uid)
                    Database.database().reference().child("users").updateChildValues(valores, withCompletionBlock: { (error, dataref) in
                        if let err = error {
                            print ("error al salvar info")
                        }
                        
                        print("Succefully saved user")
                    })
            
                })
            })
            
            
        }

        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(plusPhotoButton)
        
        plusPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        setupInputFields()
    }
    
    fileprivate func setupInputFields() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, signUpButton])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 200)
    }
    
}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
}


extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate


{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width/2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 3
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
}
