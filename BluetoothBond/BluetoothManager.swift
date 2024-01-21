//
//  BTManager.swift
//  BluetoothBond
//
//  Created by segev perets on 20/01/2024.
//

import UIKit
import CoreBluetooth
import Combine

class BluetoothManager {
    
    @Published var isScanning: Bool = false
    
    var centralIsScanning: Bool = false {
        didSet {
            isScanning = centralIsScanning && peripheralIsScanning
        }
    }
    
    var peripheralIsScanning: Bool = false{
        didSet {
            isScanning = centralIsScanning && peripheralIsScanning
        }
    }
    
    enum TransferService {
        static let serviceUUID = CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961")
        static let characteristicUUID = CBUUID(string: "08590F7E-DB05-467E-8757-72F6FAEB13D4")
    }
    
    let centralManager = CentralManager()
    let peripheralManager = PeripheralManager()
    
    

    

}
