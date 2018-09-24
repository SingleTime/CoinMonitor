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

    @IBOutlet weak var prefs: NSWindow!
    @IBOutlet weak var menu: NSMenu!
    var statusItem:NSStatusItem!
    var timer:Timer!
    var defaults = UserDefaults.standard
    var priceMap = Dictionary<String, String>();
    var isInit = false;
    @IBAction func prefsClick(_ sender: NSMenuItem) {
        prefs.setIsVisible(true)
    }
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
        let dataString = defaults.string(forKey: "selectedCoins")
        let json = JSON.init(parseJSON: dataString ?? "[]")
        for subJson in json.arrayValue {
            let symbol = subJson["Source"].stringValue + subJson["Target"].stringValue
            if !isInit {
                self.priceMap.updateValue("0", forKey: symbol.lowercased())
            }
            getPrice(symbol: symbol.lowercased());
        }
        self.isInit = true;
        var index = 0;
        for key in priceMap.keys{
            let item = statusItem.menu?.item(at: index);
            if (item?.keyEquivalent == key){
                item?.title = key + ":" + priceMap[key]!
            } else {
                statusItem.menu?.insertItem(withTitle: key + ":" + priceMap[key]!, action: #selector(timerAction), keyEquivalent:key, at: index)
            }
            
            index = index + 1
        }
        
        statusItem.title = statusItem.menu?.item(at: 0)?.title;
    }
    
    func getPrice(symbol: String){
        Alamofire.request("https://api.huobi.pro/market/detail/merged", parameters: ["symbol": symbol.lowercased()])
        .responseJSON { response in
                if response.data != nil {
                let json = JSON(response.data!)
                let price = json["tick"]["bid"][0].stringValue
                print("result", symbol + ":" + price)
                if !price.isEmpty {
                    self.priceMap.updateValue(price, forKey: symbol)
                }
            }
        }
    }
}
