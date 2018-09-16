//
//  StatusMenuController.swift
//  CoinMonitor
//
//  Created by 姜辽 on 2018/9/16.
//  Copyright © 2018 姜辽. All rights reserved.
//

import Cocoa
import Alamofire
import Foundation
import SwiftyJSON

class StatusMenuController: NSObject {

    @IBOutlet weak var menu: NSMenu!
    var statusItem:NSStatusItem!
    var timer:Timer!
    
    override func awakeFromNib() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.image = #imageLiteral(resourceName: "StatusBarButtonImage")
        #imageLiteral(resourceName: "StatusBarButtonImage").isTemplate = true
        statusItem.menu = menu
        timer  = Timer.scheduledTimer(timeInterval: 3,
                                   target: self,
                                   selector:#selector(timerAction),
                                   userInfo: nil,
                                   repeats: true)
        timerAction()
    }
    
    @IBAction func quitClick(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    @objc dynamic func timerAction() {
        Alamofire.request("https://api.huobi.pro/market/detail/merged", parameters: ["symbol":"btcusdt"])
            .responseJSON { response in
                if response.data != nil {
                    let json = JSON(response.data!)
                    let price = json["tick"]["bid"][0].stringValue
                    self.statusItem.title = price
                    print("data:", price)
                }
        }
       
    }
}
