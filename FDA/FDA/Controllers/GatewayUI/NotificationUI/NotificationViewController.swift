//
//  NotificationViewController.swift
//  FDA
//
//  Created by Ravishankar on 3/1/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit

class NotificationViewController : UIViewController{
    
    @IBOutlet var tableView : UITableView?
    
    
//MARK:- ViewController LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString(kNotificationsTitleText, comment: "")
        
        WCPServices().getNotification(skip:0, delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addBackBarButton()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        
        
        let ud = UserDefaults.standard
        ud.set(false, forKey: kShowNotification)
        ud.synchronize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }

    
//MARK:- 
    
    
    func handleNotificationListResponse(){
        if (Gateway.instance.notification?.count)! > 0{
            self.loadNotificationFromDatabase()
            self.tableView?.isHidden = false
        }
        else {
            self.tableView?.isHidden = true
        }
    }
    
    func loadNotificationFromDatabase(){
        
        DBHandler.loadNotificationListFromDatabase(completionHandler: {(notificationList) in
            
            if notificationList.count > 0 {
                 self.tableView?.isHidden = false
                
                Gateway.instance.notification = notificationList
                self.tableView?.reloadData()
            }
            else{
                
            }
            
            })
    }

    
    
    
    
    
    /**
     
     Used to check the Study State
     
     @param study    Access the data from Study class
     @return Bool
     
     */
    func checkForStudyState(study:Study) -> Bool{
        
        let currentStudy = study
        let participatedStatus = (currentStudy.userParticipateState.status)
        
        switch currentStudy.status {
        case .Active:
            if participatedStatus == .inProgress {
                return true
            }
            else {
                 UIUtilities.showAlertWithTitleAndMessage(title: "", message: NSLocalizedString("Please join study to go forward.", comment: "") as NSString)
            }
        case .Upcoming:
            UIUtilities.showAlertWithTitleAndMessage(title: "", message: NSLocalizedString(kMessageForStudyUpcomingState, comment: "") as NSString)
        case .Paused:
            UIUtilities.showAlertWithTitleAndMessage(title: "", message: NSLocalizedString(kMessageForStudyPausedState, comment: "") as NSString)
        case .Closed:
            UIUtilities.showAlertWithTitleAndMessage(title: "", message: NSLocalizedString(kMessageForStudyClosedState, comment: "") as NSString)
            
        }
        
        return false
    }
    
    
    /**
     
     Used to push the screen to Study Dashboard
     
     @param type    Access data from AppNotification class and NotificationSubType Enum

     */
    func pushToStudyDashboard(type:AppNotification.NotificationSubType?){
        
        let viewController:StudyDashboardTabbarViewController?
        let storyboard = UIStoryboard(name: "Study", bundle: nil)
        if type != nil {
            
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            
            viewController = storyboard.instantiateViewController(withIdentifier: kStudyDashboardTabbarControllerIdentifier) as? StudyDashboardTabbarViewController
            
            switch type! as  AppNotification.NotificationSubType{
            case .Study:
                
                viewController?.selectedIndex = 0
                self.navigationController?.pushViewController(viewController!, animated: true)
            case .Resource:
                
                viewController?.selectedIndex = 2
                self.navigationController?.pushViewController(viewController!, animated: true)
            case .Activity:
                
                viewController?.selectedIndex = 1
                self.navigationController?.pushViewController(viewController!, animated: true)
            default: break
                
            }
        }
    }
}

//MARK:- TableView Datasource
extension NotificationViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (Gateway.instance.notification?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : NotificationTableViewCell?
        
        cell = tableView.dequeueReusableCell(withIdentifier:kNotificationTableViewCellIdentifier , for: indexPath) as? NotificationTableViewCell
        
        cell?.populateCellWith(appNotification: (Gateway.instance.notification?[indexPath.row])!)
        cell?.backgroundColor = UIColor.clear
        return cell!
    }
}


//MARK:- TableView Delegates
extension NotificationViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let appNotif = (Gateway.instance.notification?[indexPath.row])!
        
        if Utilities.isValidValue(someObject: appNotif.studyId as AnyObject?) {
            
            if Gateway.instance.studies!.contains(where: { $0.studyId == appNotif.studyId }){
                
              let index =  Gateway.instance.studies?.index(where: { $0.studyId == appNotif.studyId })
                
                //check status for study
                if self.checkForStudyState(study: (Gateway.instance.studies?[index!])!) {
                    Study.updateCurrentStudy(study:(Gateway.instance.studies?[index!])! )
                    self.pushToStudyDashboard(type:appNotif.subType )
                }
            }
        }
    }
}


//MARK:- WebService Delegate
extension NotificationViewController:NMWebServiceDelegate {
    
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.addProgressIndicator()
    }
    
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName) Response : \(response)")
        self.removeProgressIndicator()
        
        if requestName as String == WCPMethods.notifications.method.methodName {
           self.handleNotificationListResponse()
        }
    }
 
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.removeProgressIndicator()
        
    }
}


