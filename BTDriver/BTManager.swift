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
    var central:BTCentralDelegate;
    var delegate:BTManagerDelegate;
    var services:[String:CBService] = [:];
    var characteristics:[String:[CBCharacteristic]] = [:];

    
    init (delegate:BTManagerDelegate) {
        self.delegate = delegate;
        self.central = BTCentralDelegate(delegate: delegate);
        self.manager = CBCentralManager(delegate: central, queue: dispatch_get_main_queue());
        
        super.init();
//        peripheral.delegate = self;
 //       peripheral.discoverServices(serviceIDs.keys.map{ CBUUID(string: $0) });
    }
    
    func connectPeripheral() {
        if(Const.ignoreUIDs == true) {
            self.connectToAny();
            return;
        }
        
        let ids:[NSUUID] = bluetoothIDs();
        let peripherals = self.manager.retrievePeripheralsWithIdentifiers(ids);

        if(peripherals.count > 0){
            print("Found registered peripherals, attempting to connect");
            self.connectToPeripherals(peripherals);
        } else {
            self.connectToAny();
        }
    }
    
    func connectToPeripherals(peripherals:[CBPeripheral]) {
        for peripheral in peripherals {
            let UUID = peripheral.identifier.UUIDString;
            self.manager.connectPeripheral(peripheral, options: nil);
            self.central.connecting.append(UUID);
        }
    }
    
    func connectToAny() {
        print("Scanning for an available peripheral");
        self.manager.scanForPeripheralsWithServices(nil, options: nil);
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