//
//  LogController.swift
//  iOS-Shack-v2
//
//  Created by Sven on 11/12/20.
//  Copyright © 2020 Sven. All rights reserved.
//

import Foundation
import UIKit
import os.log


class LogController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = .white
        
        var myLabel = MyLabel()

        myLabel = MyLabel(frame: CGRect(x: 25, y: 50, width: 350, height: 150))
        myLabel.text  = "Press the Buttons to trigger a log event. \n Can you find the logs?"
        myLabel.numberOfLines = 2
        self.view.addSubview(myLabel)
      
        // Create UIButton
        let logButton = UIButton(type: .system)
        // Position Button
        logButton.frame = CGRect(x: 100, y: 200, width: 150, height: 50)
        // Set text on button
        logButton.setTitle("Create Log", for: .normal)
        // Set button tint color
        logButton.tintColor = UIColor.black
        // Set button background color
        logButton.backgroundColor = UIColor.lightGray
        // Set button action
        logButton.addTarget(self, action: #selector(buttonActionLog(_:)), for: .touchUpInside)
    

        view.addSubview(logButton)
        
        self.view = view
        
    }
    
    
    @objc func buttonActionLog(_ sender:UIButton!)
    {

        let Url = String(format: "https://example.com")
        guard let serviceUrl = URL(string: Url) else { return }
        let parameterDictionary = ["username" : "Test", "password" : "123456"]
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
            return
        }
        request.httpBody = httpBody
        
        print("Print - credentials being used \(parameterDictionary)")
        
//        #if DEBUG
            NSLog("NSLog - credentials being used: %@", parameterDictionary)
//        #endif
        
        os_log("OS_LOG - credentials being used: %{public}@", log: .default, parameterDictionary)
        
        let logger = Logger(subsystem: "com.example.LoggingTest", category: "main")
        logger.info("Logger - credentials being used \(parameterDictionary, privacy: .public)")
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                // for debugging
//                print(parameterDictionary)
                
                print(response)
            }
        }.resume()
        
        
        /*
         * A function customPrint is being created that includes the "#ifdef DEBUG" and "#endif" preprocessor macro code
         * (see line 96 also):
         *
         *  func customPrint(string: String) {
         *   #if DEBUG
         *    print(string)
         *   #endif
         *  }
         *
         * Comment the print statement above (L62), press the option key and click on the Build button in Xcode.
         * In the build settings menu, select "Release". Run the app in the simulator and you can see in the Xcode Console
         * that the print statements disappear when you click on the "Create Log" button.
         * Instead of print, the function customPrint should always be used instead, as this ensures that all log statements
         * will be removed for the release build.
         * This is ensured due to the usage of the #ifdef DEBUG" and "#endif" preprocessor macro code.
        */
//        customPrint(string: parameterDictionary["username"]!)
//        customPrint(string: parameterDictionary["password"]!)
        
    }
    
    
    
    func customPrint(string: String) {
        #if DEBUG
            print(string)
        #endif
    }
    
}


extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let ui = OSLog(subsystem: subsystem, category: "UI")
//    static let firebase = OSLog(subsystem: subsystem, category: "Firebase")
}
