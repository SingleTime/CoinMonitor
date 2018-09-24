//
//  PrefsViewController.swift
//  CoinMonitor
//
//  Created by 姜辽 on 2018/9/22.
//  Copyright © 2018 姜辽. All rights reserved.
//

import Cocoa
import Alamofire
import Foundation
import SwiftyJSON

class PrefsViewController: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var sourceItems: NSPopUpButton!
    @IBOutlet weak var targetItems: NSPopUpButton!
    let defaults = UserDefaults.standard

    private lazy var c: NSTableView = {
        let tmpTableView = NSTableView()
        tmpTableView.delegate = self
        tmpTableView.dataSource = self
        tmpTableView.allowsColumnSelection = true
        return tmpTableView
    }()
    var data = Array<Dictionary<String, String>>()

    @IBOutlet weak var scrollView: NSScrollView!
    
    override func awakeFromNib() {
        print("aaaaa")
        self.sourceItems.removeAllItems()
        loadCoinItems()
        
        self.sourceItems.addItem(withTitle: "USDT")
        self.sourceItems.addItem(withTitle: "BTC")
        self.sourceItems.addItem(withTitle: "HT")
        let dataString = defaults.string(forKey: "selectedCoins")
        let json = JSON.init(parseJSON: dataString ?? "[]")
        for subJson in json.arrayValue {
            self.data.append(["Target":subJson["Target"].stringValue, "Source":subJson["Source"].stringValue])
        }
        buildDataView()
        
        
    }
    
    func buildDataView() {
        let column1 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "Source"))
        column1.width = 100
        column1.minWidth = 100
        column1.maxWidth = 101
        column1.title = "Source"
        let column2 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "Target"))
        column2.width = 100
        column2.minWidth = 100
        column2.maxWidth = 101
        column2.title = "Target"
        column2.isEditable = false
        column2.headerToolTip = "提示"
        column2.isHidden = false
        column2.sortDescriptorPrototype = NSSortDescriptor(key: "sortDescriptorPrototyp", ascending: false)
        //允许自动调整Column的尺寸
        column1.resizingMask = NSTableColumn.ResizingOptions.autoresizingMask
        column2.resizingMask = NSTableColumn.ResizingOptions.autoresizingMask
        c.frame = CGRect.zero
        c.addTableColumn(column1)
        c.addTableColumn(column2)
        self.scrollView.contentView.documentView = c
        
        self.c.dataSource = self
        self.c.delegate = self
        self.c.reloadData()
    }
    
    @IBAction func addClick(_ sender: Any) {
        let source = self.targetItems.selectedItem?.title ?? ""
        let target = self.sourceItems.selectedItem?.title ?? ""
        print("target:", target)
        print("source:", source)
        let obj = data.filter({$0["Target"]==target && $0["Source"]==source }).first
        if (obj == nil){
            self.data.append(["Target":target, "Source":source])
            self.c.reloadData()
            let jsonString = JSON(self.data).rawString(.utf8, options: .init(rawValue: 0))
            defaults.removeObject(forKey: "selectedCoins")
            defaults.set(jsonString, forKey: "selectedCoins")
        }

    }
    func loadCoinItems() {
        Alamofire.request("https://api.huobi.pro/v1/common/currencys")
            .responseJSON { response in
                if response.data != nil {
                    let json = JSON(response.data!)
                    let data = json["data"].array?.compactMap({ $0.string })
                    self.targetItems.removeAllItems()
                    for item in data ?? [] {
                        self.targetItems.addItem(withTitle: item.uppercased())
                    }
                }
        }
        
    }
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return self.data.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any?
    {
        //获取表格列的标识符
        let columnID = tableColumn!.identifier;
        let value = data[row][columnID.rawValue]
        print("columid:", value!)
        return value;
    }
    
    
}
