//
//  PeripheralResponder.swift
//  BTDriver
//
//  Created by Alfred Cepeda on 3/1/16.
//  Copyright © 2016 Alfred Cepeda. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol PeripheralResponder {
    func discoverServices() -> [CBUUID];
    func discoverCharacterisics(service:CBService) -> [CBUUID]?;
    func characteristicUpdated(characteristic:CBCharacteristic, value:NSData?, peripheral:CBPeripheral, delegate:PeripheralDelegate);
}