//
//  ViewController.swift
//  iOS-Shack-v2
//
//  Created by Sven on 31/8/20.
//  Copyright © 2020 Sven. All rights reserved.
// https://www.youtube.com/watch?v=e8OtfA3YvSM


import SideMenu
import UIKit

class ViewController: UIViewController, MenuControllerDelegate {
    private var sideMenu: SideMenuNavigationController?

    private let sensitiveDataController = SensitiveDataController()
    private let logController = LogController()
    private let biometericController = BiometricController()

    override func viewDidLoad() {
        super.viewDidLoad()
        let menu = MenuController(with: SideMenuItem.allCases)

        let str = "Test Message"
        let url = self.getDocumentsDirectory().appendingPathComponent("message.txt")

        do {
            try str.write(to: url, atomically: true, encoding: .utf8)
            let input = try String(contentsOf: url)
            print(input)
        } catch {
            print(error.localizedDescription)
        }
        
        
        let aws_access_key = "AKIAIOSFODNN7EXAMPLE"
        let aws_secret_access_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
        
        menu.delegate = self

        sideMenu = SideMenuNavigationController(rootViewController: menu)
        sideMenu?.leftSide = true

        SideMenuManager.default.leftMenuNavigationController = sideMenu
        SideMenuManager.default.addPanGestureToPresent(toView: view)

        addChildControllers()
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func addChildControllers() {
        addChild(sensitiveDataController)
        addChild(logController)
        addChild(biometericController)
        

        view.addSubview(sensitiveDataController.view)
        view.addSubview(logController.view)
        view.addSubview(biometericController.view)

        sensitiveDataController.view.frame = view.bounds
        logController.view.frame = view.bounds
        biometericController.view.frame = view.bounds

        sensitiveDataController.didMove(toParent: self)
        logController.didMove(toParent: self)
        biometericController.didMove(toParent: self)

        sensitiveDataController.view.isHidden = true
        logController.view.isHidden = true
        biometericController.view.isHidden = true
    }

    @IBAction func didTapMenuButton() {
        present(sideMenu!, animated: true)
    }

    func didSelectMenuItem(named: SideMenuItem) {
        sideMenu?.dismiss(animated: true, completion: nil)

        title = named.rawValue
        switch named {
        case .home:
            sensitiveDataController.view.isHidden = true
            logController.view.isHidden = true
            biometericController.view.isHidden = true
        

        case .sensitiveData:
            sensitiveDataController.view.isHidden = false
            logController.view.isHidden = true
            biometericController.view.isHidden = true
            
            
        case .log:
            sensitiveDataController.view.isHidden = true
            logController.view.isHidden = false
            biometericController.view.isHidden = true
            
        case .biometric:
            sensitiveDataController.view.isHidden = true
            logController.view.isHidden = true
            biometericController.view.isHidden = false
        }

    }

}
    
 
