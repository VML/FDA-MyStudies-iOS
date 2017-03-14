//
//  ChangePasswordViewController.swift
//  FDA
//
//  Created by Surender Rathore on 3/13/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift



enum CPTextFeildTags : Int {
    case oldPassword = 100
    case newPassword
    case confirmPassword
}

class ChangePasswordViewController: UIViewController {
    
    var tableViewRowDetails : NSMutableArray?
    var newPassword = ""
    var oldPassword = ""
    var confirmPassword = ""
    @IBOutlet var tableView : UITableView?
    @IBOutlet var buttonSubmit : UIButton?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Used to set border color for bottom view
        buttonSubmit?.layer.borderColor = kUicolorForButtonBackground
        self.title = NSLocalizedString(kChangePasswordTitleText, comment: "")
        
        //load plist info
        let plistPath = Bundle.main.path(forResource: "ChangePasswordData", ofType: ".plist", inDirectory:nil)
        tableViewRowDetails = NSMutableArray.init(contentsOfFile: plistPath!)
        
        //Automatically takes care  of text field become first responder and scroll of tableview
        IQKeyboardManager.sharedManager().enable = true
        
        //Used for background tap dismiss keyboard
        let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(ChangePasswordViewController.dismissKeyboard))
        self.tableView?.addGestureRecognizer(tapGesture)
        
        
        //unhide navigationbar
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.addBackBarButton()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        //hide navigationbar
        //self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //Used to show the alert using Utility
    func showAlertMessages(textMessage : String){
        UIUtilities.showAlertMessage("", errorMessage: NSLocalizedString(textMessage, comment: ""), errorAlertActionTitle: NSLocalizedString("OK", comment: ""), viewControllerUsed: self)
    }
    
    //Dismiss key board when clicked on Background
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    func requestToChangePassword() {
         UserServices().changePassword(oldPassword: self.oldPassword, newPassword: self.newPassword, delegate: self)
    }
    
    //MARK: Signin Button Action and validation checks
    @IBAction func submitButtonAction(_ sender: Any) {
        
        if self.oldPassword == ""{
            self.showAlertMessages(textMessage: kMessagePasswordBlank)
            
        }else if self.newPassword == ""{
            self.showAlertMessages(textMessage: kMessageNewPasswordBlank)
        }
        else if Utilities.isPasswordValid(text: self.newPassword) == false{
            self.showAlertMessages(textMessage: kMessageValidatePasswordComplexity)
            
        }
        else if self.newPassword != self.confirmPassword{
            self.showAlertMessages(textMessage: kMessageValidatePasswords)
        }
        else{
           self.requestToChangePassword()
        }
        
    }
    
}
//MARK: TableView Data source
extension ChangePasswordViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewData = tableViewRowDetails?.object(at: indexPath.row) as! NSDictionary
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kSignInTableViewCellIdentifier, for: indexPath) as! SignInTableViewCell
        
        cell.textFieldValue?.tag = indexPath.row + 100
        cell.populateCellData(data: tableViewData, securedText: true)
        
        return cell
    }
}

//MARK: TableView Delegates
extension ChangePasswordViewController :  UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

//MARK: Textfield Delegate
extension ChangePasswordViewController : UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(textField.tag)
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.text!)
        
        let tag = CPTextFeildTags(rawValue: textField.tag)!
        
        switch tag {
        case .oldPassword:
            self.oldPassword = textField.text!
        case .newPassword:
            self.newPassword = textField.text!
        case .confirmPassword:
            self.confirmPassword = textField.text!
            break
        default: break
        }
    }
}

extension ChangePasswordViewController:NMWebServiceDelegate {

    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.addProgressIndicator()
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.removeProgressIndicator()
        
        user.password = self.newPassword

    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")

        self.removeProgressIndicator()

        UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString("Error", comment: "") as NSString, message: error.localizedDescription as NSString)
    }
}
