//
//  BTCentral.swift
//  BTDriver
//
//  Created by Alfred Cepeda on 2/27/16.
//  Copyright © 2016 Alfred Cepeda. All rights reserved.
//

import Foundation
import CoreBluetooth

class CentralDelegate : NSObject, CBCentralManagerDelegate {
    var central:CBCentralManager!;
    var responder:CentralResponder?;
    var connecting:[CBPeripheral] = [];
    var connected:[CBPeripheral] = [];
    var discovered:[String] = [];

    override init() {
        super.init();
        
        self.central = CBCentralManager(delegate: self, queue: dispatch_get_main_queue());
    }

    func process(ids:[NSUUID]) {
        let peripherals = self.central.retrievePeripheralsWithIdentifiers(ids);
        
        if(peripherals.count > 0){
            print("Found registered peripherals, attempting to connect");
            self.connectToPeripherals(peripherals);
        } else {
            self.startScanning();
        }
    }
    
    func connectToPeripherals(peripherals:[CBPeripheral]) {
        for peripheral in peripherals {
            self.central.connectPeripheral(peripheral, options: nil);
            self.connecting.append(peripheral);
        }
    }
    
    func startScanning() {
        print("Scanning for available peripherals");
        self.central.scanForPeripheralsWithServices(nil, options: nil);
        
        delay(Const.scanTime, cb: self.stopScanning);
    }
    
    func stopScanning() {
        self.central.stopScan();
        print("Stopped scanning for available peripherals");
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if let delegate = self.responder {
            switch(central.state) {
                case .PoweredOn:
                    delegate.bluetoothAvailable();
                break;
            
                case .Unsupported:
                    delegate.bluetoothUnavailable();
                break;
            
                default:
                    print("Need to support state: \(central.state.rawValue)");
                break;
            }
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject],RSSI: NSNumber) {
        let UUID = peripheral.identifier.UUIDString;
        
        if(self.discovered.indexOf(UUID) != nil) {
            return;
        }
        
        self.discovered.append(UUID);
        print("Discovered: \"\(peripheral.name!)\" Identifier: \"\(UUID)\"");
        
        let shouldSkip = (self.connecting.indexOf(peripheral) != nil && self.connected.indexOf(peripheral) != nil);
        let validUID = (Const.connectAll == true || Const.devices.indexOf({ $0.UUID == UUID }) != nil);
        
        if( shouldSkip || validUID ) {
            print("Attemping to connect to: \"\(peripheral.name!)\"");
            central.connectPeripheral(peripheral, options: nil);
            self.connecting.append(peripheral);
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Connected to \"\(peripheral.name!)\"!");
        
        if let index = self.connecting.indexOf(peripheral) {
            self.connecting.removeAtIndex(index);
        }
        
        if let delegate = self.responder {
            delegate.didConnectPeripheral(peripheral);
        }
        
        self.connected.append(peripheral);
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Failed to connect: \(error)");
    }
}