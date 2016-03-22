//
//  main.swift
//  BTDriver
//
//  Created by Alfred Cepeda on 7/15/15.
//  Copyright (c) 2015 Alfred Cepeda. All rights reserved.
//

import Foundation
import CoreBluetooth

if let bluetooth = Const.devices.first {
    var manager = BTManager(bluetooth: bluetooth);
    NSRunLoop.currentRunLoop().run();
} else {
    print("Can't start without knowing what I'm looking for");
}

