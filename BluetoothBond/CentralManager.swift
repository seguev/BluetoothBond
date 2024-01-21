//
//  CentralManager.swift
//  BluetoothBond
//
//  Created by segev perets on 20/01/2024.
//

import CoreBluetooth
import UIKit


class CentralManager: NSObject, CBCentralManagerDelegate {
    
    weak var delegate: BluetoothManager?
    
//    let peripheralManager = PeripheralManager()
    
    var central: CBCentralManager?
    
    override init() {
        super.init()
        central = .init(delegate: self, queue: nil,options: [CBCentralManagerOptionShowPowerAlertKey: true])
        Logger.log(.info, "initializing central")
    }
    
    private var connectedPeripheral: CBPeripheral? {
        didSet {
            if let connectedPeripheral {
                delegate?.centralIsScanning = false
//                connectedPeripheral.delegate = peripheralManager
            }
        }
    }
    
    func startScanning() {
        Logger.log(.info, "Start scanning")
        central!.scanForPeripherals(withServices: [BluetoothManager.TransferService.serviceUUID])
    }
    
    func stopScanning() {
        Logger.log(.info, "Stop scanning")
        central!.stopScan()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        self.central = central
        
        switch central.state {
        case .poweredOn:
            
            if let connectedPeri = central.retrieveConnectedPeripherals(withServices: [BluetoothManager.TransferService.serviceUUID]).last {
                Logger.log(.info, "Already connected!")
                delegate?.centralIsScanning = false
                central.connect(connectedPeri)
            } else {
                delegate?.centralIsScanning = true
                Logger.log(.info, "Central is scanning")
                startScanning()
                
            }
        default:
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        guard let services = peripheral.services, !services.isEmpty else {return}
        
        Logger.log(.warning, "Found someone!",peripheral.name ?? "No name")
        
        services.forEach { service in
            if service == BluetoothManager.TransferService.serviceUUID {
                
                self.connectedPeripheral = peripheral
                
                self.stopScanning()
                delegate?.centralIsScanning = false
                
                central.connect(peripheral)
            } else {
                Logger.log(.info, "Not a match")
            }
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        Logger.log(.info, #function)
        
        central.scanForPeripherals(withServices: [BluetoothManager.TransferService.serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        Logger.log(.error, #function)
    }
    
    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        Logger.log(.info, #function,event == .peerConnected ? "peerConnected" : "peerDisconnected" )
    }
    
    
}


