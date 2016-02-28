//
//  Driver.swift
//  BTDriver
//
//  Created by Alfred Cepeda on 7/16/15.
//  Copyright (c) 2015 Alfred Cepeda. All rights reserved.
//

import Foundation
import CoreBluetooth

class UBTDriver : BTManagerDelegate {
    var manager:BTManager!;
    
    init() {
        self.manager = BTManager(delegate:self);
    }
    
    func run() {
        NSRunLoop.currentRunLoop().run();
    }
    
    func characteristicUpdated(characteristic: CBCharacteristic!, withValue value: NSData!, fromPeripheral peripheral: CBPeripheral) {
        var decoded:Int = 0;
        value.getBytes(&decoded, length: 2);
        print("\(characteristic.UUID.UUIDString): \(decoded)");
    }
    
    func peripheralScanned(peripheral: CBPeripheral, withCharacteristics services: [String : [CBCharacteristic]]) {
        for (UUID, characteristics) in services {
            print("----------Registering to service: \(UUID)----------");

            for characteristic in characteristics {
                peripheral.setNotifyValue(true, forCharacteristic: characteristic);
                peripheral.readValueForCharacteristic(characteristic);
                print("\(characteristic.UUID.UUIDString) (\(characteristic.value))");
            }
        }
    }
    
    func outputServices(services: [String: [CBCharacteristic]]) {
        for (UUID, characteristics) in services {
            print("Service(\(UUID)) is available with \(characteristics.count) characteristics: ");
            
            for (characteristic) in characteristics {
                print("\(characteristic.UUID.UUIDString)");
            }
        }
    }
    
    func bluetoothAvailable() {
        print("Bluetooth 4.0 is available");
        self.manager.connectPeripheral();
    }
    
    func bluetoothUnavailable() {
        print("Bluetooth 4.0 is unavailable, closing driver");
        exit(0);
    }
}