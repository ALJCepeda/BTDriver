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
    func bluetoothAvailable(manager: BTManager!);
    func bluetoothUnavailable(manager: BTManager!);
}

class BTManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var manager:CBCentralManager!;
    var services:[String:CBService] = [:];
    var characteristics:[String:[CBCharacteristic]] = [:];
    var connecting:[String] = [];
    var discovered:[String] = [];
    var connected:Int = 0;
    var delegate:BTManagerDelegate!;
    
    override init () {
        super.init();
        
        manager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue());
    }
    
    func connectPeripheral() {
        let ids:[NSUUID] = bluetoothIDs();
        let peripherals = self.manager.retrievePeripheralsWithIdentifiers(ids);

        if(peripherals.count > 0){
            print("Found registered peripherals, attempting to connect");
            
            for peripheral in peripherals {
                let UUID = peripheral.identifier.UUIDString;
                self.manager.connectPeripheral(peripheral, options: nil);
                self.connecting.append(UUID);
            }
        } else {
            print("Scanning for an available peripheral");
            self.manager.scanForPeripheralsWithServices(nil, options: nil);
        }
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
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch(central.state) {
            case .PoweredOn:
                delegate.bluetoothAvailable(self);
            break;
            
            case .Unsupported:
                delegate.bluetoothUnavailable(self);
            break;
            
            default:
                print("Need to support state: \(central.state.rawValue)");
            break;
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject],RSSI: NSNumber) {
        let UUID = peripheral.identifier.UUIDString;
        
        if(self.discovered.indexOf(UUID) != nil) {
            return;
        }
        
        self.discovered.append(UUID);
        print("Discovered: \"\(peripheral.name!)\" Identifier: \"\(UUID)\"");
        
        if(Const.BT_UIDs.indexForKey(UUID) != nil && self.connecting.indexOf(UUID) != nil) {
            print("Attemping to connect to: \(UUID)");
            self.manager.connectPeripheral(peripheral, options: nil);
            self.connecting.append(UUID);
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        let UUID = peripheral.identifier.UUIDString;
        print("[\(UUID)] discovering services ... ");
        
        if let index = self.connecting.indexOf(UUID) {
            self.connecting.removeAtIndex(index);
        }
        
        if let serviceIDs = Const.BT_UIDs[UUID] {
            peripheral.delegate = self;
            peripheral.discoverServices(serviceIDs.keys.map{ CBUUID(string: $0) });
            self.connected++;
        }
        
        if(self.connected == Const.BT_UIDs.count) {
            self.manager.stopScan();
        }
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Failed to connect: \(error)");
    }
    
}