//
//  MovieDetailController.swift
//  Rotten Tomatoes
//
//  Created by Shajith on 2/5/15.
//  Copyright (c) 2015 zd. All rights reserved.
//

import UIKit

class MovieDetailController: UIViewController {

    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingsLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    @IBOutlet weak var detailScroll: UIScrollView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var ratingLabel: UILabel!
    
    var movie: NSDictionary = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var posterURL = movie.valueForKeyPath("posters.original") as NSString
        
        posterURL = posterURL.stringByReplacingOccurrencesOfString("_tmb.jpg", withString: "_ori.jpg")
        
        posterImage.setImageWithURL(NSURL(string: posterURL))
        
        titleLabel.text = movie["title"] as NSString

        var criticsRating = movie.valueForKeyPath("ratings.critics_score") as NSNumber
        
        var viewersRating = movie.valueForKeyPath("ratings.audience_score") as NSNumber
        
        ratingsLabel.text = "Critics: \(criticsRating), Audience: \(viewersRating)"

        synopsisLabel.text = movie["synopsis"] as NSString
        
        
        var rating = movie["mpaa_rating"] as NSString

        var attrs = [NSFontAttributeName: UIFont.boldSystemFontOfSize(14.0)]
        
        var ratingText = NSMutableAttributedString(string:rating, attributes:attrs)

        attrs = [NSFontAttributeName: UIFont.italicSystemFontOfSize(14.0)]
        
        var runtime = movie["runtime"] as NSNumber
        
        var runtimeText = NSMutableAttributedString(string:" \(runtime) min", attributes:attrs)
        
        ratingText.appendAttributedString(runtimeText)
        
        ratingLabel.attributedText = ratingText
        
        synopsisLabel.sizeToFit()
        
        var newHeight = synopsisLabel.frame.origin.y + synopsisLabel.frame.height;
        
        if(detailView.frame.height < newHeight) {
            detailView.frame = CGRect(origin: detailView.frame.origin, size: CGSize(width: detailView.frame.width,  height: newHeight + 150))
        }
        
        var contentHeight = detailScroll.bounds.height - detailView.frame.origin.y + detailView.frame.height
        
        detailScroll.contentSize = CGSize(width: detailView.frame.width, height: contentHeight)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
