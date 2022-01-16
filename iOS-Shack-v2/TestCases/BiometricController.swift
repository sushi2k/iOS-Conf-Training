//
//  LogController.swift
//  iOS-Shack-v2
//
//  Created by Sven on 11/12/20.
//  Copyright © 2020 Sven. All rights reserved.
//

import Foundation
import UIKit
import LocalAuthentication

class BiometricController: UIViewController {

    var bioLabel = MyLabel()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = .white
        
        var myLabel = MyLabel()

        myLabel = MyLabel(frame: CGRect(x: 25, y: 50, width: 350, height: 150))
        myLabel.text  = "Biometric Authentication \n Press the button"
        myLabel.numberOfLines = 2
        self.view.addSubview(myLabel)
      
        // Create UIButton
        let bioButton = UIButton(type: .system)
        // Position Button
        bioButton.frame = CGRect(x: 100, y: 200, width: 150, height: 50)
        // Set text on button
        bioButton.setTitle("Biometric Auth", for: .normal)
        // Set button tint color
        bioButton.tintColor = UIColor.black
        // Set button background color
        bioButton.backgroundColor = UIColor.lightGray
        // Set button action
        bioButton.addTarget(self, action: #selector(buttonActionBio(_:)), for: .touchUpInside)
    
        
        view.addSubview(bioButton)
        
        

        bioLabel = MyLabel(frame: CGRect(x: 25, y: 250, width: 350, height: 150))
        bioLabel.text  = "Default"
        bioLabel.numberOfLines = 2
        self.view.addSubview(bioLabel)
        
        self.view = view
        
    }
    
    
    @objc func buttonActionBio(_ sender:UIButton!)
    {
        
        visAuthClass.isValidUer(reasonString: "BioMetric Authentication Demo") {[unowned self] (isSuccess, stringValue) in
            
            if isSuccess
            {
                self.bioLabel.textColor = UIColor.systemGreen
                self.bioLabel.text = "evaluating...... successfully completed"
            }
            else
            {
                self.bioLabel.textColor = UIColor.red
                self.bioLabel.text = "evaluating...... failed to recognise user \n reason = \(stringValue?.description ?? "invalid")"
            }
            
        }
        
        
    }
    
}


extension LAContext {
    enum BiometricType: String {
        case none
        case touchID
        case faceID
    }
    
    var biometricType: BiometricType {
        var error: NSError?
        
        guard self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            // Capture these recoverable error thru Crashlytics
            return .none
        }
        
        if #available(iOS 11.0, *) {
            switch self.biometryType {
            case .none:
                return .none
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            }
        } else {
            return  self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touchID : .none
        }
    }
}
    
    
