//
//  RequestAppointmentViewController.swift
//  SimX
//
//  Created by Salman on 28/05/2021.
//  Copyright © 2021 Agilio. All rights reserved.
//

import UIKit

public enum Appointment_Status: String
{
    case Pending = "pending"
    case rejected = "rejected"
    case accepted = "accepted"
}

class RequestAppointmentViewController: UIViewController{

    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var viewDate: UIView!
    @IBOutlet weak var view8AM: UIView!
    @IBOutlet weak var btn8AM: UIButton!
    @IBOutlet weak var view12PM: UIView!
    @IBOutlet weak var btn12PM: UIButton!
    @IBOutlet weak var view10AM: UIView!
    @IBOutlet weak var btn10AM: UIButton!
    @IBOutlet weak var view2PM: UIView!
    @IBOutlet weak var btn2PM: UIButton!
    @IBOutlet weak var view6PM: UIView!
    @IBOutlet weak var btn6PM: UIButton!
    @IBOutlet weak var view4PM: UIView!
    @IBOutlet weak var btn4PM: UIButton!
    @IBOutlet weak var view10Min: UIView!
    @IBOutlet weak var btn10Min: UIButton!
    @IBOutlet weak var view30Min: UIView!
    @IBOutlet weak var btn30Min: UIButton!
    @IBOutlet weak var view20Min: UIView!
    @IBOutlet weak var btn20Min: UIButton!
    @IBOutlet weak var view40Min: UIView!
    @IBOutlet weak var btn40Min: UIButton!
    @IBOutlet weak var view60Min: UIView!
    @IBOutlet weak var btn60Min: UIButton!
    @IBOutlet weak var view50Min: UIView!
    @IBOutlet weak var btn50Min: UIButton!
    @IBOutlet weak var lblEstimatedCost: UILabel!
    @IBOutlet weak var lbl121Fee: UILabel!
    @IBOutlet weak var btnRequestAppointment: UIButton!
    @IBOutlet weak var lbl8AM: UILabel!
    @IBOutlet weak var lbl10AM: UILabel!
    @IBOutlet weak var lbl12PM: UILabel!
    @IBOutlet weak var lbl2PM: UILabel!
    @IBOutlet weak var lbl4PM: UILabel!
    @IBOutlet weak var lbl6PM: UILabel!
    @IBOutlet weak var lbl10Min: UILabel!
    @IBOutlet weak var lbl20Min: UILabel!
    @IBOutlet weak var lbl30Min: UILabel!
    @IBOutlet weak var lbl40Min: UILabel!
    @IBOutlet weak var lbl50Min: UILabel!
    @IBOutlet weak var lbl60Min: UILabel!
    @IBOutlet weak var img8: UIImageView!
    @IBOutlet weak var img12: UIImageView!
    @IBOutlet weak var img10: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img4: UIImageView!
    @IBOutlet weak var img6: UIImageView!
    @IBOutlet weak var img10m: UIImageView!
    @IBOutlet weak var img20: UIImageView!
    @IBOutlet weak var img30: UIImageView!
    @IBOutlet weak var img40: UIImageView!
    @IBOutlet weak var img50: UIImageView!
    @IBOutlet weak var img60: UIImageView!
    
    var datePickerContainer: UIView?
    var selected_broadcaster: User?
   
    var choosenDurationOptionIndex = 0
    var appointment_date: String = "March 20, 2018"
    var appointment_time: String = "08:00"
    var appointment_duration: String = "10 minutes"
    var appointment_deposit: String = "£10"
    var appointment_1_2_1_BroadcastFee: String = "£10/hr"
    
    let datePicker = UIDatePicker()
    
    fileprivate let dataAccess = DataAccess.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let rateOfBroadcaster = Int((self.selected_broadcaster?.rate)!)
//        let amountToPay = Double(rateOfBroadcaster!) * (Double(self.choosenDurationOptionIndex + 1)/6.0)
//        self.appointment_deposit = String(format: "£%0.1f", amountToPay) //"£\(Int(amountToPay))
        //self.appointment_1_2_1_BroadcastFee = "£\(self.selected_broadcaster?.rate ?? "nan")/hr"
//        self.lbl121Fee.text = appointment_1_2_1_BroadcastFee
//        lblEstimatedCost.text = String(format: "£%0.1f", amountToPay)
        // Do any additional setup after loading the view.
        setupView()
        self.updateDateAndTimeValues(date: Date().addingTimeInterval(3600))
        self.showDatePicker()
    }
    
    func setupView()
    {
        view8AM.applyShadow(radius: 2)
        view10AM.applyShadow(radius: 2)
        view12PM.applyShadow(radius: 2)
        view2PM.applyShadow(radius: 2)
        view4PM.applyShadow(radius: 2)
        view6PM.applyShadow(radius: 2)
        view10Min.applyShadow(radius: 2)
        view20Min.applyShadow(radius: 2)
        view30Min.applyShadow(radius: 2)
        view40Min.applyShadow(radius: 2)
        view50Min.applyShadow(radius: 2)
        view60Min.applyShadow(radius: 2)
        
        view8AM.layer.cornerRadius = 5
        view10AM.layer.cornerRadius = 5
        view12PM.layer.cornerRadius = 5
        view2PM.layer.cornerRadius = 5
        view4PM.layer.cornerRadius = 5
        view6PM.layer.cornerRadius = 5
        view10Min.layer.cornerRadius = 5
        view20Min.layer.cornerRadius = 5
        view30Min.layer.cornerRadius = 5
        view40Min.layer.cornerRadius = 5
        view50Min.layer.cornerRadius = 5
        view60Min.layer.cornerRadius = 5
        
        btnRequestAppointment.layer.cornerRadius = 5
        
        lblEstimatedCost.layer.cornerRadius = 5
        lblEstimatedCost.clipsToBounds = true
        lbl121Fee.layer.cornerRadius = 5
        lbl121Fee.clipsToBounds = true
    }
    
    func showDatePicker(){
        //Formate Date
        datePickerContainer = UIView()
        datePickerContainer?.frame = CGRect(x:0.0, y:self.view.frame.height - 300.0, width:self.view.frame.width, height:300.0)
        datePickerContainer?.backgroundColor = UIColor.white
        
        let pickerSize : CGSize = datePicker.sizeThatFits(CGSize.zero)
        datePicker.frame = CGRect(x:0.0, y:20.0, width:pickerSize.width, height:260)
        
        datePicker.datePickerMode = .date
        datePicker.setDate(Date().addingTimeInterval(3600), animated: true)
        datePicker.minimumDate = Date().addingTimeInterval(3600)
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: UIControlEvents.valueChanged)
        datePicker.setValue(UIColor.black, forKeyPath: "textColor")
        datePickerContainer?.addSubview(datePicker)
        
        let doneButton = UIButton()
        doneButton.setTitle("Done", for: UIControlState.normal)
        doneButton.setTitleColor(UIColor.blue, for: UIControlState.normal)
        doneButton.addTarget(self, action: #selector(dismissPicker(sender:)), for: UIControlEvents.touchUpInside)
        doneButton.frame    = CGRect(x:250.0, y:5.0, width:70.0, height:37.0)
        
        datePickerContainer?.addSubview(doneButton)
        self.view.addSubview(datePickerContainer!)
        self.datePickerContainer?.isHidden = true
        
    }
    
    func showPicker() {
        self.datePickerContainer?.isHidden = false
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        self.updateDateAndTimeValues(date: sender.date)
    }
    
    func updateDateAndTimeValues(date: Date) {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        
        var dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        
        self.appointment_date = dateFormatterPrint.string(from: date)
        self.txtDate.text = self.appointment_date
    }
    
    @objc func dismissPicker(sender: UIButton) {
        print("dismiss date picker")
        self.datePickerContainer?.isHidden = true
    }
    
    //MARK:- Buttons Actions
    
    @IBAction func btnDate_pressed(_ sender: Any) {
        self.showPicker()
    }
    @IBAction func btn8AM_pressed(_ sender: Any) {
        resetTimeViews()
        view8AM.backgroundColor = UIColor(red: 0/255, green: 50/255, blue: 239/255, alpha: 1)
        lbl8AM.textColor = UIColor.white
        img8.image = UIImage(named: "imgClockWhite")
        
        self.appointment_time = "08:00"
    }
    @IBAction func btn10AM_pressed(_ sender: Any) {
        resetTimeViews()
        view10AM.backgroundColor = UIColor(red: 0/255, green: 50/255, blue: 239/255, alpha: 1)
        lbl10AM.textColor = UIColor.white
        img10.image = UIImage(named: "imgClockWhite")
        
        self.appointment_time = "10:00"
    }
    @IBAction func btn12PM_pressed(_ sender: Any) {
        resetTimeViews()
        view12PM.backgroundColor = UIColor(red: 0/255, green: 50/255, blue: 239/255, alpha: 1)
        lbl12PM.textColor = UIColor.white
        img12.image = UIImage(named: "imgClockWhite")
        
        self.appointment_time = "12:00"
    }
    @IBAction func btn2PM_pressed(_ sender: Any) {
        resetTimeViews()
        view2PM.backgroundColor = UIColor(red: 0/255, green: 50/255, blue: 239/255, alpha: 1)
        lbl2PM.textColor = UIColor.white
        img2.image = UIImage(named: "imgClockWhite")
        
        self.appointment_time = "14:00"
    }
    @IBAction func btn4PM_pressed(_ sender: Any) {
        resetTimeViews()
        view4PM.backgroundColor = UIColor(red: 0/255, green: 50/255, blue: 239/255, alpha: 1)
        lbl4PM.textColor = UIColor.white
        img4.image = UIImage(named: "imgClockWhite")
        
        self.appointment_time = "16:00"
    }
    @IBAction func btn6PM_pressed(_ sender: Any) {
        resetTimeViews()
        view6PM.backgroundColor = UIColor(red: 0/255, green: 50/255, blue: 239/255, alpha: 1)
        lbl6PM.textColor = UIColor.white
        img6.image = UIImage(named: "imgClockWhite")
        
        self.appointment_time = "18:00"
    }
    @IBAction func btn10Min_pressed(_ sender: Any) {
        resetDurationViews()
        view10Min.backgroundColor = UIColor(red: 0/255, green: 50/255, blue: 239/255, alpha: 1)
        lbl10Min.textColor = UIColor.white
        img10m.image = UIImage(named: "imgHalfClockWhite")
        
        self.appointment_duration = "10 minutes"
        self.choosenDurationOptionIndex = 0
        //durationSelected()
    }
    @IBAction func btn20Min_pressed(_ sender: Any) {
        resetDurationViews()
        view20Min.backgroundColor = UIColor(red: 0/255, green: 50/255, blue: 239/255, alpha: 1)
        lbl20Min.textColor = UIColor.white
        img20.image = UIImage(named: "imgHalfClockWhite")
        
        self.appointment_duration = "20 minutes"
        self.choosenDurationOptionIndex = 1
        //durationSelected()
    }
    @IBAction func btn30Min_pressed(_ sender: Any) {
        resetDurationViews()
        view30Min.backgroundColor = UIColor(red: 0/255, green: 50/255, blue: 239/255, alpha: 1)
        lbl30Min.textColor = UIColor.white
        img30.image = UIImage(named: "imgHalfClockWhite")
        
        self.appointment_duration = "30 minutes"
        self.choosenDurationOptionIndex = 2
        //durationSelected()
    }
    @IBAction func btn40Min_pressed(_ sender: Any) {
        resetDurationViews()
        view40Min.backgroundColor = UIColor(red: 0/255, green: 50/255, blue: 239/255, alpha: 1)
        lbl40Min.textColor = UIColor.white
        img40.image = UIImage(named: "imgHalfClockWhite")
        
        self.appointment_duration = "40 minutes"
        self.choosenDurationOptionIndex = 3
        //durationSelected()
    }
    @IBAction func btn50Min_pressed(_ sender: Any) {
        resetDurationViews()
        view50Min.backgroundColor = UIColor(red: 0/255, green: 50/255, blue: 239/255, alpha: 1)
        lbl50Min.textColor = UIColor.white
        img50.image = UIImage(named: "imgHalfClockWhite")
        
        self.appointment_duration = "50 minutes"
        self.choosenDurationOptionIndex = 4
        //durationSelected()
    }
    @IBAction func btn60Min_pressed(_ sender: Any) {
        resetDurationViews()
        view60Min.backgroundColor = UIColor(red: 0/255, green: 50/255, blue: 239/255, alpha: 1)
        lbl60Min.textColor = UIColor.white
        img60.image = UIImage(named: "imgHalfClockWhite")
        
        self.appointment_duration = "60 minutes"
        self.choosenDurationOptionIndex = 5
        //durationSelected()
    }
    @IBAction func btnBack_pressed(_ sender: Any) {
        self.moveBack()
    }
    @IBAction func btnRequestAppointment_pressed(_ sender: Any) {
        
        if appointment_date == dateToString(date: Date(), formate: "MMM dd,yyyy") || appointment_time == dateToString(date: Date(), formate: "HH:mm") {
            
            let alert = UIAlertController(title: "", message: "You cannot book an appointment at current time.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if let broadcaster = self.selected_broadcaster
        {
            let u = CurrentUser.getCurrentUser_From_UserDefaults()
            let app: Appointment = Appointment()
            app.time = self.appointment_time
            app.message = ""
            app.status = Appointment_Status.Pending.rawValue
            app.date = self.appointment_date
            
            app.patientId = u.username
            app.patientName = u.name
            app.patientQbId = u.qbid
            
            app.doctorId = broadcaster.username
            app.doctorName = broadcaster.name
            app.doctorQbId = broadcaster.qbid
            
            Utilities.show_ProgressHud(view: self.view)
            self.dataAccess.add_OR_update_Appointment(appointment: app, delegate: self, senderTag: 2333)
            AppDelegate.send_PUSH_Notification(notification_type: .Appointment_Notification, toUsers: broadcaster.qbid, message: "\(u.name) requested for an appointment.")
        }
    }
    
    func dateToString(date: Date, formate: String)-> String {
        
        let dateFormatter: DateFormatter  = DateFormatter()
        dateFormatter.dateFormat = formate
        return dateFormatter.string(from: date)
    }
    
    func moveBack()
    {
        DispatchQueue.main.async {
            if self.isModal {
                self.dismiss(animated: true, completion: nil)
            }
            else
            {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func resetTimeViews()
    {
        view8AM.backgroundColor = UIColor.white
        view10AM.backgroundColor = UIColor.white
        view12PM.backgroundColor = UIColor.white
        view2PM.backgroundColor = UIColor.white
        view4PM.backgroundColor = UIColor.white
        view6PM.backgroundColor = UIColor.white
        
        lbl8AM.textColor = UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1)
        lbl10AM.textColor = UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1)
        lbl12PM.textColor = UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1)
        lbl2PM.textColor = UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1)
        lbl4PM.textColor = UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1)
        lbl6PM.textColor = UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1)
        
        img8.image = UIImage(named: "imgClock")
        img10.image = UIImage(named: "imgClock")
        img12.image = UIImage(named: "imgClock")
        img2.image = UIImage(named: "imgClock")
        img4.image = UIImage(named: "imgClock")
        img6.image = UIImage(named: "imgClock")
    }
    
    func resetDurationViews()
    {
        view10Min.backgroundColor = UIColor.white
        view20Min.backgroundColor = UIColor.white
        view30Min.backgroundColor = UIColor.white
        view40Min.backgroundColor = UIColor.white
        view50Min.backgroundColor = UIColor.white
        view60Min.backgroundColor = UIColor.white
        
        lbl10Min.textColor = UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1)
        lbl20Min.textColor = UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1)
        lbl30Min.textColor = UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1)
        lbl40Min.textColor = UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1)
        lbl50Min.textColor = UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1)
        lbl60Min.textColor = UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1)
        
        img10m.image = UIImage(named: "imgClockHalf")
        img20.image = UIImage(named: "imgClockHalf")
        img30.image = UIImage(named: "imgClockHalf")
        img40.image = UIImage(named: "imgClockHalf")
        img50.image = UIImage(named: "imgClockHalf")
        img60.image = UIImage(named: "imgClockHalf")
        
    }
    
    
    
//    func updateDateAndTimeValues(date: Date) {
//        let dateFormatterPrint = DateFormatter()
//        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = DateFormatter.Style.long
//
//        self.appointment_date = dateFormatterPrint.string(from: date)
//        self.txtDate.text = self.appointment_date
//    }
    
    //MARK: Riz Change
//    func durationSelected() {
//        // calculate amount to pay before dismissing this action
//        let rateOfBroadcaster = Int((self.selected_broadcaster?.rate)!)
//        let amountToPay = Double(rateOfBroadcaster!) * (Double(self.choosenDurationOptionIndex + 1)/6.0)
//
//        self.appointment_deposit = String(format: "£%0.1f", amountToPay)//"\(Int(amountToPay))"
//        lblEstimatedCost.text = String(format: "£%0.1f", amountToPay)
//    }
    
    func moveToRoot()
    {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func showAlertWith(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }

}

extension RequestAppointmentViewController: Add_Appointment_Delegate, send_Appointment_Notification_Delegate
{
    func Add_Appointment_ResponseSuccess(senderTag: Int, id: Int) {
        print("\n Add_Appointment_ResponseSuccess called ... AND id = \(id) \n")
        
        DispatchQueue.main.async {
      
            
            Utilities.hide_ProgressHud(view: self.view)
            NotificationCenter.default.post(name: Notification.Name(Constants.Notifications_name.getCurrentUser_Appointments_Data), object: nil)
            
            let patient = CurrentUser.getCurrentUser_From_UserDefaults()
            let doctor = self.selected_broadcaster!
            
            // reverting patient <-&&-> doctor position in method because it needs to be changed on server side for now we will keep it this way untill server api got fixed
            self.dataAccess.send_Appointment_Notification(patient: patient, doctor: doctor, delegate: self)
            
            let alert = UIAlertController(title: "", message: "Appointment request sent", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.moveToRoot()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func Add_Appointment_ResponseError(error: NSError) {
        DispatchQueue.main.async {
            Utilities.hide_ProgressHud(view: self.view)
        }
        self.showAlertWith(title: "Error!", message: "Please check your internet connection and try again!")
        print("\n Add_Appointment_ResponseError called ... AND error = \(error.localizedDescription) \n")
    }
    
    func send_Appointment_Notification_Success(msg: String)
    {
        print("\n send_Appointment_Notification_Success called ... AND Message = \(msg) \n")
    }
    
    func send_Appointment_Notification_Error(error: String)
    {
        print("\n send_Appointment_Notification_Error called ... AND error = \(error) \n")
    }
    
}

