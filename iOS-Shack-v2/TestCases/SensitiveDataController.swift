//
//  SensitiveData.swift
//  iOS-Shack-v2
//
//  Created by Sven on 31/8/20.
//  Copyright © 2020 Sven. All rights reserved.
//


import Foundation
import UIKit
import CoreData
import KeychainSwift
import SQLite3
import Alamofire


class SensitiveDataController: UIViewController {

        var db: OpaquePointer?
    
        override func viewDidLoad() {
            super.viewDidLoad()
            
            view.backgroundColor = .white
            
            var myLabel = MyLabel()
            
            myLabel = MyLabel(frame: CGRect(x: 50, y: 50, width: 300, height: 150))
            myLabel.text  = "Check the local storage of the app's \n sandbox and see if you can find \n any sensitive information."
            myLabel.numberOfLines = 3
            self.view.addSubview(myLabel)
            
            pListCreation()
            
            httpRequest()
            
            httpRequestAlamofire()
            
            sqlite()
            
            // KeyChain
            let keychain = KeychainSwift()
            keychain.set("masterAccessCode123", forKey: "Secret")
            print(keychain.get("Secret"))
            
        }
    
    func httpRequest() {
        guard let url =  URL(string:"http://ror.mstg.mobi:8080/") 
        else{
            return
        }
        
        let body = "test"
        let finalBody = body.data(using: .utf8)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalBody
        
        URLSession.shared.dataTask(with: request){
            (data, response, error) in
            print(response as Any)
            if let error = error {
                print(error)
                return
            }
            guard let data = data else{
                return
            }
            print(data, String(data: data, encoding: .utf8) ?? "*unknown encoding*")
            
        }.resume()
    }
    
    
    
    func httpRequestAlamofire() {
        
        // Defined a constant that holds the URL to register an account
        let URL_USER_REGISTER = "http://ror.mstg.mobi:8080/signup"

        //creating parameters for the post request
        let parameters: Parameters=[
            
            "password":"test",
//            "name":textFieldName.text!,
            "name":"Test User",
            "email":"foo@bar.org"
        ]
        
        //Sending http post request
        Alamofire.request(URL_USER_REGISTER, method: .post, parameters: parameters).responseJSON
            {
                response in
            
//                    self.labelMessage?.text = ""
                
                //printing response
                print(response.response as Any)
                
//                os_log(response, log: OSLog.default, type: .info)
                
                
                // HTTP Status Code crated
                if response.response?.statusCode == 201 {
            
                    //getting the json value from the server
                    if let result = response.result.value {
                        
                        //converting it as NSDictionary
                        let jsonData = result as! NSDictionary
                        
                        //displaying the message in label
                        if jsonData.value(forKey: "message") != nil {
//                                    self.labelMessage?.text = (jsonData.value(forKey: "message") as! String?)
                            
                                let token = jsonData.value(forKey: "auth_token") as! String
                                print (token)
                            
                                _ = FileManager.default
                                let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                                let path = documentDirectory.appending("/JWT.plist")
                            
                                let dicContent:[String: String] = ["token": token]
                                let plistContent = NSDictionary(dictionary: dicContent)
                                let success:Bool = plistContent.write(toFile: path, atomically: true)
                                if success {
                                    print("file has been created!")
                                }else{
                                    print("unable to create the file")
                                }
                            
                            
                        } else {
                            print("Message doesn't contain a value.")
                        }
                        
                    }
                    
                }
                
                
                guard case let .failure(error) = response.result else { return }

                if let error = error as? AFError {
                    switch error {
                    case .invalidURL(let url):
                        print("Invalid URL: \(url) - \(error.localizedDescription)")
                    case .parameterEncodingFailed(let reason):
                        print("Parameter encoding failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    case .multipartEncodingFailed(let reason):
                        print("Multipart encoding failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    case .responseValidationFailed(let reason):
                        print("Response validation failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")

                        switch reason {
                        case .dataFileNil, .dataFileReadFailed:
                            print("Downloaded file could not be read")
                        case .missingContentType(let acceptableContentTypes):
                            print("Content Type Missing: \(acceptableContentTypes)")
                        case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                            print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                        case .unacceptableStatusCode(let code):
                            print("Response status code was unacceptable: \(code)")
                        }
                    case .responseSerializationFailed(let reason):
                        print("Response serialization failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    }

                    print("Underlying error: \(error.underlyingError)")
                } else if let error = error as? URLError {
                    print("URLError occurred: \(error)")
                } else {
                    print("Unknown error: \(error)")
                }
        }
        
    }

        func sqlite() {
            // SQLite Database
            //the database file
            let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("Database.sqlite")
            
            //opening the database
            if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
                print("error opening database")
            }
            
            //droping table
            if sqlite3_exec(db, "DROP TABLE Users", nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error dropping table: \(errmsg)")
            }
            
            //creating table
            if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, password TEXT)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating table: \(errmsg)")
            }
            
            
            //creating a statement
            var stmt: OpaquePointer?
            
            //the insert query
            let queryString = "INSERT INTO Users (name, password) VALUES (?,?)"
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            let name = "john smith";
            
            //binding the parameters
            if sqlite3_bind_text(stmt, 1, name, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            
            let password = "SuperSecretPassword";
            
            if sqlite3_bind_text(stmt, 2, password, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting hero: \(errmsg)")
                return
            }
        }
        
        func pListCreation() {
            let fileManager = FileManager.default
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let path = documentDirectory.appending("/debug.plist")
            
            if (!fileManager.fileExists(atPath: path)) {
                let dicContent:[String: String] = ["username": "debug@foo.org", "password":"debugPass"]
                let plistContent = NSDictionary(dictionary: dicContent)
                let success:Bool = plistContent.write(toFile: path, atomically: true)
                if success {
                    print("file has been created!")
                }else{
                    print("unable to create the file")
                }
                
            }else{
                print("file already exist")
            }
        }

        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
    }
