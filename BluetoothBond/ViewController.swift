//
//  ViewController.swift
//  BluetoothBond
//
//  Created by segev perets on 20/01/2024.
//

import UIKit

class ViewController: UIViewController, BluetoothManagerDelegate {

    @IBOutlet weak var debuggingTextView: UITextView!
    let manager = BluetoothManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        
    }

    
    
    
    
    

}

