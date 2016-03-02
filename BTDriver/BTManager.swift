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
    var central:CentralDelegate = CentralDelegate();
    var peripheral:PeripheralDelegate = PeripheralDelegate();
    var manager:CBCentralManager;
    
    
    override init () {
        self.manager = CBCentralManager(delegate: self.central, queue: dispatch_get_main_queue());
        super.init();
        
        self.central.responder = self;
        self.peripheral.responder = self;
    }
    
    func connectPeripheral() {
        if(Const.forceScan == true) {
            self.startScanning();
            return;
        }
        
        let ids:[NSUUID] = bluetoothIDs();
        let peripherals = self.manager.retrievePeripheralsWithIdentifiers(ids);

        if(peripherals.count > 0){
            print("Found registered peripherals, attempting to connect");
            self.connectToPeripherals(peripherals);
        } else {
            self.startScanning();
        }
    }

    func bluetoothAvailable() {
        print("Bluetooth 4.0 is available");
        self.connectPeripheral();
    }
    
    func bluetoothUnavailable() {
        print("Bluetooth 4.0 is unavailable, aborting");
        exit(0);
    }
    
    func didConnectPeripheral(peripheral: CBPeripheral) {
        print("Discovering \"\(peripheral.name!)\" services ... ");
        self.peripheral.process(peripheral);
    }
    
    func characteristicUpdated(characteristic: CBCharacteristic, value: NSData?, peripheral: CBPeripheral, delegate: PeripheralDelegate) {
        var decoded:Int = 0;
        if let data = value {
            if(characteristic.UUID.UUIDString == "FFF3") {
                var x = 0; var y = 0; var z = 0;
               
                data.getBytes(&y, range:  NSMakeRange(0, 1));
                data.getBytes(&x, range:  NSMakeRange(1, 1));
                data.getBytes(&z, range:  NSMakeRange(2, 1));
                
                print("X: \(x) Y: \(y) Z:\(z)");
            } else {
                value!.getBytes(&decoded, length: 2);
                print("\(characteristic.UUID.UUIDString): \(decoded)");
            }
        }
    }
    
    func connectToPeripherals(peripherals:[CBPeripheral]) {
        self.central.process(<#T##central: CBCentralManager##CBCentralManager#>)
        for peripheral in peripherals {
            self.manager.connectPeripheral(peripheral, options: nil);
            self.central.connecting.append(peripheral);
        }
    }
    
    func startScanning() {
        print("Scanning for available peripherals");
        self.manager.scanForPeripheralsWithServices(nil, options: nil);
    
        delay(Const.scanTime, cb: self.stopScanning);
    }
    
    func stopScanning() {
        self.manager.stopScan();
        print("Stopped scanning for available peripherals");
    }
}