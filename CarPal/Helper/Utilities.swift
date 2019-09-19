//
//  Utilities.swift
//  CarPal
//
//  Created by Daniel Lee on 9/16/19.
//  Copyright © 2019 Daniel Lee. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    static func styleTextField(_ textfield:UITextField){
        // create the bottom line
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height: 2)
        bottomLine.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        
        //remove border of text field
        textfield.borderStyle = .none
        
        //add the line to the text field
        textfield.layer.addSublayer(bottomLine)
    }
    
    static func styleFilledButton(_ button:UIButton) {
        //filled rounded corner style
        button.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        button.layer.cornerRadius = 20.0
        button.tintColor = UIColor.white
    }
    
    static func styleHollowButton(_ button:UIButton) {
        
        // Hollow rounded corner style
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 20.0
        button.tintColor = UIColor.black
    }
    
    static func isPasswordValid(_ password : String) -> Bool {
        let testing = NSPredicate(format: "Self Matches %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return testing.evaluate(with: password)
    }
}

