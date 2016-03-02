//
//  PeripheralDelegate.swift
//  BTDriver
//
//  Created by Alfred Cepeda on 3/1/16.
//  Copyright © 2016 Alfred Cepeda. All rights reserved.
//

import Foundation
import CoreBluetooth

class PeripheralDelegate : NSObject, CBPeripheralDelegate  {
    var responder:PeripheralResponder?;
    var characteristics:[String:[CBCharacteristic]] = [:];
    var services:[String:CBService] = [:];
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let delegate = self.responder {
            delegate.characteristicUpdated(characteristic, value: characteristic.value, peripheral: peripheral, delegate: self);
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        let UUID = service.UUID.UUIDString;
        if(self.characteristics[UUID] == nil) {
            self.characteristics[UUID] = [];
        }
        
        if let e = error {
            print("Encountered error while searching for characteristics belonging to service(\(UUID)): \(e)");
            print("Service belongs to peripheral(\(peripheral.identifier.UUIDString))");
        } else {
            print("----------Registering to service: \(UUID)----------");
            if let characteristics = service.characteristics {
                self.characteristics[UUID] = characteristics;
                
                for characteristic in characteristics {
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic);
                    peripheral.readValueForCharacteristic(characteristic);
                    print("\(characteristic.UUID.UUIDString) (\(characteristic.value))");
                }
            } else {
                print("Invalid characteristics for service(\(UUID))");
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if let e = error {
            print("Encountered error while searching for services belonging to peripheral(\(peripheral.identifier.UUIDString)): \(e)");
        } else {
            for (service) in peripheral.services! {
                self.services[service.UUID.UUIDString] = service;
                peripheral.discoverCharacteristics(nil, forService: service);
            }
        }
    }
}