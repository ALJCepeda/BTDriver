//
//  ServiceDescription.swift
//  BTDriver
//
//  Created by Alfred Cepeda on 3/2/16.
//  Copyright © 2016 Alfred Cepeda. All rights reserved.
//

import Foundation
import CoreBluetooth

class Byte {
    var name = "";
    var length = 0;
    
    init(name:String, length:Int) {
        self.name = name;
        self.length = length;
    }
}

class Bluetooth {
    var name = "";
    var UUID = "";
    var services:[Service] = [];
    
    init(name:String, UUID:String, services:[Service]) {
        self.name = name;
        self.UUID = UUID;
        self.services = services;
    }
    
    func serviceWithUUID(UUID:String) -> Service? {
        return self.services.find{ $0.UUID == UUID };
    }
}

class Service {
    var name = "";
    var UUID = "";
    var characteristics:[Characteristic] = [];
    
    init(name:String, UUID:String, characteristics:[Characteristic]) {
        self.name = name;
        self.UUID = UUID;
        self.characteristics = characteristics;
    }
}

class Characteristic {
    var name = "";
    var type = Bytetype.None;
    var UUID = "";
    var parse:AnyObject?;
    
    init(name:String, UUID:String, type:Bytetype, parse:AnyObject) {
        self.name = name;
        self.UUID = UUID;
        self.type = type;
        self.parse = parse;
    }
}