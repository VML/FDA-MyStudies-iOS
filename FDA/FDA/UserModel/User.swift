//
//  User.swift
//  FDA
//
//  Created by Arun Kumar on 2/2/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation


enum UserType:Int{
    case AnonymousUser = 0
    case FDAUser
}

enum LogoutReason:String{
    case user_action
    case error
    case security_jailbroken
}


let kUserValueForOS = "ios"

let kCFBundleShortVersionString = "CFBundleShortVersionString"
let kTerms = "terms"
let kPolicy = "privacy"

//MARK: User
class User{
    
    var firstName : String?
    var lastName :String?
    var emailId : String?
    var settings : Settings?
    var userType : UserType?
    var userId : String!
    var password : String? = ""
   
    
    //var confirmPassword : String? = ""
    var verified : Bool!
    var authToken: String!
    var participatedStudies:Array<UserStudyStatus>! = []
    var participatedActivites:Array<UserActivityStatus>! = []
    var logoutReason : LogoutReason = .user_action
    var isLoginWithTempPassword:Bool = false
    //sharedInstance
    private static var _currentUser: User?
    
    static var currentUser: User {
        if _currentUser == nil { _currentUser = User() }
        return _currentUser!
    }
    
    static func resetCurrentUser() {
        _currentUser = nil
    }
    
    
    init() {
        self.firstName = ""
        self.lastName = ""
        self.emailId  = ""
        self.settings = Settings()
        self.userType = UserType.AnonymousUser
        self.userId = ""
        self.verified = false
    }
    
    init(firstName:String?,lastName:String?,emailId: String?,userType: UserType?,userId:String?){
        self.firstName = firstName
        self.lastName = lastName
        self.emailId = emailId
        self.userType = userType
        self.userId = userId
    }
    
    func setFirstName(firstName:String) {
        self.firstName = firstName
    }
    func setLastName(lastName:String) {
        self.lastName = lastName
    }
    func setEmailId(emailId:String) {
        self.emailId = emailId
    }
    func setUserType(userType:UserType) {
        self.userType = userType
    }
    func setUserId(userId:String) {
        self.userId = userId
    }
    func getFullName() -> String {
        return firstName! + " " + lastName!
    }
    
    func setUser(dict:NSDictionary)  {
        
        if Utilities.isValidObject(someObject: dict){
            
            if Utilities.isValidValue(someObject: dict[kUserFirstName] as AnyObject ){
                self.firstName = dict[kUserFirstName] as? String
            }
            if Utilities.isValidValue(someObject: dict[kUserLastName] as AnyObject ){
                self.lastName = dict[kUserLastName] as? String
            }
            if Utilities.isValidValue(someObject: dict[kUserEmailId] as AnyObject ){
                self.emailId = dict[kUserEmailId] as? String
            }
            if Utilities.isValidObject(someObject: dict[kUserSettings] as AnyObject ) {
                self.settings?.setSettings(dict: dict[kUserSettings] as! NSDictionary)
            }
            if Utilities.isValidValue(someObject: dict[kUserId] as AnyObject )  {
                self.userId = dict[kUserId] as? String
            }
            
            
            
        }
        else{
            Logger.sharedInstance.debug("User Dictionary is null:\(dict)")
        }
        
        
        
    }
    func getUserProfileDict() -> NSMutableDictionary {
        let dataDict = NSMutableDictionary()
        
        if self.userType == .FDAUser {
            
            if self.userId != nil{
                dataDict.setValue(self.userId, forKey:(kUserId as NSCopying) as! String)
            }
            let profileDict = NSMutableDictionary()
            
            
            if self.firstName != nil{
                profileDict.setValue(self.firstName, forKey:(kUserFirstName as NSCopying) as! String)
            }
            else{
                profileDict.setValue("", forKey:(kUserFirstName as NSCopying) as! String)
            }
            if self.lastName != nil{
                profileDict.setValue(self.lastName, forKey:(kUserLastName as NSCopying) as! String)
            }
            else{
                profileDict.setValue("", forKey:(kUserLastName as NSCopying) as! String)
            }
            
            let infoDict = NSMutableDictionary()
            
            infoDict.setValue(kUserValueForOS, forKey:kUserOS)
            
            
            if let version = Bundle.main.infoDictionary?[kCFBundleShortVersionString] as? String {
                infoDict.setValue(version, forKey:kUserAppVersion)
            }
            
            dataDict.setObject(profileDict, forKey:kUserProfile as NSCopying)
            dataDict.setObject(profileDict, forKey:kUserInfo as NSCopying)
            
        }
        
        return dataDict
        
    }
    
    func udpateCompletionAndAdherence(studyId:String,completion:Int,adherence:Int) -> UserStudyStatus{
        
        
        let studies = self.participatedStudies as Array<UserStudyStatus>
        if let study =   studies.filter({$0.studyId == studyId}).first {
            
            study.adherence = adherence
            study.completion = completion
            
            
            return study
        }
        else {
           
            
            let studyStatus = UserStudyStatus()
            
            studyStatus.studyId = studyId
            studyStatus.adherence = adherence
            studyStatus.completion = completion
            self.participatedStudies.append(studyStatus)
            
           
            
            return studyStatus
        }
        
    }

    
    //MARK:Study Bookmark
    func isStudyBookmarked(studyId:String) -> Bool{
        
        let studies = self.participatedStudies as Array<UserStudyStatus>
        if let study =   studies.filter({$0.studyId == studyId}).first {
            return study.bookmarked
        }
        return false
        
    }
    
    
    func bookmarkStudy(studyId:String) -> UserStudyStatus{
        
        
        let studies = self.participatedStudies as Array<UserStudyStatus>
        if let study =   studies.filter({$0.studyId == studyId}).first {
            study.bookmarked = true
            Logger.sharedInstance.info("Bookmark: study is bookmarked : \(studyId)")
            
            return study
        }
        else {
            Logger.sharedInstance.info("Bookmark: study not found : \(studyId)")
            
            let studyStatus = UserStudyStatus()
            studyStatus.bookmarked = true
            studyStatus.studyId = studyId
            
            self.participatedStudies.append(studyStatus)
            
            Logger.sharedInstance.info("Bookmark: study is bookmarked : \(studyId)")
            
            return studyStatus
        }
        
    }
    
    func removeBookbarkStudy(studyId:String) -> UserStudyStatus?{
        
        let studies = self.participatedStudies as Array<UserStudyStatus>
        if let study =   studies.filter({$0.studyId == studyId}).first {
            study.bookmarked = false
            Logger.sharedInstance.info("Bookmark: study is removed from bookmark : \(studyId)")
            return study
        }
        return nil
    }
    
    
    
    
    //MARK:Activity Bookmark
    func isActivityBookmarked(studyId:String,activityId:String) -> Bool{
        
        let activityes = self.participatedActivites as Array<UserActivityStatus>
        if let activity =   activityes.filter({$0.studyId == studyId && $0.activityId == activityId}).first {
            return activity.bookmarked
        }
        return false
        
    }
    
    
    func bookmarkActivity(studyId:String,activityId:String) -> UserActivityStatus{
        
        
        let activityes = self.participatedActivites as Array<UserActivityStatus>
        if let activity =   activityes.filter({$0.studyId == studyId && $0.activityId == activityId}).first {
            activity.bookmarked = true
            Logger.sharedInstance.info("Bookmark: activity is bookmarked : \(studyId)")
            return activity
        }
        else {
            Logger.sharedInstance.info("Bookmark: activity not found : \(studyId)")
            
            let activityStatus = UserActivityStatus()
            activityStatus.bookmarked = true
            activityStatus.studyId = studyId
            activityStatus.activityId = activityId
            self.participatedActivites.append(activityStatus)
            
            Logger.sharedInstance.info("Bookmark: activity is bookmarked : \(studyId)")
            return activityStatus
        }
        
    }
    
    func removeBookbarkActivity(studyId:String,activityId:String){
        
        let activityes = self.participatedActivites as Array<UserActivityStatus>
        if let activity =   activityes.filter({$0.studyId == studyId && $0.activityId == activityId}).first {
            activity.bookmarked = true
            Logger.sharedInstance.info("Bookmark: activity is removed from bookmarked : \(studyId)")
        }
    }
    
    //MARK:Study Status
    func updateStudyStatus(studyId:String,status:UserStudyStatus.StudyStatus)->UserStudyStatus{
        
        let studies = self.participatedStudies as Array<UserStudyStatus>
        if let study =   studies.filter({$0.studyId == studyId}).first {
            study.status = status
            Logger.sharedInstance.info("User Study Status: study is updated : \(studyId)")
            return study
        }
        else {
            Logger.sharedInstance.info("User Study Status: study not found : \(studyId)")
            
            let studyStatus = UserStudyStatus()
            studyStatus.status = status
            studyStatus.studyId = studyId
            self.participatedStudies.append(studyStatus)
            
            Logger.sharedInstance.info("User Study Status: study is updated : \(studyId)")
            return studyStatus
        }
    }
    
    func updateParticipantId(studyId:String,participantId:String)->UserStudyStatus{
        
        let studies = self.participatedStudies as Array<UserStudyStatus>
        if let study =   studies.filter({$0.studyId == studyId}).first {
            study.participantId = participantId
            Logger.sharedInstance.info("User Study Status: study is updated : \(studyId)")
            return study
        }
        else {
            Logger.sharedInstance.info("User Study Status: study not found : \(studyId)")
            
            let studyStatus = UserStudyStatus()
            studyStatus.participantId = participantId
            studyStatus.studyId = studyId
            self.participatedStudies.append(studyStatus)
            
            Logger.sharedInstance.info("User Study Status: study is updated : \(studyId)")
            return studyStatus
        }
    }
    
    func getStudyStatus(studyId:String) -> UserStudyStatus.StudyStatus{
        
        let studies = self.participatedStudies as Array<UserStudyStatus>
        if let study =   studies.filter({$0.studyId == studyId}).first {
            return study.status
        }
        return .yetToJoin
    }
    
    //MARK:Activity Status
    func updateActivityStatus(studyId:String,activityId:String,runId:String,status:UserActivityStatus.ActivityStatus) -> UserActivityStatus{
        
        let activityes = self.participatedActivites as Array<UserActivityStatus>
        if let activity =   activityes.filter({$0.activityId == activityId && $0.activityRunId == runId}).first {
            activity.status = status
            Logger.sharedInstance.info("User Activity Status: activity is updated : \(studyId)")
            return activity
        }
        else {
            Logger.sharedInstance.info("User Activity Status: activity not found : \(studyId)")
            
            let activityStatus = UserActivityStatus()
            activityStatus.status = status
            activityStatus.studyId = studyId
            activityStatus.activityId = activityId
            activityStatus.activityRunId = runId
            self.participatedActivites.append(activityStatus)
            return activityStatus
            
            Logger.sharedInstance.info("User Activity Status: activity is updated : \(studyId)")
        }
    }
    
    func getActivityStatus(studyId:String,activityId:String) -> UserActivityStatus.ActivityStatus?{
        
        let activityes = self.participatedActivites as Array<UserActivityStatus>
        if let activity =   activityes.filter({$0.activityId == activityId}).first {
            return activity.status
        }
        return .yetToJoin
    }
    
    
}

//MARK:User Settings
class Settings{
    
    var remoteNotifications : Bool?
    var localNotifications :Bool?
    var touchId :Bool?
    var passcode :Bool?
    var leadTime :String?
     var locale : String?
    
    init() {
        self.remoteNotifications = false
        self.localNotifications = false
        self.touchId  = false
        self.passcode = false
        self.leadTime = "00:00"
        self.locale = ""
    }
    
    init(remoteNotifications:Bool?,localNotifications:Bool?,touchId: Bool?,passcode:Bool?){
        self.remoteNotifications = remoteNotifications
        self.localNotifications = localNotifications
        self.touchId = touchId
        self.passcode = passcode
    }
    
    func setRemoteNotification(value : Bool){
        self.remoteNotifications = value
    }
    func setLocalNotification(value : Bool){
        self.localNotifications = value
    }
    func setTouchId(value : Bool){
        self.touchId = value
    }
    func setPasscode(value : Bool){
        self.passcode = value
    }
    func setLeadTime(value:String) {
        self.leadTime = value
    }
    
    
    func setSettings(dict:NSDictionary)  {
        
        if Utilities.isValidObject(someObject: dict){
            
            if  Utilities.isValidValue(someObject: dict[kSettingsRemoteNotifications] as AnyObject){
                self.remoteNotifications = dict[kSettingsRemoteNotifications] as? Bool
            }
            if Utilities.isValidValue(someObject: dict[kSettingsLocalNotifications] as AnyObject){
                self.localNotifications = dict[kSettingsLocalNotifications] as? Bool
            }
            if Utilities.isValidValue(someObject: dict[kSettingsPassCode] as AnyObject){
                self.passcode = dict[kSettingsPassCode] as? Bool
            }
            if Utilities.isValidValue(someObject: dict[kSettingsTouchId] as AnyObject){
                self.touchId = dict[kSettingsTouchId] as? Bool
            }
            if Utilities.isValidValue(someObject: dict[kSettingsLeadTime] as AnyObject){
                self.leadTime = dict[kSettingsLeadTime] as? String
            }
            if Utilities.isValidValue(someObject: dict[kLocale] as AnyObject )  {
                self.locale = dict[kLocale] as? String
            }

            
        }
        else{
            Logger.sharedInstance.debug("Settings Dictionary is null:\(dict)")
        }
        
        
    }
}

//MARK: StudyStatus
class UserStudyStatus{
    
    enum StudyStatus:Int {
        
        case yetToJoin
        case notEligible
        case inProgress
        case completed
        case withdrawn
        
        var sortIndex : Int {
            switch self {
            case .inProgress:
                return 0
            case .yetToJoin:
                return 1
            case .completed:
                return 2
            case .withdrawn:
                return 3
            case .notEligible:
                return 4
                
            }
        }
        
        var description:String {
            switch self {
            case .yetToJoin:
                return "Yet To Join"
            case .inProgress:
                return "In Progress"
            case.completed:
                return "Completed"
            case .notEligible:
                return "Not Eligible"
            case .withdrawn:
                return "Withdrawn"
                
            }
        }
        
        var paramValue:String {
            switch self {
            case .yetToJoin:
                return "yetToJoin"
            case .inProgress:
                return "inProgress"
            case.completed:
                return "completed"
            case .notEligible:
                return "notEligible"
            case .withdrawn:
                return "withdrawn"
                
            }
        }

    }
    
    var bookmarked:Bool = false
    var studyId:String! = ""
    var status:StudyStatus = .yetToJoin
    var consent:String! = ""
    var joiningDate:Date!
    var completion:Int = 0
    var adherence:Int = 0
    var participantId:String?
    
    init() {
        
    }
    
    init(detail:Dictionary<String, Any>){
        
        if Utilities.isValidObject(someObject: detail as AnyObject?){
            
            if  Utilities.isValidValue(someObject: detail[kStudyId] as AnyObject){
                self.studyId = detail[kStudyId] as! String
            }
            if Utilities.isValidValue(someObject: detail[kBookmarked] as AnyObject){
                self.bookmarked = detail[kBookmarked] as! Bool
            }
            if Utilities.isValidValue(someObject: detail[kCompletion] as AnyObject){
                self.completion = detail[kCompletion] as! Int
            }
            if Utilities.isValidValue(someObject: detail[kAdherence] as AnyObject){
                self.adherence = detail[kAdherence] as! Int
            }
            if Utilities.isValidValue(someObject: detail[kStudyParticipantId] as AnyObject){
                self.participantId = detail[kStudyParticipantId] as? String
            }
            if Utilities.isValidValue(someObject: detail[kStudyEnrolledDate] as AnyObject){
                self.joiningDate = Utilities.getDateFromString(dateString: detail[kStudyEnrolledDate] as! String)
            }
            if Utilities.isValidValue(someObject: detail[kStatus] as AnyObject){
                
                let statusValue = detail[kStatus] as! String
                
                if (StudyStatus.inProgress.paramValue == statusValue) {
                    self.status = .inProgress
                }
                else if (StudyStatus.notEligible.paramValue == statusValue) {
                    self.status = .notEligible
                }
                else if (StudyStatus.completed.paramValue == statusValue) {
                    self.status = .completed
                }
                else if (StudyStatus.withdrawn.paramValue == statusValue) {
                    self.status = .withdrawn
                }
            }
            
            
        }
        else{
            Logger.sharedInstance.debug("UserStudyStatus Dictionary is null:\(detail)")
        }
        
        
        
    }
    
    func getBookmarkUserStudyStatus() -> Dictionary<String,Any>{
        
        let studyDetail = [kStudyId:self.studyId,
                           kBookmarked:self.bookmarked] as [String : Any]
        return studyDetail
    }
    func getParticipatedUserStudyStatus() -> Dictionary<String,Any>{
        
        
        var id = ""
        if self.participantId != nil {
            id = self.participantId!
        }
        
        let studyDetail = [kStudyId:self.studyId,
                           kStudyStatus:self.status.paramValue,
                           kStudyParticipantId:id] as [String : Any]
        return studyDetail
    }
    func getCompletionAdherence() -> Dictionary<String,Any>{
        let studyDetail = [kStudyId:self.studyId,
                           "completion":completion,
                           "adherence":adherence] as [String : Any]
        return studyDetail
    }
    
}

class TermsAndPolicy {
    var termsURL:String?
    var policyURL:String?
    static var currentTermsAndPolicy: TermsAndPolicy?
    init() {
        self.termsURL = ""
        self.policyURL = ""
    }
     func initWithDict(dict:Dictionary<String,Any>) {
        if Utilities.isValidObject(someObject: dict as AnyObject) {
            
            if Utilities.isValidValue(someObject: dict[kTerms] as AnyObject?)  {
                
                self.termsURL = (dict[kTerms] as! String?)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            }
            else{
                 self.termsURL = ""
            }
            
            if Utilities.isValidValue(someObject: dict[kPolicy] as AnyObject?) {
                 self.policyURL = (dict[kPolicy] as! String?)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            }
            else{
                self.policyURL = ""
            }
        }
    }
    
    
}

//MARK: ActivityStatus
class UserActivityStatus{
    
    enum ActivityStatus:Int {
        case yetToJoin
        case inProgress
        case completed
        case abandoned
        
        var description:String {
            switch self {
            case .yetToJoin:
                return "  Start  "
            case .inProgress:
                return "  Resume  "
            case.completed:
                return "  Completed  "
            case .abandoned:
                return "  Incomplete  "
                
            }
        }
        
        var paramValue:String {
            switch self {
            case .yetToJoin:
                return "yetToJoin"
            case .inProgress:
                return "inProgress"
            case.completed:
                return "completed"
            case .abandoned:
                return "abandoned"
            
                
            }
        }
    }
    
    var bookmarked:Bool = false
    var activityId:String! = ""
    var studyId:String! = ""
    var activityVersion:String! = ""
    var activityRunId:String! = ""
    var totalRuns = 0
    var compeltedRuns = 0
    var incompletedRuns = 0
    var status:ActivityStatus = .yetToJoin
    init() {
        
    }
    init(detail:Dictionary<String, Any>){
        
        if Utilities.isValidObject(someObject: detail as AnyObject?){
            
            if  Utilities.isValidValue(someObject: detail[kStudyId] as AnyObject){
                self.studyId = detail[kStudyId] as! String
            }
            if  Utilities.isValidValue(someObject: detail[kActivityId] as AnyObject){
                self.activityId = detail[kActivityId] as! String
            }
            if  Utilities.isValidValue(someObject: detail[kActivityVersion] as AnyObject){
                self.activityVersion = detail[kActivityVersion] as! String
            }
            if Utilities.isValidValue(someObject: detail[kBookmarked] as AnyObject){
                self.bookmarked = detail[kBookmarked] as! Bool
            }
            if Utilities.isValidValue(someObject: detail[kActivityRunId] as AnyObject){
                self.activityRunId = detail[kActivityRunId] as! String
            }
            
            
            if Utilities.isValidValue(someObject: detail[kActivityStatus] as AnyObject){
                
                let statusValue = detail[kActivityStatus] as! String
                
                if (ActivityStatus.inProgress.paramValue == statusValue) {
                    self.status = .inProgress
                }
                else if (ActivityStatus.yetToJoin.paramValue == statusValue) {
                    self.status = .yetToJoin
                }
                else if (ActivityStatus.completed.paramValue == statusValue) {
                    self.status = .completed
                }
                else if (ActivityStatus.abandoned.paramValue == statusValue) {
                    self.status = .abandoned
                }
            }
            
            
        }
        else{
            Logger.sharedInstance.debug("UserStudyStatus Dictionary is null:\(detail)")
        }
       
        
    }
    
    func getBookmarkUserActivityStatus() -> Dictionary<String,Any>{
        
        let studyDetail = [kStudyId:self.studyId,
                           kActivityId:self.activityId,
                           kBookmarked:self.bookmarked] as [String : Any]
        return studyDetail
    }
    func getParticipatedUserActivityStatus() -> Dictionary<String,Any>{
        
        let runDetail = [	"total":self.totalRuns,
                         	"completed":self.compeltedRuns,
                         	"missed":self.incompletedRuns]
        
        let studyDetail = [
                           kActivityId:self.activityId,
                           kActivityRunId:self.activityRunId,
                           kActivityStatus:self.status.paramValue,
                           "activityRun":runDetail] as [String : Any]
       
        return studyDetail
    }
    
}
