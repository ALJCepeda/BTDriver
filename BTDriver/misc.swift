//
//  misc.swift
//  BTDriver
//
//  Created by Alfred Cepeda on 2/27/16.
//  Copyright © 2016 Alfred Cepeda. All rights reserved.
//

import Foundation

func delay(delay:Double, cb:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), cb)
}

extension Array {
    func find(isFound: (Element) -> Bool) -> Element? {
        for elem in self {
            if(isFound(elem) == true) {
                return elem;
            }
        }
        
        return nil;
    }
}