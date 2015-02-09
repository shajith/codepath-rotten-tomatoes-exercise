//
//  ViewController.swift
//  Rotten Tomatoes
//
//  Created by Shajith on 2/2/15.
//  Copyright (c) 2015 zd. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var moviesTable: UITableView!
    @IBOutlet weak var networkErrorLabel: UILabel!
    
    let moviesURL = NSURL(string: "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=p2buf5fb69teepqrq95uwhtt&limit=50")
    
    var displayedMovies: [NSDictionary] = []
    var allMovies: [NSDictionary] = []
    
    var refreshControl: UIRefreshControl!
    var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        moviesTable.dataSource = self
        moviesTable.delegate = self
        title = "Tomatoes"
        
        hideNetworkError()
        
        refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: "refreshMovies", forControlEvents: UIControlEvents.ValueChanged)
        
        moviesTable.addSubview(refreshControl)
        
        searchBar = UISearchBar(frame: CGRect(x: 0, y:0, width: 320, height: 44))
        
        searchBar.delegate = self
            
        moviesTable.addSubview(searchBar)
        moviesTable.tableHeaderView = searchBar
        moviesTable.contentOffset = CGPoint(x: 0, y: 44)
        moviesTable.separatorInset = UIEdgeInsetsZero
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.blackColor()
        searchBar.backgroundColor = UIColor.blackColor()

        JHProgressHUD.sharedHUD.showInView(view, withHeader: "Loading", andFooter: "")

        fetchMovies() { () -> Void in
            JHProgressHUD.sharedHUD.hide()
        }
        
    }

    func hideNetworkError() {
        networkErrorLabel.hidden = true
        networkErrorLabel.frame = CGRect(x: 0, y: 0, width: 0,height: 0)
    }
    
    func showNetworkError() {
        networkErrorLabel.hidden = false
        networkErrorLabel.frame = CGRect(x: 0, y: 0, width: 320,height: 20)
    }
    
    func refreshMovies() {
        fetchMovies() { () -> Void in
            self.refreshControl.endRefreshing()
        }
    }
    
    func fetchMovies(completion: (() -> Void)?) {
        var request = NSURLRequest(URL: moviesURL!)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            if(error != nil) {
                self.showNetworkError()
                return
            }
            
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            
            self.allMovies = jsonResult["movies"] as [NSDictionary]
            self.displayedMovies = jsonResult["movies"] as [NSDictionary]
            NSLog("Movies: %ld", self.allMovies.count)
            
            self.moviesTable.reloadData()
            
            if(completion != nil) {
                completion!()
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedMovies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell") as MovieCell
        
        var movie = displayedMovies[indexPath.row]
        
        cell.titleLabel.text = movie["title"] as NSString
        cell.synopsisLabel.text = movie["synopsis"] as NSString
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.preservesSuperviewLayoutMargins = false;
        
        var posterURL = movie.valueForKeyPath("posters.thumbnail") as NSString
        
        posterURL = posterURL.stringByReplacingOccurrencesOfString("_tmb.jpg", withString: "_pro.jpg") //get a slightly higer res thumb
        
        cell.posterImage.setImageWithURL(NSURL(string: posterURL))
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var detail = segue.destinationViewController as MovieDetailController
        let path = moviesTable.indexPathForSelectedRow()
        
        detail.movie = displayedMovies[path!.row] as NSDictionary;
        detail.title = detail.movie["title"] as NSString
        moviesTable.deselectRowAtIndexPath(path!, animated: true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(searchText.isEmpty) {
            displayedMovies = allMovies
        } else {
            displayedMovies = allMovies.filter() { (movie: NSDictionary) -> (Bool) in
                var title = movie["title"] as NSString
                return (title.lowercaseString as NSString).containsString(searchText)
            }
        }
        
        moviesTable.reloadData()
    }

}

