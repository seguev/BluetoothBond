//
//  ViewController.swift
//  BluetoothBond
//
//  Created by segev perets on 20/01/2024.
//

import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var debuggingTextView: UITextView!
    
    let manager = BluetoothManager()
    var listeners = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    func bind() {
        manager.$isScanning.sink { [weak self] isScanning in
            guard let self else {return}
            DispatchQueue.main.async {
                if isScanning {
                    self.activityIndicator.startAnimating()
                } else {
                    self.activityIndicator.stopAnimating()
                }
            }
        }.store(in: &listeners)
        
        
    }
    
    
    
    
    

}

