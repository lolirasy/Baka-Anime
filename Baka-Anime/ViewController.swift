//
//  ViewController.swift
//  Baka-Anime
//
//  Created by ភី ម៉ារ៉ាសុី on 9/29/16.
//  Copyright © 2016 ភី ម៉ារ៉ាសុី. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        Alamofire.request("http://api.animeplus.tv/GetAllShows").responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                print("yes")
                let swiftyJsonVar = JSON(responseData.result.value!)
                for  i in 0 ..< swiftyJsonVar.count {
                     let resData = swiftyJsonVar[i]["name"]
                        print(resData)
                    

                }
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

