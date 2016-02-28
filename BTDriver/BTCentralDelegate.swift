//
//  BTCentral.swift
//  BTDriver
//
//  Created by Alfred Cepeda on 2/27/16.
//  Copyright © 2016 Alfred Cepeda. All rights reserved.
//

import Foundation
import CoreBluetooth

class BTCentralDelegate : NSObject, CBCentralManagerDelegate {
    var delegate:BTManagerDelegate;
    var connecting:[String] = [];
    var connected:[CBPeripheral] = [];
    var discovered:[String] = [];
    
    var didConnectPeripheral:((CBPeripheral) -> ()) = { _ in print("Need to override BTCentral.didDiscoverPeripheral on: \(self)") };
    
    init(delegate:BTManagerDelegate) {
        self.delegate = delegate;
        
        super.init();
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch(central.state) {
        case .PoweredOn:
            self.delegate.bluetoothAvailable();
            break;
            
        case .Unsupported:
            self.delegate.bluetoothUnavailable();
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
        
        let shouldSkip = (self.connecting.indexOf(UUID) != nil && self.connected.indexOf(peripheral) != nil);
        let validUID = (Const.ignoreUIDs == true || Const.BT_UIDs.indexForKey(UUID) != nil);
        if( shouldSkip || validUID ) {
            print("Attemping to connect to: \(UUID)");
            central.connectPeripheral(peripheral, options: nil);
            self.connecting.append(UUID);
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        let UUID = peripheral.identifier.UUIDString;
        print("[\(UUID)] discovering services ... ");
        
        if let index = self.connecting.indexOf(UUID) {
            self.connecting.removeAtIndex(index);
        }
        
        self.didConnectPeripheral(peripheral);
        self.connected.append(peripheral);
        
        if(self.connected.count == Const.BT_UIDs.count) {
            central.stopScan();
        }
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Failed to connect: \(error)");
    }
}