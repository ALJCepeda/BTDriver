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
    var responder:CentralResponder?;
    var connecting:[CBPeripheral] = [];
    var connected:[CBPeripheral] = [];
    var discovered:[String] = [];
    
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
        let validUID = (Const.connectAll == true || Const.BT_UIDs.indexForKey(UUID) != nil);
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