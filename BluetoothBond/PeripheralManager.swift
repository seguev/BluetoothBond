//
//  PeripheralManager.swift
//  BluetoothBond
//
//  Created by segev perets on 20/01/2024.
//

import Foundation
import CoreBluetooth


class PeripheralManager: NSObject, CBPeripheralDelegate, CBPeripheralManagerDelegate {
    
    weak var delegate: BluetoothManager?
    
    var peripheralManager: CBPeripheralManager?
    var name: String = "No name"
    
    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey: true])
    }
    
    var transferCharacteristic : CBMutableCharacteristic?
    
    var connectedCentral: CBCentral?
    
    var recievedData: Data?
    
    //MARK: setup
    private func setupPeripheral() {
        Logger.log(.info, "Peri is being prepared")
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
        peripheralManager?.add(transferService)
        Logger.log(.info, "Peri is ready for advertizing")
    }
    
    func startAdvertising() {
        peripheralManager?.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [BluetoothManager.TransferService.serviceUUID]
                                             ,CBAdvertisementDataLocalNameKey:self.name])

        Logger.log(.info, "Peri is advertizing")
    }
    
    func stopAdvertising() {
        Logger.log(.warning, "Peri did stop advertizing")
        peripheralManager?.stopAdvertising()
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
            Logger.log(.error,#function,error)
        }
        Logger.log(.info, "Some one is trying to connect to peri")
        
        guard let services = peripheral.services else {print("no services!");return}
        
        Logger.log(.info, "Found services")
        for service in services {
            peripheral.discoverCharacteristics([BluetoothManager.TransferService.characteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error {
            Logger.log(.error,#function,error)
        }
        guard let characteristics = service.characteristics else {print("No characteristics!");return}
        Logger.log(.info, "Found characteristics!")
        guard let char = characteristics.filter({ $0.uuid == BluetoothManager.TransferService.characteristicUUID }).first else {
            Logger.log(.warning, "Got characteristics but could not match")
            return
        }
        Logger.log(.info, "Listening to char")
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
            Logger.log(.error,#function,"ho no its more than one chunk")
            fatalError()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error {
            Logger.log(.error,#function,error)
        }
        guard let data = characteristic.value else {Logger.log(.error, "No data");return}
        Logger.log(.info, "Got data!")
        Logger.log(.info,String(data: data, encoding: .utf8) ?? "no data")
        
        self.recievedData = data
    }
    
    
}
