//
//  CentralManager.swift
//  BluetoothBond
//
//  Created by segev perets on 20/01/2024.
//

import Foundation
import CoreBluetooth
import UIKit

protocol CentralManagerDelegate: BluetoothManager {
    func log(_ text:String)
}


class CentralManager: NSObject, CBCentralManagerDelegate {
    
    weak var delegate: BluetoothManager?
    
    override init() {
        super.init()
        central = .init(delegate: self, queue: nil)
        delegate?.log("1. Central initialized")
    }
    
    var central: CBCentralManager?
    
    let peripheralManager = PeripheralManager()
    
    private var peripheral: CBPeripheral? {
        didSet {
            if let peripheral {
                peripheral.delegate = peripheralManager
            }
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        delegate?.log("2. Initial func is being called")
        self.central = central
        
        switch central.state {
        case .poweredOn:
            delegate?.log("3. State == ON")
            if let connectedPeri = central.retrieveConnectedPeripherals(withServices: [BluetoothManager.TransferService.serviceUUID]).last {
                
                central.connect(connectedPeri)
            } else {
                delegate?.log("4. scanning for peripherals")
                central.scanForPeripherals(withServices: nil)
//                central.scanForPeripherals(withServices: [BluetoothManager.TransferService.serviceUUID])
            }
        default:
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let services = peripheral.services, !services.isEmpty else {return}
        delegate?.log("5. Discovering peripherals")
        print(peripheral.identifier)
        if let services = peripheral.services {
            print("With services:")
            services.forEach { service in
                if service == BluetoothManager.TransferService.serviceUUID {
                    print("Match!")
                    delegate?.log("Found device with appropriate services")
                    
                    self.peripheral = peripheral
                    
                    central.stopScan()
                    
                    delegate?.log("Connecting to it..")
                    central.connect(peripheral)
                } else {
                    print("Not a match..")
                }
            }
        }
//        guard RSSI.intValue >= -50 else {return}
        
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        delegate?.log("Connected")
        
        central.scanForPeripherals(withServices: [BluetoothManager.TransferService.serviceUUID])
    }
    
    
    
}


