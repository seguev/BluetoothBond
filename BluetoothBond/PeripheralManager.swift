//
//  PeripheralManager.swift
//  BluetoothBond
//
//  Created by segev perets on 20/01/2024.
//

import Foundation
import CoreBluetooth

protocol PeripheralManagerDelegate: BluetoothManager {
    
}

class PeripheralManager: NSObject, CBPeripheralDelegate, CBPeripheralManagerDelegate {
    
    weak var delegate: BluetoothManager?
    
    var peripheralManager: CBPeripheralManager?
    
    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey: true])
        delegate?.log("5. Peripheral initialized")
    }
    
    var transferCharacteristic : CBMutableCharacteristic?
    
    var connectedCentral: CBCentral?
    
    var recievedData: Data?
    
    //MARK: setup
    private func setupPeripheral() {
        delegate?.log("6. setupPeripheral")
        //initialize a new mutable characterstic
        transferCharacteristic = CBMutableCharacteristic(type: BluetoothManager.TransferService.characteristicUUID,
                                                         properties: [.notify,.writeWithoutResponse],
                                                         value: nil,
                                                         permissions: [.readable,.writeable])
        
        //initialize a new transfer service
        let transferService = CBMutableService(type: BluetoothManager.TransferService.serviceUUID, primary: true)
        
        
        //add characteristic service
        transferService.characteristics = [transferCharacteristic!] //force unwrap cause the init is literaly 2 lines above
        
        //add service to central
        peripheralManager!.add(transferService)
        startAdvertising()
        
    }
    
    func startAdvertising() {
        delegate?.log("7. startAdvertising")
        peripheralManager!.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [BluetoothManager.TransferService.serviceUUID]])
        print("Peripheral is advertizing!")
    }
    
    func stopAdvertising() {
        peripheralManager!.stopAdvertising()
    }
    
    //MARK: Delegate funcs
    
    ///being called when peripheral is being initialized
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .unsupported:
            print("unsupported")
        case .unauthorized:
            print("unauthorized")
        case .poweredOff:
            print("poweredOff")
        case .poweredOn:
            print("poweredOn")
            setupPeripheral()
        default:
            fatalError("hah?")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error {
            print(error)
        }
        print("peripheral did discover")
        
        guard let services = peripheral.services else {print("no services!");return}
        print("Found services")
        
        for service in services {
            peripheral.discoverCharacteristics([BluetoothManager.TransferService.characteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error {
            print(error)
        }
        guard let characteristics = service.characteristics else {print("No characteristics!");return}
        print("Found characteristics!")
        
        guard let char = characteristics.filter({ $0.uuid == BluetoothManager.TransferService.characteristicUUID }).first else {
            print("Got characteristics but could not match")
            return
        }
        
        print("Listening to char")
        peripheral.setNotifyValue(true, for: char)
    }
    
    
    
    //MARK: Data handlers
    
    func sendData(_ recievedData:Data) {
        
        guard let transferCharacteristic else {fatalError("You need to set the characteristics global variable")}
        
        print("Message To Send\n",String(data: recievedData, encoding: .utf8) ?? "Empty Message")
        
        let messageLength = recievedData.count
        print("recieved data length:", messageLength)
        
        guard let maximumLength = connectedCentral?.maximumUpdateValueLength else {
            print("Nobody's connected...")
            return
        }
        
        print("maximumUpdateValueLength:",maximumLength)
        
        let isOneChunk = messageLength <= maximumLength
        if isOneChunk {
            print("Its one chunk")
            
            let didSend = peripheralManager!.updateValue(recievedData,
                                          for: transferCharacteristic,
                                          onSubscribedCentrals: nil)
            
            print(didSend ? "Sent!" : "Did not send!")
            
        } else {
            fatalError("ho no its more than one chunk")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error {
            print(error)
        }
        guard let data = characteristic.value else {print("No data");return}
        print("Got data")
        
        self.recievedData = data
    }
    
    
}
