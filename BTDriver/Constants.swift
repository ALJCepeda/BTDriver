//
//  Constants.swift
//  BTDriver
//
//  Created by Alfred Cepeda on 7/15/15.
//  Copyright (c) 2015 Alfred Cepeda. All rights reserved.
//

import Foundation

class Const {
    static let forceScan = true;
    static let connectAll = false;
    static let scanTime = 5.0; //seconds
    static let devices = [
        Bluetooth(name: "VStroker", UUID: "E307093E-C17A-4654-BA94-57481F8A3230", services: [
            Service(name: "Accelerometer", UUID: "FFF0", characteristics: [
                Characteristic(name:"3D", UUID:"FFF3", type: "bytearray", parse: [
                    Byte(name: "x", length: 1),
                    Byte(name: "y", length: 1),
                    Byte(name: "z", length: 1)
                ])
            ])
        ])
    ];
}