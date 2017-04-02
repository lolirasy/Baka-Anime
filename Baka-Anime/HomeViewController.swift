//
//  HomeViewController.swift
//  Baka-Anime
//
//  Created by ភី ម៉ារ៉ាសុី on 10/4/16.
//  Copyright © 2016 ភី ម៉ារ៉ាសុី. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Material
class HomeViewController: UIViewController{
  
    @IBOutlet var menuButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        menuButton.image = Icon.menu
        if revealViewController() != nil {
            //            revealViewController().rearViewRevealWidth = 62
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            revealViewController().rightViewRevealWidth = 150
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
            
            
            Alamofire.request("http://api.animeplus.tv/GetDetails/1").responseJSON { (responseData) -> Void in
                if((responseData.result.value) != nil) {
                    let swiftyJsonVar = SwiftyJSON.JSON(responseData.result.value!)
                    print(swiftyJsonVar)
                }
            }
        }

        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
   }
