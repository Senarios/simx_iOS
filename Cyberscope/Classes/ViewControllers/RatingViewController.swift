//
//  RatingViewController.swift
//  SimX
//
//  Created by Senarios on 22/06/2021.
//  Copyright © 2021 Agilio. All rights reserved.
//

import UIKit

class RatingViewController: UIViewController {

    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblUserRating: UILabel!
    @IBOutlet weak var lblTotalRating: UILabel!
    @IBOutlet weak var viewRating: StarRatingView!
    @IBOutlet weak var btnWriteReview: UIButton!
    @IBOutlet weak var tableViewReviews: UITableView!
    @IBOutlet weak var viewRateUser: RatingView!
    @IBOutlet weak var imgBlur: UIImageView!
    
    var user: User!
    var fromSelfProfile: Bool!
    var reviewsArray: [Review] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataAccess.sharedInstance.getAllReviews(userId: user.username, self)
        self.tableViewReviews.delegate = self
        self.tableViewReviews.dataSource = self
        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView()
    {
        if(fromSelfProfile)
        {
            self.btnWriteReview.isHidden = true
        }
        else
        {
            self.btnWriteReview.isHidden = false
        }
        let totalRating = user.total_ratings as String
        let userRating = user.user_ratings as String
        
        self.lblUserRating.text = userRating
        self.lblTotalRating.text = "from " + totalRating + " people"
        self.setupRating(rating: userRating)
    }
    
    func setupRating(rating: String)
    {
        if(rating == "")
        {
            self.lblUserRating.text = "Unrated yet"
        }
        else
        {
            let rate = (rating as NSString).floatValue
            viewRating.rating = rate
        }
    }
    
    func moveBack()
    {
        DispatchQueue.main.async {
            if (self.navigationController == nil) {
                self.dismiss(animated: true, completion: nil)
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK:- Buttons Actions

    @IBAction func btnClose_pressed(_ sender: Any) {
        self.moveBack()
    }
    
    @IBAction func btnWriteReview_pressed(_ sender: Any) {
        self.imgBlur.isHidden = false
        self.viewRateUser.isHidden = false
        self.viewRateUser.lblUserName.text = "Rate " + user.name
        self.viewRateUser.btnPostReview.addTarget(self, action: #selector(btnPostReview_pressed), for: .touchUpInside)
        self.viewRateUser.btnClose.addTarget(self, action: #selector(btnClosePostReview_pressed), for: .touchUpInside)
    }
    
    @objc func btnClosePostReview_pressed()
    {
        self.imgBlur.isHidden = true
        self.viewRateUser.isHidden = true
    }
    
    @objc func btnPostReview_pressed()
    {
//        if(viewRateUser.txtReview.text == "Type your review here..." || viewRateUser.txtReview.text == nil)
//        {
//            self.showAlert(message: "Please type some review")
//        }
        if(viewRateUser.txtReview.text.count > 500)
        {
            self.showAlert(message: "Review should be less than 500 characters")
        }
        else if(viewRateUser.viewRating.rating == 0)
        {
            self.showAlert(message: "Rating should be atleast 1")
        }
        else
        {
            Utilities.show_ProgressHud(view: self.view)
            let rate = viewRateUser.viewRating.rating
            let review = (viewRateUser.txtReview.text == "Type your review here..." || viewRateUser.txtReview.text == nil) ? "" : viewRateUser.txtReview.text
            let fromUser = CurrentUser.getCurrentUser_From_UserDefaults()
            let fromId = fromUser.username
            let toId = self.user.username
            
            DataAccess.sharedInstance.postReview(toId: toId, fromId: fromId, rate: String(format: "%f", rate), review: review!, self)
        }
    }
    
    func showAlert(message: String)
    {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension RatingViewController: UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return reviewsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 15.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 15.0))
        view.backgroundColor = UIColor.clear
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let height: CGFloat = (tableView.frame.size.height / 5)
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableViewReviews.dequeueReusableCell(withIdentifier: "RatingTableViewCell") as! RatingTableViewCell
        
        let review = reviewsArray[indexPath.section]
        
        let nameReviewer = review.user?.name
        let pictureReviewer = review.user?.picture
        let rating = review.rating
        let reviewText = review.review
        
        cell.populateCell(name: nameReviewer!, rate: rating!, review: reviewText!, picture: pictureReviewer!)
        
        return cell
    }
    
}

extension RatingViewController: RatingAndReviewDelegate,GetReviewsSuccessDelegate
{
    func recievedReviews(_ reviewsArray: [Review]) {
        self.reviewsArray = reviewsArray
        self.tableViewReviews.reloadData()
    }
    
    func ratedSuccessfully(_ totalRating: String, _ userRating: String) {
        self.viewRating.rating = Float(userRating)!
        self.lblUserRating.text = userRating
        self.lblTotalRating.text = "from " + totalRating + " people"
        DataAccess.sharedInstance.getAllReviews(userId: user.username, self)
        self.viewRateUser.isHidden = true
        self.imgBlur.isHidden = true
        Utilities.hide_ProgressHud(view: self.view)
        NotificationCenter.default.post(
            name: NSNotification.Name("updateUserInfo"),
            object: nil,
            userInfo: [
                "totalRating": totalRating as Any,
                "userRating": userRating as Any
            ])
    }
}
