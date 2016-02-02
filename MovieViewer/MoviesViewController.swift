//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Bhatt, Gaurang on 1/29/16.
//  Copyright © 2016 Gb0143. All rights reserved.
//

import UIKit
import AFNetworking;
import MBProgressHUD;

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
//    @IBOutlet weak var errorView: UIView!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkError: UIView!
    
    var movies: [NSDictionary]?
    let refreshControl = UIRefreshControl();
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        errorView.hidden = true
        print("tableView: \(tableView)");
        tableView.dataSource = self;
        tableView.delegate = self;
        
        refreshControlAction(refreshControl);
        tableView.insertSubview(refreshControl, atIndex: 0)
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        if !isConnectedToNetwork() {
            print("no network connection");
            refreshControl.endRefreshing();
            networkError.hidden = false;
            return;
        } else {
            networkError.hidden = true;
        }
        let apiKey = "e2eea30c49db9a7f219266fbc9d34297"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            self.movies = responseDictionary["results"] as? [NSDictionary];
                            self.tableView.reloadData()
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            refreshControl.endRefreshing()
                    }
                }
            }
        )
        task.resume()
    }
    
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let movies = movies {
            print(" \(movies.count)");
            return movies.count;
        } else {
            return 0;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row];
        let title = movie["title"] as! String;
        print("row \(indexPath.row), title \(title)");
        var posterPath = "nil"
        if movie["poster_path"] is NSNull {
        } else {
            posterPath = movie["poster_path"] as! String;
        }
        
        let baseURL = "http://image.tmdb.org/t/p/w500";
        let imageURL = NSURL(string: baseURL + posterPath)
        cell.title.text = title;
        cell.overview.text = movie["overview"] as? String;
        cell.movieImage.setImageWithURL(imageURL!);
        return cell;
    }
    
    @IBAction func refreshPage(sender: AnyObject) {
        refreshControlAction(refreshControl);
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
