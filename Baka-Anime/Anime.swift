//
//  Anime.swift
//  Baka-Anime
//
//  Created by ភី ម៉ារ៉ាសុី on 10/2/16.
//  Copyright © 2016 ភី ម៉ារ៉ាសុី. All rights reserved.
//

import UIKit

class Anime : NSObject{
    var animeName = String()
    var animeDetail = String()
    var animeRate = Int()
    var animeStatus = String()
    var animeGenre = String()
    var animeId = String()
 
    init(name: String,detail: String, rate: Int, status: String, genre: String, id: String) {
        self.animeName = name
        self.animeDetail = detail
        self.animeGenre = genre
        self.animeRate = rate
        self.animeStatus = status
        self.animeId = id
        
    }
    override init() {
        
    }
}
