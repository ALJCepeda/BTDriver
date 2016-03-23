//
//  BTManager.swift
//  BTDriver
//
//  Created by Alfred Cepeda on 7/18/15.
//  Copyright (c) 2015 Alfred Cepeda. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BTManagerDelegate {
    func characteristicUpdated(characteristic: CBCharacteristic!, value:NSData!, peripheral:CBPeripheral);
}

class BTManager: NSObject, PeripheralResponder, CentralResponder {
    var bluetooth:Bluetooth;
    var central:CentralDelegate = CentralDelegate();
    var peripheral:PeripheralDelegate = PeripheralDelegate();
    var console:Console = Console();

    var readers:[String:DataReader] = [:];
    
    init(bluetooth:Bluetooth) {
        self.bluetooth = bluetooth;
        super.init();
        
        self.central.responder = self;
        self.peripheral.responder = self;
    }
    
    func connectBluetooth() {
        if let UUID = NSUUID(UUIDString: bluetooth.UUID) {
            self.central.process(UUID);
        } else {
            print("Bluetooth has invalid UUID");
        }
    }

    func bluetoothAvailable() {
        print("Bluetooth 4.0 is available");
        self.connectBluetooth();
    }
    
    func bluetoothUnavailable() {
        print("Bluetooth 4.0 is unavailable, aborting");
        exit(0);
    }
    
    func didConnectPeripheral(peripheral: CBPeripheral) {
        print("Discovering \"\(peripheral.name!)\" services ... ");
        self.peripheral.process(peripheral);
    }
    
    func discoverServices() -> [CBUUID] {
        return self.bluetooth.services.map{ CBUUID(string: $0.UUID) };
    }
    
    func discoverCharacterisics(service: CBService) -> [CBUUID]? {
        if let service = self.bluetooth.serviceWithUUID(service.UUID.UUIDString) {
            return service.characteristics.map { CBUUID(string: $0.UUID) };
        }
        
        return nil;
    }
    
    func didDiscoverCharacteristic(characteristic: CBCharacteristic, forService service: CBService) {
        if let service = self.bluetooth.serviceWithUUID(service.UUID.UUIDString) {
            if let charac = service.characteristicWithUUID(characteristic.UUID.UUIDString) {
                self.readers[charac.UUID] = DataReader(characteristic: charac);
            }
        }
    }
    
    func characteristicUpdated(characteristic: CBCharacteristic, value: NSData?, peripheral: CBPeripheral, delegate: PeripheralDelegate) {
        
        if let reader = self.readers[characteristic.UUID.UUIDString] {
            if let data = value {
                let val = reader.read(data);
                self.parseValue(val);
            }
        }
    }
    
    func parseValue(val:AnyObject?) {
        if let hashmap = val as? [String:Int] {
            for (key, value) in hashmap {
                console.stdout("\(key): \(value) ");
            }
            
            console.stdout("\n");
        }
    }
}