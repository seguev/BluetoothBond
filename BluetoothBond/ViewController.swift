//
//  ViewController.swift
//  BluetoothBond
//
//  Created by segev perets on 20/01/2024.
//

import UIKit
import Combine
let printNotification: NSNotification.Name = .init(rawValue: "printNotification")
class ViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var debuggingTextView: UITextView!
    
    let manager = BluetoothManager()
    var listeners = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        NotificationCenter.default.addObserver(self, selector: #selector(printToUserLog), name: printNotification, object: nil)
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
    
    @objc func printToUserLog(_ notification:Notification) {
        let content = notification.object as! String
        debuggingTextView.text += content+"\n"
    }
    

}

func printToUser(_ content:String) {
    NotificationCenter.default.post(name: printNotification, object: content)
}
