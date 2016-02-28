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
    func characteristicUpdated(characteristic: CBCharacteristic!, withValue value:NSData!, fromPeripheral peripheral:CBPeripheral);
    func peripheralScanned(peripheral: CBPeripheral, withCharacteristics characteristics: [String:[CBCharacteristic]]);
    func bluetoothAvailable();
    func bluetoothUnavailable();
}

class BTManager: NSObject, CBPeripheralDelegate {
    var manager:CBCentralManager;
    var central:CentralDelegate;
    var delegate:BTManagerDelegate;
    var services:[String:CBService] = [:];
    var characteristics:[String:[CBCharacteristic]] = [:];

    
    init (delegate:BTManagerDelegate) {
        self.delegate = delegate;
        self.central = CentralDelegate(delegate: delegate);
        self.manager = CBCentralManager(delegate: central, queue: dispatch_get_main_queue());
        
        super.init();
//        peripheral.delegate = self;
 //       peripheral.discoverServices(serviceIDs.keys.map{ CBUUID(string: $0) });
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
    
    func connectToPeripherals(peripherals:[CBPeripheral]) {
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
    
    func bluetoothIDs() -> [NSUUID] {
        return Const.BT_UIDs.keys.map { NSUUID(UUIDString: $0)! };
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        delegate.characteristicUpdated(characteristic, withValue: characteristic.value, fromPeripheral: peripheral);
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if(characteristics[service.UUID.UUIDString] == nil) {
            characteristics[service.UUID.UUIDString] = [];
        }
        
        if let e = error {
            print("Encountered error while searching for characteristics belonging to service(\(service.UUID.UUIDString)): \(e)");
            print("Service belongs to peripheral(\(peripheral.identifier.UUIDString))");
        } else {
            for (characteristic) in service.characteristics!{
                characteristics[service.UUID.UUIDString]!.append(characteristic);
            }
        }
        
        if(services.count == characteristics.count) {
            print("Discovered all available characteristics for peripheral");
            delegate.peripheralScanned(peripheral, withCharacteristics: characteristics);
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if let e = error {
            print("Encountered error while searching for services belonging to peripheral(\(peripheral.identifier.UUIDString)): \(e)");
        } else {
            for (service) in peripheral.services! {
                services[service.UUID.UUIDString] = service;
                peripheral.discoverCharacteristics(nil, forService: service);
            }
        }
    }
}