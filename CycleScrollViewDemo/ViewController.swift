//
//  ViewController.swift
//  CycleScrollView
//
//  Created by Loveletter on 14/03/2018.
//  Copyright © 2018 CodeTips. All rights reserved.
//

import UIKit
import CycleScrollView

class ViewController: UIViewController, CycleScrollViewDelegate {
    var viewData = [UIView]()
    
    func numberOfPages(in cycleScrollView: CycleScrollView) -> Int {
        return viewData.count
    }
    
    func cycleScrollView(_ cycleScrollView: CycleScrollView, viewForPageAt index: Int) -> UIView {
        return viewData[index]
    }
    
    func cycleScrollView(_ cycleScrollView: CycleScrollView, didSelectPageAt index: Int) {
        print(index)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.white
        
        let cycleScrollView = CycleScrollView.init(frame: CGRect(x: 0, y: 50, width: self.view.bounds.width, height: 140), animation: 2)
        cycleScrollView.delegate = self
        view.addSubview(cycleScrollView)
        
        let colors = [UIColor.blue, UIColor.yellow, UIColor.brown, UIColor.cyan, UIColor.darkGray]
        
        for color in colors{
            let view = UIView(frame: cycleScrollView.bounds)
            view.backgroundColor = color
            viewData.append(view)
        }
        
        cycleScrollView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

