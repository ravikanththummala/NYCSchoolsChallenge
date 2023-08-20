//
//  AlertController.swift
//  08201990-Ravikanth-Thummala-NYCSchools
//
//  Created by Ravikanth Thummala on 8/20/23.
//

import Foundation
import UIKit

class AlertController {
    static func showTextAlert(on vc: UIViewController, with title: String, with message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
}
