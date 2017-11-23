//
//  FetalKickCounterStepViewController.swift
//  FDA
//
//  Created by Arun Kumar on 2/28/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import ResearchKit
import IQKeyboardManagerSwift
import IQKeyboardManagerSwift
import ActionSheetPicker_3_0




let kFetalKickCounterStepDefaultIdentifier = "defaultIdentifier"
let kTapToRecordKick = "TAP TO RECORD A KICK"

let kConfirmMessage =  "You have recorded "
let kConfirmMessage2 =  " Proceed to confirming the time taken?"

let kGreaterValueMessage = "This activity records the time it takes to feel "

let kProceedTitle = "Proceed"

class FetalKickCounterStepViewController:  ORKStepViewController {
    
    //ORKStepViewController ORKActiveStepViewController
    
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    
    
    @IBOutlet weak var startButton:UIButton?   // button to start task as well as increment the counter
    @IBOutlet weak var startTitleLabel:UILabel? // displays the title
    @IBOutlet weak var timerLabel:UILabel?      //  displays the current timer Value
    @IBOutlet weak var counterTextField:UITextField? // displays current kick counts
    @IBOutlet weak var editCounterButton:UIButton?  // used to edit the counter value
    @IBOutlet weak var seperatorLineView:UIView? // separator line
    
    @IBOutlet weak var submitButton:UIButton? // button to submit response to server
    
    @IBOutlet weak var editTimerButton:UIButton?
    
    var kickCounter:Int? = 0        // counter
    var timer:Timer? = Timer()      //  timer for the task
    var timerValue:Int? = 0         // TimerValue
    
    var totalTime:Int? = 0          // Total duration
    var maxKicksAllowed:Int? = 0
    
    var taskResult:FetalKickCounterTaskResult = FetalKickCounterTaskResult(identifier: kFetalKickCounterStepDefaultIdentifier)
  
    
    //Mark: ORKStepViewController overriden methods
    
    
    override init(step: ORKStep?) {
        super.init(step: step)
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var initialTime = 0
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        
        notificationCenter.addObserver(self, selector: #selector(appBecameActive), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        
         submitButton?.layer.borderColor =   kUicolorForButtonBackground
        
        if let step = step as? FetalKickCounterStep {
            //step.counDownTimer = 600
            
            let ud = UserDefaults.standard
            //ud.set(true, forKey: "FKC")
            
            //ud.set(Study.currentActivity?.actvityId, forKey: "FetalKickActivityId")
            //ud.set(Study.currentStudy?.studyId, forKey: "FetalKickStudyId")
            let activityId = ud.value(forKey:"FetalKickActivityId" ) as! String?
            var differenceInSec = 0
            var autoStartTimer = false
            if  ud.bool(forKey: "FKC")
                && activityId != nil
                && activityId == Study.currentActivity?.actvityId
                 {
                    
                let previousTimerStartDate = ud.object(forKey: "FetalKickStartTimeStamp") as! Date
                let currentDate = Date()
                differenceInSec = Int(currentDate.timeIntervalSince(previousTimerStartDate))
                autoStartTimer = true
            }
        
            /*
            if differenceInSec > step.counDownTimer!{
                //task is completed
                
                let previousKicks:Int? = ud.value(forKey:"FetalKickCounterValue" ) as? Int
                
                self.kickCounter = (previousKicks == nil ? 0 : previousKicks!)
                
                self.taskResult.totalKickCount = self.kickCounter!
                
               // self.goForward()
                self.startButton?.isHidden = true
                self.startTitleLabel?.isHidden = true
                self.submitButton?.isHidden =  false
            } */
            //else {
                if differenceInSec >= 0 {
                    initialTime =   initialTime + differenceInSec
                }
                
                print("difference \(differenceInSec)")
                //Setting the maximum time allowed for the task
                 self.totalTime = step.counDownTimer! //10
            
                //Setting the maximum Kicks allowed
                self.maxKicksAllowed = step.totalCounts!
            
                //Calculating time in required Format
                let hours =   Int(initialTime) / 3600
                let minutes =  Int(initialTime) / 60 % 60
                let seconds =   Int(initialTime) % 60
                
                self.timerValue =  initialTime //self.totalTime    // step.counDownTimer!
                
                self.timerLabel?.text = (hours < 10 ? "0\(hours):" : "\(hours):") + (minutes < 10 ? "0\(minutes):" : "\(minutes):")   + (seconds < 10 ? "0\(seconds)" : "\(seconds)")
                //self.taskResult.duration = self.totalTime!
                
                if autoStartTimer{
                    
                    let previousKicks:Int? = ud.value(forKey:"FetalKickCounterValue" ) as? Int
                    
                    self.kickCounter = (previousKicks == nil ? 0 : previousKicks!)
                    
                    self.setCounter()
                    
                    self.startButtonAction(UIButton())
                }
            //}
            
            backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                
            })
            
            // enables the IQKeyboardManager
            IQKeyboardManager.sharedManager().enable = true
            
            // adding guesture to view to support outside tap
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FetalKickCounterStepViewController.handleTap(_:)))
            gestureRecognizer.delegate = self
            self.view.addGestureRecognizer(gestureRecognizer)
            }
        
       // backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
       //     UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier!)
       // })
    
        
    }
    
    
    override func hasNextStep() -> Bool {
        super.hasNextStep()
        return true
    }
    
    override func goForward(){
        
        super.goForward()
        
    }
    
    override var result: ORKStepResult? {
        
        let orkResult = super.result
        orkResult?.results = [self.taskResult]
        return orkResult
        
    }
    
    
    //Mark:Utility Methods
    
    /*
     updates the timer value
     */
    
    func setCounterValue(){
        
            if self.kickCounter! < 10{
                counterTextField?.text = "00" + "\(self.kickCounter!)"
            }
            else if self.kickCounter! >= 10 && self.kickCounter! < 100{
                counterTextField?.text = "0" + "\(self.kickCounter!)"
            }
            else {
                counterTextField?.text = "\(self.kickCounter!)"
            }
    }
    
    
    func setCounter() {
        
        
        DispatchQueue.global(qos: .background).async {
            if self.timerValue! < 0 {
                self.timerValue = 0
                self.timer?.invalidate()
                self.timer = nil
                
                // self.result = ORKStepResult.init(stepIdentifier: (step?.identifier)!, results: [taskResult])
                
                DispatchQueue.main.async{
                    
                    //self.perform(#selector(self.goForward))
                    self.startButton?.isHidden = true
                    self.startTitleLabel?.isHidden = true
                    self.submitButton?.isHidden =  false
                }
                
            }
            else{
                self.timerValue = self.timerValue! + 1  //-  1
            }
            
            if self.timerValue! >= 0{
                
                
                DispatchQueue.main.async{
                    
                    if self.timerValue! > self.totalTime!{
                    self.setResults()
                    self.showAlertOnCompletion()
                       
                    }
                    else{
                    self.editCounterButton?.isHidden = false
                    self.setTimerValue()
                    
                    }
                    
                }
                
            }
        }
        
    }
    
    func setTimerValue(){
        
        let hours = Int(self.timerValue!) / 3600
        let minutes = Int(self.timerValue!) / 60 % 60
        let seconds = Int(self.timerValue!) % 60
        
        self.timerLabel?.text = (hours < 10 ? "0\(hours):" : "\(hours):") + (minutes < 10 ? "0\(minutes):" : "\(minutes):")   + (seconds < 10 ? "0\(seconds)" : "\(seconds)")
        
        self.taskResult.totalKickCount = self.kickCounter!
    }
    
    /*
     handleTap method detects the tap gesture event
     @param  sender is tapguesture instance
     */
    func handleTap(_ sender:UITapGestureRecognizer)   {
        counterTextField?.resignFirstResponder()
    }
    
    func appMovedToBackground() {
        
        print("App moved to background!")
        
        let ud = UserDefaults.standard
        if ud.object(forKey: "FetalKickStartTimeStamp") != nil{
            
            ud.set(true, forKey: "FKC")
            
            ud.set(Study.currentActivity?.actvityId, forKey: "FetalKickActivityId")
            ud.set(Study.currentStudy?.studyId, forKey: "FetalKickStudyId")
            
            ud.set(self.kickCounter, forKey: "FetalKickCounterValue")
            
            //check if runid is saved
            if ud.object(forKey: "FetalKickCounterRunid") == nil {
                ud.set(Study.currentActivity?.currentRun.runId, forKey: "FetalKickCounterRunid")
            }
            
            ud.synchronize()
        }
        
    }
    
    
    func appBecameActive() {
        print("App moved to forground!")
        
        let ud = UserDefaults.standard
        ud.set(false, forKey: "FKC")
        
        ud.synchronize()
    }

    func showAlertForGreaterValues(){
        
         let message = kGreaterValueMessage + "\(self.maxKicksAllowed!) kicks, " + "please enter " + "\(self.maxKicksAllowed!) kicks only"
        
        Utilities.showAlertWithTitleAndMessage(title: NSLocalizedString(kMessage, comment: "") as NSString, message: message as NSString)
        
    }
    
    func setResults()  {
        //Show alert for time Taken for those kicks and user can edit them---PENDING
        
        
        self.timer?.invalidate()
        self.timer = nil
        self.editTimerButton?.isHidden = false
        self.taskResult.totalKickCount = self.kickCounter == nil ? 0 : self.kickCounter!
        
        self.taskResult.duration = self.timerValue == nil ? 0 : self.timerValue!
        
        
    }
    
    
    func getTimerArray() -> Array<Any>{
        
        let hoursMax =   Int(self.totalTime!) / 3600
        let minutesMax =  Int(self.totalTime!) / 60 % 60
        let secondsMax =   Int(self.totalTime!) % 60
        
        var hoursArray:Array<String> = []
        var minutesArray:Array<String> = []
        var secondsArray:Array<String> = []
        var i = 0
        while i <= hoursMax{
            hoursArray.append("\(i)" + " h")
            minutesArray.append("\(i)" + " m")
            secondsArray.append("\(i)" + " s")
            i += 1
        }
        i = hoursMax + 1
        while i <= 59{
            minutesArray.append("\(i)" + " m")
            secondsArray.append("\(i)" + " s")
            i += 1
        }
        
        return [hoursArray,minutesArray,secondsArray]
    }
    
    func getIndexes() -> Array<Any>{
        
        
        let hoursIndex =   Int(self.timerValue!) / 3600
        let minutesIndex =  Int(self.timerValue!) / 60 % 60
        let secondsIndex =   Int(self.timerValue!) % 60
        
        return [(hoursIndex > 0 ? hoursIndex + 1 : 0) ,(minutesIndex > 0 ? minutesIndex + 1 : 0) ,(secondsIndex > 0 ? secondsIndex + 1 : 0)]
        
        
 }
    
    
    func showAlertOnCompletion(){
        
        DispatchQueue.main.async{
            
            //self.perform(#selector(self.goForward))
            self.startButton?.isHidden = true
            self.startTitleLabel?.isHidden = true
            self.submitButton?.isHidden =  false
        }
        
        
        let timeConsumed = (self.timerLabel?.text!)
        let message = kConfirmMessage + "\(self.kickCounter!) kicks in " + "\(timeConsumed!) time." + kConfirmMessage2
        
        UIUtilities.showAlertMessageWithTwoActionsAndHandler(NSLocalizedString(kMessage, comment: ""), errorMessage: NSLocalizedString(message, comment: ""), errorAlertActionTitle: NSLocalizedString(kProceedTitle, comment: ""),
                                                             errorAlertActionTitle2: NSLocalizedString(kTitleCancel, comment: ""), viewControllerUsed: self,
                                                             action1: {
                                                                
                                                 //self.setResults()
                                                   self.goForward()
        },
                                                             action2: {
                                                                
        })
        
    }
    
    
    //Mark:IBActions
    
    
    @IBAction func editCounterButtonAction(_ sender:UIButton){
        counterTextField?.isUserInteractionEnabled = true
        counterTextField?.isHidden = false
        seperatorLineView?.isHidden =  false
        counterTextField?.becomeFirstResponder()
    }
    
    @IBAction func startButtonAction(_ sender:UIButton){
        
        if Int((self.counterTextField?.text)!)! == 0 {
            
            if self.timer == nil {
                // first time
                
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(FetalKickCounterStepViewController.setCounter), userInfo: nil, repeats: true)
                
                //save start time stamp
                let ud = UserDefaults.standard
                if ud.object(forKey: "FetalKickStartTimeStamp") == nil {
                    ud.set(Date(),forKey:"FetalKickStartTimeStamp")
                }
                ud.synchronize()
                
                RunLoop.main.add(self.timer!, forMode: .commonModes)
                
                // start button image and start title changed
                startButton?.setImage(UIImage(named: "kick_btn1.png"), for: .normal)
                startTitleLabel?.text = NSLocalizedString(kTapToRecordKick, comment:"")
            }
            else{
                self.kickCounter = self.kickCounter! + 1
                
                editCounterButton?.isHidden = false
                self.counterTextField?.text =  self.kickCounter! < 10 ?  ("0\(self.kickCounter!)" == "00" ? "000" : "00\(self.kickCounter!)") : (self.kickCounter! >= 100 ? "\(self.kickCounter!)" : "0\(self.kickCounter!)" )
                
                
            }
            
        }
        else{
            if self.kickCounter! < self.maxKicksAllowed! {
               self.kickCounter = self.kickCounter! + 1
                
                editCounterButton?.isHidden = false
                self.counterTextField?.text =  self.kickCounter! < 10 ?  ("0\(self.kickCounter!)" == "00" ? "000" : "00\(self.kickCounter!)") : (self.kickCounter! >= 100 ? "\(self.kickCounter!)" : "0\(self.kickCounter!)" )
                
            }
            else if self.kickCounter! == self.maxKicksAllowed!{
                self.setResults()
               self.showAlertOnCompletion()
            }
            else if self.kickCounter! > self.maxKicksAllowed!{
                self.showAlertForGreaterValues()
            }
        }
        
            
        
    }
    @IBAction func submitButtonAction(_ sender:UIButton){
        
        self.taskResult.duration = self.timerValue!
        
        self.taskResult.totalKickCount = self.kickCounter == nil ? 0 : self.kickCounter!
        self.perform(#selector(self.goForward))
    }
    
    @IBAction func editTimerButtonAction(_ sender:UIButton){
//        let datePicker = ActionSheetDatePicker(title: "CountDownTimer:", datePickerMode: UIDatePickerMode.countDownTimer, selectedDate: NSDate() as Date!, doneBlock: {
//            picker, value, index in
//
//            print("value = \(value)")
//            print("index = \(index)")
//            print("picker = \(picker)")
//
//            self.timerValue = value! as! Int
//            self.setTimerValue()
//
//            return
//        }, cancel: { ActionStringCancelBlock in return }, origin: sender.superview!.superview)
//         datePicker?.countDownDuration =  self.timerValue! > 0 ? Double(self.timerValue!) : 0.0
//
//        datePicker?.show()
    
        let timerArray = self.getTimerArray()
        let defaultTime = self.getIndexes()
        
        
        let acp = ActionSheetMultipleStringPicker(title: "Select Time", rows: timerArray, initialSelection: defaultTime, doneBlock: {
                picker, values, indexes in
                
                print("values = \(values)")
                print("indexes = \(indexes)")
          
          
            let result:Array<String> =  (indexes as! Array<String>)
            let hours = result.first?.components(separatedBy: CharacterSet.init(charactersIn: " h"))
            let minutes = result[1].components(separatedBy: CharacterSet.init(charactersIn: " m"))
            let seconds = result.last?.components(separatedBy: CharacterSet.init(charactersIn: " s"))
            
            
            let hoursValue:Int = hours?.count != 0 ? Int(hours!.first!)! : 0
            let minuteValue:Int = minutes.count != 0 ? Int(minutes.first!)! : 0
            let secondsValue:Int = seconds?.count != 0 ? Int(seconds!.first!)! : 0
            
            self.timerValue = hoursValue * 3600 + minuteValue * 60 + secondsValue
          
          if hoursValue * 3600 + minuteValue * 60 + secondsValue >= self.totalTime!{
            
            let hours = Int(self.totalTime!) / 3600
            let minutes = Int(self.totalTime!) / 60 % 60
            let seconds = Int(self.totalTime!) % 60
            
            let value = (hours < 10 ? "0\(hours):" : "\(hours):") + (minutes < 10 ? "0\(minutes):" : "\(minutes):")   + (seconds < 10 ? "0\(seconds)" : "\(seconds)")
            
            Utilities.showAlertWithTitleAndMessage(title: kMessage as NSString, message: ("Please select a valid time(Max " + value + ")") as NSString)
          }
          else{
             self.setTimerValue()
          }
                print("picker = \(picker)")
                return
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
      
        acp?.setTextColor(kUIColorForSubmitButtonBackground)
        acp?.pickerBackgroundColor = UIColor.white
        acp?.toolbarBackgroundColor = UIColor.white
        acp?.toolbarButtonsColor = kUIColorForSubmitButtonBackground
        acp?.show()
    }
}

class FetalKickCounterStepType : ORKActiveStep {
    static func stepViewControllerClass() -> FetalKickCounterStepViewController.Type {
        return FetalKickCounterStepViewController.self
    }
}


/*
 FetalKickCounterTaskResult holds the tak result
 @param totalKickCount contains the Kick count
 @param duration is the task duration
 */

open class FetalKickCounterTaskResult: ORKResult {
    
    open var totalKickCount:Int = 0
    open var duration:Int = 0
    
    override open var description: String {
        get {
            return "hitCount:\(totalKickCount), duration:\(duration)"
        }
    }
    
    override open var debugDescription: String {
        get {
            return "hitCount:\(totalKickCount), duration:\(duration)"
        }
    }
}



//Mark: GetureRecognizer delegate
extension FetalKickCounterStepViewController:UIGestureRecognizerDelegate{
    func gestureRecognizer(_: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
}



//Mark:TextField Delegates
extension FetalKickCounterStepViewController:UITextFieldDelegate {
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if (textField == counterTextField)
        {
            if (textField.text?.characters.count)! > 0 {
                if Int(textField.text!)! == 0 {
                    textField.text = ""
                }
            }
        }
    }
    
        
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (textField == counterTextField)
        {
            counterTextField?.resignFirstResponder()
            
            if textField.text?.characters.count == 0 {
               textField.text = "000"
                self.kickCounter = 000
            }
            
            
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        
        if textField == counterTextField! && ( Utilities.isValidValue(someObject: counterTextField?.text as AnyObject?) == false || Int((counterTextField?.text)!)! <= 0) {
            counterTextField?.resignFirstResponder()
            if textField.text?.characters.count == 0 || (Int((counterTextField?.text)!) != nil) {
                textField.text = "000"
                self.kickCounter = 000
            }
            
            
            //Utilities.showAlertWithMessage(alertMessage:kAlertPleaseEnterValidValue)
        }
        else{
            self.kickCounter = Int((counterTextField?.text)!)
            
            if textField.text?.characters.count == 2{
                counterTextField?.text = "0" + textField.text!
                self.kickCounter  = (Int((counterTextField?.text)!))
            }
            else if (textField.text?.characters.count)! >= 3{
                let finalValue = (Int((counterTextField?.text)!))
                
                if finalValue! < 10{
                    counterTextField?.text = "00" + "\(finalValue!)"
                }
                else if finalValue! >= 10 && finalValue! < 100{
                     counterTextField?.text = "0" + "\(finalValue!)"
                }
                else {
                     counterTextField?.text = "\(finalValue!)"
                }
                
            }
            else if textField.text?.characters.count == 1 {
                let finalValue = (Int((counterTextField?.text)!))
                counterTextField?.text = "00" + "\(finalValue!)"
            }
            
            if self.kickCounter == self.maxKicksAllowed!{
                self.setResults()
                self.showAlertOnCompletion()
            }
            
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let finalString = textField.text! + string
        
        if textField == counterTextField && finalString.characters.count > 0{
            
            if Int(finalString)! <= self.maxKicksAllowed!{
                
                return true
            }
            else{
                
                self.showAlertForGreaterValues()
                
                return false
            }
        }
        else {
            return true
        }
        
    }
}

