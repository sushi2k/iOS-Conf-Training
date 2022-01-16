//
//  MyLabel.swift
//  iOS-Shack-v2
//
//  Created by Sven on 31/8/20.
//  Copyright © 2020 Sven. All rights reserved.
//

import Foundation

import UIKit

  class MyLabel: UILabel {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeLabel()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeLabel()
    }

    func initializeLabel() {

        self.textAlignment = .left
        self.font = UIFont(name: "Halvetica", size: 17)
        self.textColor = UIColor.black

    }

}
