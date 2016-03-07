//
//  datareader.swift
//  BTDriver
//
//  Created by Alfred Cepeda on 3/4/16.
//  Copyright © 2016 Alfred Cepeda. All rights reserved.
//

import Foundation

enum Bytetype {
    case None, Byte, Array
}

class DataReader {
    var characteristic:Characteristic?;
    var parse:((NSData) -> AnyObject)?;
    
    func read(value:NSData) -> AnyObject? {
        if let action = self.parse {
            let result = action(value);
            return result;
        }
        
        print("Must set characteristic before attempting to read value");
        return nil;
    }
    
    func setCharacteristic(charac:Characteristic) -> Bool {
        var wasSet = false;
        self.characteristic = charac;
        
        switch(charac.type) {
            case .Array:
                if let lengths = charac.parse as? Array<Int> {
                    self.parse = self.action_byteArray(lengths);
                } else if let bytes = charac.parse as? Array<Byte> {
                    self.parse = self.action_byteArray(bytes);
                } else if let dict = charac.parse as? [String:Int] {
                    self.parse = self.action_hashMap(dict);
                }
                
                wasSet = true;
            break;
            case .Byte:
                self.parse = self.action_word();
                wasSet = true;
            break;
            default:
                print("Unreccognized byte read type");
            break;
        }
        
        return wasSet;
    }
    
    func action_word() -> NSData -> AnyObject {
        return { (value:NSData) -> AnyObject in
            var decoded = 0;
            value.getBytes(&decoded, length: value.length);
            return decoded;
        };
    }
    
    func action_hashMap(dict:[String:Int]) -> ((NSData) -> AnyObject) {
        return { (value:NSData) -> AnyObject in
            var result:[String:Int] = [:];
            var offset = 0;
            dict.forEach{ (entry: (String, Int)) -> () in
                var decoded = 0;
                value.getBytes(&decoded, range: NSMakeRange(offset, entry.1));
                offset += entry.1;
                
                result[entry.0] = decoded;
            };
            
            return result;
        }
    }
    
    func action_byteArray(bytes:Array<Byte>) -> ((NSData) -> AnyObject)? {
        var dict:[String:Int] = [:];
        var index = 0;
        bytes.forEach{ byte in
            let key = (byte.name != "") ? byte.name : String(index);
            dict[key] = byte.length;
            index++;
        };
        
        return self.action_hashMap(dict);
    }
    
    func action_byteArray(lengths:Array<Int>) -> ((NSData) -> AnyObject) {
        return { (value:NSData) -> AnyObject in
            var result:[Int] = [];
            var offset = 0;
            lengths.forEach{ length in
                var decoded = 0;
                value.getBytes(&decoded, range: NSMakeRange(offset, length));
                offset += length;
                
                result.append(decoded);
            };
            
            return result;
        };
    }
}