//
//  CycleScrollViewDelegate.swift
//  CycleScrollView
//
//  Created by Loveletter on 15/03/2018.
//  Copyright © 2018 CodeTips. All rights reserved.
//

import UIKit

@objc public protocol CycleScrollViewDelegate : NSObjectProtocol {
    func numberOfPages(in cycleScrollView: CycleScrollView) -> Int
    func cycleScrollView(_ cycleScrollView: CycleScrollView, viewForPageAt index: Int) -> UIView
    @objc optional func cycleScrollView(_ cycleScrollView: CycleScrollView, didSelectPageAt index: Int)
}
