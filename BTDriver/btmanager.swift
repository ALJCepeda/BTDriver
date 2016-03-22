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
    
    func characteristicUpdated(characteristic: CBCharacteristic, value: NSData?, peripheral: CBPeripheral, delegate: PeripheralDelegate) {
        var decoded:Int = 0;
        if let data = value {
            if(characteristic.UUID.UUIDString == "FFF3") {
                var x = 0; var y = 0; var z = 0;
               
                data.getBytes(&x, range: NSMakeRange(0, 1));
                data.getBytes(&y, range: NSMakeRange(1, 1));
                data.getBytes(&z, range: NSMakeRange(2, 1));
                
                print("X: \(x) Y: \(y) Z:\(z)");
            } else {
                value!.getBytes(&decoded, length: 2);
                print("\(characteristic.UUID.UUIDString): \(decoded)");
            }
        }
    }
}