//
//  ViewController.swift
//  Example
//
//  Created by Giáp Trần on 1/8/17.
//  Copyright © 2017 Giáp Trần. All rights reserved.
//

import UIKit
import NotificationBar

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationBar.shared.selectHandler = { [weak self] _ in
            guard let _ = self else { return }
            
            print("SelectHandler")
        }
        NotificationBar.shared.sendHandler = { [weak self] (text) in
            guard let _ = self else { return }
            
            print("SendHandler: \(text)")
        }
    }

    deinit {
        NotificationBar.shared.selectHandler = nil
        NotificationBar.shared.sendHandler = nil
    }

    @IBAction func showAlertAction(_ sender: Any) {
        NotificationBar.shared.showNotification(title: "Notification", message: "Hello world")
    }
    
    @IBAction func showBannerAction(_ sender: Any) {
        NotificationBar.shared.showNotification(title: "Notification", message: "Hello world", style: .banner)
    }
    

}

