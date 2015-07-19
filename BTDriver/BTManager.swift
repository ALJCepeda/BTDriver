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
    var discovered:CBPeripheral!;
    var services:[String:CBService] = [:];
    var characteristics:[String:[CBCharacteristic]] = [:];
    
    var delegate:BTManagerDelegate!;
    
    override init () {
        super.init();
        
        manager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue());
    }
    
    func connectPeripheral() {
        var ids:[AnyObject] = [NSUUID(UUIDString: Const.BT_UID)!];
        var peripherals = manager.retrievePeripheralsWithIdentifiers(ids);
        
        if(peripherals.count > 0){
            println("Found \(peripherals.count) previously connected peripheral, attempting to reconnect");
            if let peripheral = peripherals[0] as? CBPeripheral {
                discovered = peripheral;
                manager.connectPeripheral(discovered, options: nil);
            } else {
                println("Unrecognized type provided");
            }
        } else {
            println("Scanning for an available peripheral");
            manager.scanForPeripheralsWithServices(nil, options: nil);
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        delegate.characteristicUpdated(characteristic, withValue: characteristic.value, fromPeripheral: peripheral);
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        if(characteristics[service.UUID.UUIDString] == nil) {
            characteristics[service.UUID.UUIDString] = [];
        }
        
        if let e = error {
            println("Encountered error while searching for characteristics belong to service(\(service.UUID.UUIDString)): \(e)");
            println("Service belongs to peripheral(\(peripheral.identifier.UUIDString))");
        } else {
            for (characteristic) in service.characteristics as! [CBCharacteristic] {
                characteristics[service.UUID.UUIDString]!.append(characteristic);
            }
        }
        
        if(services.count == characteristics.count) {
            println("Discovered all available characteristics for peripheral");
            delegate.peripheralScanned(peripheral, withCharacteristics: characteristics);
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        if let e = error {
            println("Encountered error while searching for services belonging to peripheral(\(peripheral.identifier.UUIDString)): \(e)");
        } else {
            for (service) in peripheral.services as! [CBService] {
                services[service.UUID.UUIDString] = service;
                peripheral.discoverCharacteristics(nil, forService: service);
            }
        }
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        switch(central.state) {
            case .PoweredOn:
                delegate.bluetoothAvailable(self);
            break;
            
            case .Unsupported:
                delegate.bluetoothUnavailable(self);
            break;
            
            default:
                println("Need to support state: \(central.state.rawValue)");
            break;
        }
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!,RSSI: NSNumber!) {
        if(peripheral.identifier.UUIDString == Const.BT_UID) {
            println("Discovered: \(peripheral)");
            println("Attemping to connect");
            discovered = peripheral;
            manager.stopScan();
            manager.connectPeripheral(discovered, options: nil);
            
        }
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        println("Connected to peripheral, discovering services");
        discovered.delegate = self;
        discovered.discoverServices(nil);
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("Failed to connect: \(error)");
    }
    
}