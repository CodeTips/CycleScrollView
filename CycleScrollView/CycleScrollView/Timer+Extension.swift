//
//  Timer+Extension.swift
//  CycleScrollView
//
//  Created by Loveletter on 15/03/2018.
//  Copyright © 2018 CodeTips. All rights reserved.
//

import Foundation

extension Timer{
    func pause(){
        guard self.isValid else {
            return
        }
        self.fireDate = Date.distantFuture
    }
    
    func resume(){
        guard self.isValid else {
            return
        }
        self.fireDate = Date()
    }
    
    func resumeAfter(interval: TimeInterval){
        guard self.isValid else {
            return
        }
        self.fireDate = Date(timeIntervalSinceNow: interval)
    }
}
