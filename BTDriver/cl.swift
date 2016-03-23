//
//  cl.swift
//  BTDriver
//
//  Created by Alfred Cepeda on 3/22/16.
//  Copyright © 2016 Alfred Cepeda. All rights reserved.
//

import Foundation

class Console {
    var output = NSFileHandle.fileHandleWithStandardOutput();
    var encoding = NSUTF8StringEncoding;
    
    func stdout(message:String) -> Bool {
        if let data = message.dataUsingEncoding(self.encoding) {
            output.writeData(data);
            return true;
        }
        
        print("Unable to encode message");
        return false;
    }
}