//
//  Driver.swift
//  BTDriver
//
//  Created by Alfred Cepeda on 7/16/15.
//  Copyright (c) 2015 Alfred Cepeda. All rights reserved.
//

import Foundation
import CoreBluetooth

class Driver : BTManagerDelegate {
    var manager:BTManager!;
    
    func run() {
        manager = BTManager();
        manager.delegate = self;
        
        NSRunLoop.currentRunLoop().run();
    }
    
    func outputServices(services: [String: [CBCharacteristic]]) {
        for (UUID, characteristics) in services {
            print("Service(\(UUID)) is available with \(characteristics.count) characteristics: ");
            
            for (characteristic) in characteristics {
                print("\(characteristic.UUID.UUIDString)");
            }
        }
    }
    
    func characteristicUpdated(characteristic: CBCharacteristic!, withValue value: NSData!, fromPeripheral peripheral: CBPeripheral) {
        print("\(characteristic.UUID.UUIDString): \(value)");
    }
    
    func peripheralScanned(peripheral: CBPeripheral, withCharacteristics services: [String : [CBCharacteristic]]) {
        outputServices(services);
        let UUID = services.keys.first!;
        print("Registering to service: \(UUID)");
    
        for characteristic in services[UUID]! {
            peripheral.setNotifyValue(true, forCharacteristic: characteristic);
            print("Default \(characteristic.UUID.UUIDString): \(characteristic.value)");
            peripheral.readValueForCharacteristic(characteristic);
        }
    }
    
    func bluetoothAvailable(manager: BTManager!) {
        print("Bluetooth 4.0 is available, attempting to connect to peripheral: \(Const.BT_UID)");
        manager.connectPeripheral();
    }
    
    func bluetoothUnavailable(manager: BTManager!) {
        print("Bluetooth 4.0 is unavailable, closing driver");
        exit(0);
    }
}