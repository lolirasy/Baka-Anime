//
//  PopularAnimeViewController.swift
//  Baka-Anime
//
//  Created by ភី ម៉ារ៉ាសុី on 10/4/16.
//  Copyright © 2016 ភី ម៉ារ៉ាសុី. All rights reserved.
//
import UIKit
import Material
import SwiftyJSON

import Alamofire
class PopularAnimeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tblDemo: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var refreshControl: UIRefreshControl!
    
    var anime = [Anime]()
    var filterAnime = [Anime]()
    
    var customView: UIView!
    
    var labelsArray: Array<UILabel> = []
    
    var isAnimating = false
    
    var currentColorIndex = 0
    
    var currentLabelIndex = 0
    
    var timer: Timer!
    
    
    
    
    
    let searchBar:SearchBar = {
        let search = SearchBar()
        search.placeholder = "Search Anime"
        search.backgroundColor = UIColor.white
        search.tintColor = UIColor.white
        return search
        
    }()
    
    
    /// Prepares the toolbar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        Alamofire.request("http://api.animeplus.tv/GetPopularShows").responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                print("yes")
                let swiftyJsonVar = SwiftyJSON.JSON(responseData.result.value!)
                for  i in 0 ..< swiftyJsonVar.count {
                    let resData = swiftyJsonVar[i]["name"].string
                    let idData = swiftyJsonVar[i]["id"].string
                    let genreData = swiftyJsonVar[i]["genres"].array?.description
                    var statusData = swiftyJsonVar[i]["status"].string
                    
                    var detailData = swiftyJsonVar[i]["description"].string
                    if statusData == nil {
                        statusData = "Unknown"
                    }
                    if detailData == nil {
                        detailData = "Unknown"
                    }
                    
                    self.anime.append(Anime(name: resData!, detail: detailData!, rate: 1, status: statusData!, genre: genreData!, id: idData!))
                    self.tblDemo.reloadData()
                    
                    
                }
                self.filterAnime = self.anime
            }
        }
    }
    
    func convertStatus(string: String) -> String{
        if string == "CMP" {
            return "Complete"
        }
        else if string == "ONG"{
            return "On Going"
        }
        else {
            return "Unknown"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        menuButton.image = Icon.menu
        if revealViewController() != nil {
            //            revealViewController().rearViewRevealWidth = 62
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            revealViewController().rightViewRevealWidth = 150
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
            
        }
        
        
        
        
        
        
        tblDemo.delegate = self
        tblDemo.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor.clear
        refreshControl.tintColor = UIColor.clear
        tblDemo.addSubview(refreshControl)
        prepareSearchBar()
        searchBar.frame = CGRect(x: 5,y: 5,width: (navigationController?.navigationBar.frame.size.width)! - 5 ,height: 35)
        navigationItem.titleView = searchBar
        
        searchBar.textField.delegate = self
        searchBar.textField.addTarget(self, action: #selector(AllAnimeViewController.searchBegin(searchText:)), for: .editingChanged)
        searchBar.clearButton.addTarget(self, action: #selector(AllAnimeViewController.clearButton(sender:)), for: .touchUpInside)
        loadCustomRefreshContents()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func clearButton(sender: UIButton){
        self.anime = self.filterAnime
        tblDemo.reloadData()
        
    }
    func searchBegin(searchText: UITextField){
        
        if searchText.text! == "" || searchText.text == nil {
            self.anime = self.filterAnime
            self.tblDemo.reloadData()
        }
        else{
            
            self.anime = self.filterAnime.filter(){
                $0.animeName.lowercased().hasPrefix(searchText.text!.lowercased())
            }
            self.tblDemo.reloadData()
            
            
            
        }
        
    }
    // MARK: UITableview method implementation
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return anime.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCell", for: indexPath)  as! AllAnimeTableViewCell
        
        cell.myTitle.text = anime[indexPath.row].animeName
        loadImageFromUrl(url: "http://www.animeplus.tv/images/series/big/\(anime[indexPath.row].animeId).jpg", view: cell.myImage)
        cell.statusLabel.text = convertStatus(string: anime[indexPath.row].animeStatus)
        cell.genreLabel.text = "\(anime[indexPath.row].animeGenre)"
        cell.myDetail.text = anime[indexPath.row].animeDetail
        return cell
    }
    fileprivate func prepareSearchBar() {
        let image: UIImage? = Icon.cm.moreVertical
        
        // More button.
        let moreButton: IconButton = IconButton()
        moreButton.pulseColor = Color.grey.base
        moreButton.tintColor = Color.grey.darken4
        moreButton.setImage(image, for: .normal)
        moreButton.setImage(image, for: .highlighted)
        
        /*
         To lighten the status bar - add the
         "View controller-based status bar appearance = NO"
         to your info.plist file and set the following property.
         */
        searchBar.leftControls = [moreButton]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 242.0
    }
    
    
    
    // MARK: UIScrollView delegate method implementation
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl.isRefreshing {
            if !isAnimating {
                doSomething()
                animateRefreshStep1()
            }
        }
    }
    
    
    // MARK: Custom function implementation
    
    func loadCustomRefreshContents() {
        let refreshContents = Bundle.main.loadNibNamed("RefreshContents", owner: self, options: nil)
        
        customView = refreshContents?[0] as! UIView
        customView.frame = refreshControl.bounds
        
        for i in 0 ..< customView.subviews.count {
            labelsArray.append(customView.viewWithTag(i + 1) as! UILabel)
        }
        
        refreshControl.addSubview(customView)
    }
    
    
    func animateRefreshStep1() {
        isAnimating = true
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
            self.labelsArray[self.currentLabelIndex].transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_4))
            self.labelsArray[self.currentLabelIndex].textColor = self.getNextColor()
            
            }, completion: { (finished) -> Void in
                
                UIView.animate(withDuration: 0.05, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                    self.labelsArray[self.currentLabelIndex].transform = CGAffineTransform.identity
                    self.labelsArray[self.currentLabelIndex].textColor = UIColor.black
                    
                    }, completion: { (finished) -> Void in
                        self.currentLabelIndex += 1
                        
                        if self.currentLabelIndex < self.labelsArray.count {
                            self.animateRefreshStep1()
                        }
                        else {
                            self.animateRefreshStep2()
                        }
                })
        })
    }
    
    
    func animateRefreshStep2() {
        UIView.animate(withDuration: 0.35, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
            self.labelsArray[0].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.labelsArray[1].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.labelsArray[2].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.labelsArray[3].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.labelsArray[4].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.labelsArray[5].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.labelsArray[6].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            
            }, completion: { (finished) -> Void in
                UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                    self.labelsArray[0].transform = CGAffineTransform.identity
                    self.labelsArray[1].transform = CGAffineTransform.identity
                    self.labelsArray[2].transform = CGAffineTransform.identity
                    self.labelsArray[3].transform = CGAffineTransform.identity
                    self.labelsArray[4].transform = CGAffineTransform.identity
                    self.labelsArray[5].transform = CGAffineTransform.identity
                    self.labelsArray[6].transform = CGAffineTransform.identity
                    
                    }, completion: { (finished) -> Void in
                        if self.refreshControl.isRefreshing {
                            self.currentLabelIndex = 0
                            self.animateRefreshStep1()
                        }
                        else {
                            self.isAnimating = false
                            self.currentLabelIndex = 0
                            for i in 0 ..< self.labelsArray.count {
                                self.labelsArray[i].textColor = UIColor.black
                                self.labelsArray[i].transform = CGAffineTransform.identity
                            }
                        }
                })
        })
    }
    
    
    func getNextColor() -> UIColor {
        var colorsArray: Array<UIColor> = [UIColor.magenta, UIColor.brown, UIColor.yellow, UIColor.red, UIColor.green, UIColor.blue, UIColor.orange]
        
        if currentColorIndex == colorsArray.count {
            currentColorIndex = 0
        }
        
        let returnColor = colorsArray[currentColorIndex]
        currentColorIndex += 1
        
        return returnColor
    }
    
    
    func doSomething() {
        timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(AllAnimeViewController.endOfWork), userInfo: nil, repeats: true)
    }
    
    
    func endOfWork() {
        refreshControl.endRefreshing()
        
        timer.invalidate()
        timer = nil
    }
    
    
    //Convert Image
    func loadImageFromUrl(url: String, view: UIImageView){
        
        // Create Url from string
        let url = URL(string: url)
        
        // Download task:
        // - sharedSession = global NSURLCache, NSHTTPCookieStorage and NSURLCredentialStorage objects.
        let task = URLSession.shared.dataTask(with: url!) { (responseData, responseUrl, error) -> Void in
            // if responseData is not null...
            if let data = responseData{
                
                // execute in UI thread
                DispatchQueue.main.async(execute: { () -> Void in
                    view.image = UIImage(data: data)
                })
            }
        }
        
        // Run task
        task.resume()
    }
    
    
}

