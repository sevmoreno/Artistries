
//
//  NetworkManager.swift
//  GHFollowers
//
//  Created by Juan Moreno on 6/17/20.
//  Copyright © 2020 Juan Moreno. All rights reserved.
//

import UIKit
import Firebase
class NetworkManager {
    
    // Love you Singelton
    
    static let shared = NetworkManager ()
    
    let baseURL = "https://www.wikiart.org/en/Api/2/login?accessCode=24b121ed1b9e4337&secretCode=adcf836a414a4ae1"
    
    let getArtitstURL =  "https://www.wikiart.org/en/api/2/UpdatedArtists"
    
    let baseArtistID = "https://www.wikiart.org/en/api/2/PaintingsByArtist?id="
    
    let pinturas = [Paintines] ()
    
       func getArtist () {
            
            
              let url = URL(string: getArtitstURL)
            
            
              let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                      
                      if let _ = error  {
                        
                        print("No se pudo conectar al API")
                         return
                      }
                      
                      guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                          
                        print("No se pudo conectar al API 2")
                          return
                      }
                      
                      
                      guard let data = data else {
                          print("No se pudo conectar al API 3")
                          return
                      }
                      
                     
                
                 //   print(String(bytes: data, encoding: String.Encoding.utf8))
                      
                // https://www.wikiart.org/en/api/2/PaintingsByArtist?artistUrl=laura-knight&imageFormat=PinterestSmall
                // https://www.wikiart.org/en/api/2/UpdatedArtists
    //            let str = "{\"names\": [\"Bob\", \"Tim\", \"Tina\"]}"
    //            let data2 = Data(str.utf8)

                do {
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // try to read out a string array
                        print("pudo")
                        if let names = json["data"] as? [Any] {
                            
                            names.forEach { (objeto) in
                                
                                guard let diccionario = objeto as? [String:Any] else { return }
                                
                                print(diccionario["artistName"] as! String)
                                print(diccionario["image"] as! String)
                                print(diccionario["url"] as! String)
                                
                                // https://www.wikiart.org/en/api/2/PaintingsByArtist?id=580b8069edc2c98300cf6e74

                                // https://www.wikiart.org/en/api/2/PaintingsByArtist?artistUrl=lolo-soldevilla
                                //url
                                // "image"
                                ///
                                
                                
                                let uid = diccionario["id"] as! String

                                let usuariovalores = ["username": diccionario["artistName"] as! String, "photo": diccionario["image"] as! String]
                                let valores = [uid:usuariovalores]
                                
                               
                                Database.database().reference().child("users").updateChildValues(valores, withCompletionBlock: { (error, dataref) in
                                    if error != nil {
                                        print ("error al salvar info")
                                    }
                                    
                                    print("Succefully saved user")
                                    
                                    // LUEGO QUE SALVAMOS EL USUARIO CREAMOS LAS IMAGENES
                                    
                                 
                                    NetworkManager.shared.fetchArtistPhotos(id: diccionario["id"] as! String) { (pinturas, error) in
                                        
                                        print(pinturas!.count)
                                        
                                        pinturas?.forEach({ (pintura) in
                                            print(pintura.title)
                                            
                                            
                                            let userPostRef = Database.database().reference().child("posts").child(uid).childByAutoId()
                                                         
                                                          
                                            let values = ["imageUrl": pintura.image, "caption": pintura.title, "imageWidth": pintura.width, "imageHeight": pintura.height,
                                                                        "creationDate": Date().timeIntervalSince1970, "artist" : diccionario["artistName"] as! String] as [String : Any]
                                                          
                                                          userPostRef.updateChildValues(values) { (err, ref) in
                                                              if let err = err {
                                                                  
                                                                  print("Failed to save post to DB", err)
                                                                  return
                                                              }
                                                              
                                                              print("Successfully saved post to DB")

                                                          }
                                            
                                        })
                                    }
                                    
                                    
                                    //
                                
                                }
                                )
                                
                                ///
                            }
                            
                        }
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
                     
    //                  do {
    //
    //                      let decoder = JSONDecoder()
    //                      decoder.keyDecodingStrategy = .convertFromSnakeCase
    //                      let followers = try decoder.decode([User].self, from: data)
    //                      completed(followers,nil)
    //
    //                  } catch {
    //
    //                      completed(nil,ErrorMessages.invalidData)
    //
    //
    //                  }
                      
                  }
                  
                  task.resume()
            
            
            
            
            
        }
    
    
    func fetchArtistPhotos(id: String,completed: @escaping ([Paintines]?,ErrorMessages?) -> Void) {
        
        
        
        guard let url = URL(string: baseArtistID + id) else {
            
            print ("No hace URL")
            return
            
        }
        
        let taks = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let _ = error {
                
                print("Conecction to server fail")
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                
                print("Conecction to server fail")
                
                return
                
            }
            
            guard let data = data else {
                print("No se pudo conectar al API 3")
                return
            }
            
                              do {
               
                                     let decoder = JSONDecoder()
                                     decoder.keyDecodingStrategy = .convertFromSnakeCase
                                     let followers = try decoder.decode(JsonPaintins.self, from: data)
                                      completed(followers.data,nil)
               
                                 } catch {
               
                                    print("Error parsing")
                                     completed(nil,ErrorMessages.invalidData)
               
               
                                 }
            
        }
        
        
        taks.resume()
        
    }
    
    
    
    
    
    func getSessionKey () {
        
        
         let url = URL(string: baseURL)
        
        
          let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                  
                  if let _ = error  {
                    
                    print("No se pudo conectar al API")
                     return
                  }
                  
                  guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                      
                    print("No se pudo conectar al API 2")
                      return
                  }
                  
                  
                  guard let data = data else {
                      print("No se pudo conectar al API 3")
                      return
                  }
                  
                 
            
                print(String(bytes: data, encoding: String.Encoding.utf8))
                  
            // https://www.wikiart.org/en/api/2/PaintingsByArtist?artistUrl=laura-knight&imageFormat=PinterestSmall
            // https://www.wikiart.org/en/api/2/UpdatedArtists
//            let str = "{\"names\": [\"Bob\", \"Tim\", \"Tina\"]}"
//            let data2 = Data(str.utf8)

            do {
                // make sure this JSON is in the format we expect
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // try to read out a string array
                    if let names = json["SessionKey"] as? String {
                        print(names)
                    }
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
                 
//                  do {
//
//                      let decoder = JSONDecoder()
//                      decoder.keyDecodingStrategy = .convertFromSnakeCase
//                      let followers = try decoder.decode([User].self, from: data)
//                      completed(followers,nil)
//
//                  } catch {
//
//                      completed(nil,ErrorMessages.invalidData)
//
//
//                  }
                  
              }
              
              task.resume()
        
        
        
        
        
    }
    
    
    // https://api.github.com/users/sevmoreno/followers?per_page=100&page=100
    private init () {}
    
    //-----------------------
    
    func getFollowers (for username: String, page: Int, completed: @escaping ([User]?,ErrorMessages?) -> Void) {
        
        let endpoint = baseURL + "\(username)/followers?per_page=100&page=\(page)"
        
        guard let url = URL(string: endpoint) else {
            
            completed(nil,ErrorMessages.invalidUsername)
            return}
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let _ = error  {
                
                completed(nil,ErrorMessages.unableToComplete)
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                
                completed(nil, ErrorMessages.invalidResponse)
                return
            }
            
            
            guard let data = data else {completed(nil,ErrorMessages.invalidData)
                return
            }
            
            
            
            do {
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let followers = try decoder.decode([User].self, from: data)
                completed(followers,nil)
                
            } catch {
                
                completed(nil,ErrorMessages.invalidData)
                
                
            }
            
        }
        
        task.resume()
    }

    
}
