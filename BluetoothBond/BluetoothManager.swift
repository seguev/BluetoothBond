//
//  BTManager.swift
//  BluetoothBond
//
//  Created by segev perets on 20/01/2024.
//

import UIKit
import CoreBluetooth

protocol BluetoothManagerDelegate: ViewController {
    
}

class BluetoothManager {
    
    weak var delegate: BluetoothManagerDelegate?
    
    enum TransferService {
        static let serviceUUID = CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961")
        static let characteristicUUID = CBUUID(string: "08590F7E-DB05-467E-8757-72F6FAEB13D4")
    }
    
    let centralManager = CentralManager()
    let peripheralManager = PeripheralManager()
    
    func log(_ text:String) {
        delegate?.debuggingTextView.text += "\n"+text
    }
    
    init(delegate: BluetoothManagerDelegate? = nil) {
        self.delegate = delegate
        self.centralManager.delegate = self
        self.peripheralManager.delegate = self
    }
 

}
