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
    var responder:PeripheralResponder!;
    var characteristics:[String:[CBCharacteristic]] = [:];
    var services:[String:CBService] = [:];
    
    func process(peripheral:CBPeripheral) {
        peripheral.delegate = self;
        
        let services = self.responder.discoverServices();
        peripheral.discoverServices(services);
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if let e = error {
            print("Encountered error while searching for services belonging to peripheral(\(peripheral.identifier.UUIDString)): \(e)");
        } else {
            for (service) in peripheral.services! {
                self.services[service.UUID.UUIDString] = service;
                
                let characs = self.responder.discoverCharacterisics(service);
                peripheral.discoverCharacteristics(characs, forService: service);
            }
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
                    print("\(characteristic.UUID.UUIDString) (\(characteristic.value))");
                    
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic);
                    peripheral.readValueForCharacteristic(characteristic);
                }
            } else {
                print("Invalid characteristics for service(\(UUID))");
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        self.responder.characteristicUpdated(characteristic, value: characteristic.value, peripheral: peripheral, delegate: self);
    }
}