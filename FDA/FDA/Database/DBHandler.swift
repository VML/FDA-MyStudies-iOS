//
//  DBHandler.swift
//  FDA
//
//  Created by Surender Rathore on 3/22/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import RealmSwift

class DBHandler: NSObject {

    /* Used to save user details like userid, authkey, first name , last name etc*/
    func saveCurrentUser(user:User){
        
        let dbUser = DBUser()
        dbUser.userType = (user.userType?.rawValue)!
        dbUser.emailId = user.emailId!
        dbUser.authToken = user.authToken
        dbUser.userId = user.userId
        //dbUser.firstName = user.firstName
        //dbUser.lastName = user.lastName
        dbUser.verified = user.verified
        
        
        
        let realm = try! Realm()
        print("DBPath : varealm.configuration.fileURL)")
        try! realm.write({
            realm.add(dbUser, update: true)
            
        })
    }
    
    /* Used to initialize the current logged in user*/
    func initilizeCurrentUser(){
        
        let realm = try! Realm()
        let dbUsers = realm.objects(DBUser.self)
        let dbUser = dbUsers.last
        
        if dbUser != nil {
            let currentUser = User.currentUser
            currentUser.firstName = dbUser?.firstName
            currentUser.lastName  = dbUser?.lastName
            currentUser.verified = dbUser?.verified
            currentUser.authToken = dbUser?.authToken
            currentUser.userId = dbUser?.userId
            currentUser.emailId = dbUser?.emailId
            currentUser.userType =  (dbUser?.userType).map { UserType(rawValue: $0) }!
            
            let settings = Settings()
            settings.localNotifications = dbUser?.localNotificationEnabled
            settings.passcode = dbUser?.passcodeEnabled
            settings.remoteNotifications = dbUser?.remoteNotificationEnabled
            
            currentUser.settings = settings
        }
        
    }
    
    class func saveUserSettingsToDatabase(){
        
        let realm = try! Realm()
        let dbUsers = realm.objects(DBUser.self)
        let dbUser = dbUsers.last
        
        try! realm.write({
            
             let user = User.currentUser
            dbUser?.passcodeEnabled = (user.settings?.passcode)!
            dbUser?.localNotificationEnabled = (user.settings?.localNotifications)!
            dbUser?.remoteNotificationEnabled = (user.settings?.remoteNotifications)!
            
        })
    }
    
    
    /* Used to delete current logged in user*/
    class func deleteCurrentUser(){
        
        let realm = try! Realm()
        let dbUsers = realm.objects(DBUser.self)
        let dbUser = dbUsers.last
        try! realm.write {
            realm.delete(dbUser!)
        }
    }
    
    
    
     //MARK:Study
    /* Save studies 
     @params: studies - Array
     */
    func saveStudies(studies:Array<Study>){
        
        let realm = try! Realm()
        let dbStudiesArray = realm.objects(DBStudy.self)
      
        var dbStudies:Array<DBStudy> = []
        for study in studies {
            
            
            //some studies are already present in db
            var dbStudy:DBStudy?
            if dbStudiesArray.count > 0 {
                 dbStudy = dbStudiesArray.filter({$0.studyId ==  study.studyId}).last
            }
            
            if dbStudy == nil {
                dbStudy = DBHandler.getDBStudy(study: study)
                dbStudies.append(dbStudy!)
            }
            else {
                
                try! realm.write({
                    dbStudy?.category = study.category
                    dbStudy?.name = study.name
                    dbStudy?.sponserName = study.sponserName
                    dbStudy?.tagLine = study.description
                    dbStudy?.logoURL = study.logoURL
                    dbStudy?.startDate = study.startDate
                    dbStudy?.endEnd = study.endEnd
                    dbStudy?.status = study.status.rawValue
                    dbStudy?.enrolling = study.studySettings.enrollingAllowed
                    dbStudy?.rejoin = study.studySettings.rejoinStudyAfterWithdrawn
                    dbStudy?.platform = study.studySettings.platform
                    dbStudy?.participatedStatus = study.userParticipateState.status.rawValue
                    dbStudy?.participatedId = study.userParticipateState.participantId
                    dbStudy?.joiningDate = study.userParticipateState.joiningDate
                    dbStudy?.completion = study.userParticipateState.completion
                    dbStudy?.adherence = study.userParticipateState.adherence
                    
                    if dbStudy?.participatedStatus == UserStudyStatus.StudyStatus.inProgress.rawValue {
                        dbStudy?.updatedVersion = study.version
                    }
                    else {
                       // dbStudy?.version = study.version
                        dbStudy?.updatedVersion = study.version
                    }
                    
                })
                
            }
           
        }
        
        
        print("DBPath : \(realm.configuration.fileURL)")
        try! realm.write({
            realm.add(dbStudies, update: true)
            
        })
    }
    
    
    
    
    
    
    
    
    
    private class func getDBStudy(study:Study) ->DBStudy{
        
        let dbStudy = DBStudy()
        dbStudy.studyId = study.studyId
        dbStudy.category = study.category
        dbStudy.name = study.name
        dbStudy.sponserName = study.sponserName
        dbStudy.tagLine = study.description
        dbStudy.version = study.version
        dbStudy.updatedVersion = study.version
        dbStudy.logoURL = study.logoURL
        dbStudy.startDate = study.startDate
        dbStudy.endEnd = study.endEnd
        dbStudy.enrolling = study.studySettings.enrollingAllowed
        dbStudy.rejoin = study.studySettings.rejoinStudyAfterWithdrawn
        dbStudy.platform = study.studySettings.platform
        dbStudy.status = study.status.rawValue
        dbStudy.participatedStatus = study.userParticipateState.status.rawValue
        dbStudy.participatedId = study.userParticipateState.participantId
        dbStudy.joiningDate = study.userParticipateState.joiningDate
        dbStudy.completion = study.userParticipateState.completion
        dbStudy.adherence = study.userParticipateState.adherence
        dbStudy.withdrawalConfigrationMessage = study.withdrawalConfigration?.message
        dbStudy.withdrawalConfigrationType = study.withdrawalConfigration?.type?.rawValue
        
        return dbStudy
        
    }
    
    class func loadStudyListFromDatabase(completionHandler:@escaping (Array<Study>) -> ()){
        
        
        let realm = try! Realm()
        let dbStudies = realm.objects(DBStudy.self)
        
        User.currentUser.participatedStudies.removeAll()
        var studies:Array<Study> = []
        for dbStudy in dbStudies {
            
            let study = Study()
            
            study.studyId = dbStudy.studyId
            study.category = dbStudy.category
            study.name = dbStudy.name
            study.sponserName = dbStudy.sponserName
            study.description = dbStudy.tagLine
            study.version = dbStudy.version
            study.newVersion = dbStudy.updatedVersion
            study.logoURL = dbStudy.logoURL
            study.startDate = dbStudy.startDate
            study.endEnd = dbStudy.endEnd
            study.status = StudyStatus(rawValue:dbStudy.status!)!
            study.signedConsentVersion = dbStudy.signedConsentVersion
            study.signedConsentFilePath = dbStudy.signedConsentFilePath
            study.activitiesLocalNotificationUpdated = dbStudy.activitiesLocalNotificationUpdated
            
            //settings
            let studySettings = StudySettings()
            studySettings.enrollingAllowed = dbStudy.enrolling
            studySettings.rejoinStudyAfterWithdrawn = dbStudy.rejoin
            studySettings.platform = dbStudy.platform!
            
            study.studySettings = studySettings
            
            //status
            let participatedStatus = UserStudyStatus()
            participatedStatus.status = UserStudyStatus.StudyStatus(rawValue:dbStudy.participatedStatus)!
            participatedStatus.bookmarked = dbStudy.bookmarked
            participatedStatus.studyId = dbStudy.studyId
            participatedStatus.participantId = dbStudy.participatedId
            participatedStatus.adherence = dbStudy.adherence
            participatedStatus.completion = dbStudy.completion
            participatedStatus.joiningDate = dbStudy.joiningDate
            
            study.userParticipateState = participatedStatus
            
            print("status \(dbStudy.participatedStatus)");
            
            //append to user class participatesStudies also
            User.currentUser.participatedStudies.append(participatedStatus)
            
            //anchorDate
            let anchorDate = StudyAnchorDate()
            anchorDate.anchorDateActivityId = dbStudy.anchorDateActivityId
            anchorDate.anchorDateQuestionKey = dbStudy.anchorDateType
            anchorDate.anchorDateActivityVersion = dbStudy.anchorDateActivityVersion
            anchorDate.anchorDateQuestionKey = dbStudy.anchorDateQuestionKey
            anchorDate.anchorDateType = dbStudy.anchorDateType
            anchorDate.date = dbStudy.anchorDate
            
            study.anchorDate = anchorDate
            
            let withdrawalInfo = StudyWithdrawalConfigration()
            withdrawalInfo.message = dbStudy.withdrawalConfigrationMessage
            
            
            if dbStudy.withdrawalConfigrationType != nil {
                 withdrawalInfo.type = StudyWithdrawalConfigrationType(rawValue: dbStudy.withdrawalConfigrationType!)
            }
            else{
                 withdrawalInfo.type = .notAvailable
            }
            study.withdrawalConfigration = withdrawalInfo
            
           
            
            studies.append(study)
        }
        
        completionHandler(studies)
        
    }
    
    
    
    
    
    
    
    
    
    
    /* Save study overview
     @params: overview , String
     */
    class func saveStudyOverview(overview:Overview , studyId:String){
        
        let realm = try! Realm()
        let studies =  realm.objects(DBStudy.self).filter("studyId == %@",studyId)
        let dbStudy = studies.last
        
        
        
        //save overview
        let dbStudies = List<DBOverviewSection>()
        for sectionIndex in 0...(overview.sections.count-1) {
            
            let section = overview.sections[sectionIndex]
            let dbOverviewSection = DBOverviewSection()
            
            dbOverviewSection.title = section.title
            dbOverviewSection.link  = section.link
            dbOverviewSection.imageURL = section.imageURL
            dbOverviewSection.text = section.text
            dbOverviewSection.type = section.type
            dbOverviewSection.studyId = studyId
            dbOverviewSection.sectionId = studyId + "screen\(sectionIndex)"
            dbStudies.append(dbOverviewSection)
        }
        
       
        
        debugPrint("DBPath : \(realm.configuration.fileURL)")
        try! realm.write({
            
            realm.add(dbStudies,update: true)
           // dbStudy?.sections.append(objectsIn: dbStudies)
            dbStudy?.websiteLink = overview.websiteLink
            
            
        })
        
    }
    
    
  
    
    class func saveWithdrawalConfigration(withdrawalConfigration:StudyWithdrawalConfigration, studyId:String){
        
        let realm = try! Realm()
        let studies =  realm.objects(DBStudy.self).filter("studyId == %@",studyId)
        let dbStudy = studies.last
        
        try! realm.write({

            dbStudy?.withdrawalConfigrationMessage = withdrawalConfigration.message
            dbStudy?.withdrawalConfigrationType = withdrawalConfigration.type?.rawValue
            
        })
        
    }

    
    
    
    
    class func saveAnchorDateDetail(anchorDate:StudyAnchorDate , studyId:String){
        
        let realm = try! Realm()
        let studies =  realm.objects(DBStudy.self).filter("studyId == %@",studyId)
        let dbStudy = studies.last
        
        try! realm.write({
            
            dbStudy?.anchorDateActivityId = anchorDate.anchorDateActivityId
            dbStudy?.anchorDateType = anchorDate.anchorDateType
            dbStudy?.anchorDateActivityVersion = anchorDate.anchorDateActivityVersion
            dbStudy?.anchorDateQuestionKey = anchorDate.anchorDateQuestionKey
            
        })
        
    }
    
    class func saveAncorDate(date:Date,studyId:String){
        
        let realm = try! Realm()
        let studies =  realm.objects(DBStudy.self).filter("studyId == %@",studyId)
        let dbStudy = studies.last
        
        try! realm.write({
            
            dbStudy?.anchorDate = date
           
            
        })

    }
    
    class func loadStudyOverview(studyId:String,completionHandler:@escaping (Overview?) -> ()){
        
        let realm = try! Realm()
        let studies =  realm.objects(DBOverviewSection.self).filter("studyId == %@",studyId)
        let study =  realm.objects(DBStudy.self).filter("studyId == %@",studyId).last
        //let dbStudy = studies.last
       
        
        if studies.count > 0 {
            
            // inilize OverviewSection from database
            var overviewSections:Array<OverviewSection> = []
            for dbSection in studies {
                let section = OverviewSection()
                
                section.title = dbSection.title
                section.imageURL = dbSection.imageURL
                section.link = dbSection.link
                section.type = dbSection.type
                section.text = dbSection.text
                
                overviewSections.append(section)
            }
            
            //Create Overview object  
            let overview = Overview()
            overview.type = .study
            overview.websiteLink = study?.websiteLink
            overview.sections = overviewSections
            
            completionHandler(overview)
        }
        else {
            completionHandler(nil)
        }
     
        
    }
    
    class func updateMetaDataToUpdateForStudy(study:Study , updateDetails:StudyUpdates?){
        
        let realm = try! Realm()
        let studies =  realm.objects(DBStudy.self).filter("studyId == %@",study.studyId)
        let dbStudy = studies.last
        
        try! realm.write({
            
            dbStudy?.updateResources = StudyUpdates.studyResourcesUpdated
            dbStudy?.updateConsent = StudyUpdates.studyConsentUpdated
            dbStudy?.updateActivities = StudyUpdates.studyActivitiesUpdated
            dbStudy?.updateInfo = StudyUpdates.studyInfoUpdated
            if StudyUpdates.studyVersion != nil {
                dbStudy?.version = StudyUpdates.studyVersion
            }
            else {
                dbStudy?.version = dbStudy?.updatedVersion
            }
            
           // dbStudy?.updatedVersion = StudyUpdates.studyVersion
            
        })
        
    }
    
    class func updateStudyParticipationStatus(study:Study){
        
        let realm = try! Realm()
        let studies =  realm.objects(DBStudy.self).filter("studyId == %@",study.studyId)
        let dbStudy = studies.last
        
        try! realm.write({
            
             dbStudy?.participatedStatus = study.userParticipateState.status.rawValue
             dbStudy?.participatedId = study.userParticipateState.participantId
             dbStudy?.joiningDate = study.userParticipateState.joiningDate
             dbStudy?.completion = study.userParticipateState.completion
             dbStudy?.adherence = study.userParticipateState.adherence
            
            
        })
        
       

    }
    
    class func loadStudyDetailsToUpdate(studyId:String,completionHandler:@escaping (Bool) -> ()){
        let realm = try! Realm()
        let studies =  realm.objects(DBStudy.self).filter("studyId == %@",studyId)
        let dbStudy = studies.last
        
        StudyUpdates.studyActivitiesUpdated = (dbStudy?.updateActivities)!
        StudyUpdates.studyConsentUpdated = (dbStudy?.updateConsent)!
        StudyUpdates.studyResourcesUpdated = (dbStudy?.updateResources)!
        StudyUpdates.studyInfoUpdated = (dbStudy?.updateInfo)!
        
        completionHandler(true)
    }
    
    
    class func saveConsentInformation(study:Study){
        
        let realm = try! Realm()
        let studies =  realm.objects(DBStudy.self).filter("studyId == %@",study.studyId)
        let dbStudy = studies.last
        
        try! realm.write({
            
            dbStudy?.signedConsentFilePath = study.signedConsentFilePath
            dbStudy?.signedConsentVersion = study.signedConsentVersion
            
        })
    }
    
    class func updateLocalNotificaitonUpdated(studyId:String){
        
        let realm = try! Realm()
        let study = realm.object(ofType: DBStudy.self, forPrimaryKey: studyId)
        try! realm.write({
            study?.activitiesLocalNotificationUpdated = true
        })
        
    }
    
     //MARK:Activity
    class func saveActivities(activityies:Array<Activity>){
        
        let realm = try! Realm()
        let study = Study.currentStudy
        let dbActivityArray = realm.objects(DBActivity.self).filter({$0.studyId == study?.studyId})// "studyId == %@",study?.studyId)
        
        
        var dbActivities:Array<DBActivity> = []
        for activity in activityies {
          
            var dbActivity:DBActivity?
            if dbActivityArray.count != 0 {
                dbActivity = dbActivityArray.filter({$0.actvityId == activity.actvityId!}).last
                
                if dbActivity == nil {
                    
                    dbActivity = DBHandler.getDBActivity(activity: activity)
                    dbActivities.append(dbActivity!)
                }
                else {
                    
                    //check if version is updated
                    if dbActivity?.version != activity.version {
                        
                        try! realm.write({
                            realm.delete((dbActivity?.activityRuns)!)
                            realm.delete(dbActivity!)
                        })
                        
                        let updatedActivity = DBHandler.getDBActivity(activity: activity)
                        dbActivities.append(updatedActivity)
                        DBHandler.deleteMetaDataForActivity(activity: activity)
                        
                    }
                    else {
                         try! realm.write({
                            
                            dbActivity?.currentRunId = activity.userParticipationStatus.activityRunId
                            dbActivity?.participationStatus = activity.userParticipationStatus.status.rawValue
                            dbActivity?.completedRuns = activity.userParticipationStatus.compeltedRuns
                            
                            
                            

                            
                         })
                    }
                    
//                    try! realm.write({
//                        
//                        
//                            dbActivity?.type = activity.type?.rawValue
//                            dbActivity?.name = activity.name
//                            dbActivity?.startDate = activity.startDate
//                            dbActivity?.endDate = activity.endDate
//                            dbActivity?.updatedVersion = activity.version
//                            dbActivity?.branching = activity.branching!
//                            dbActivity?.frequencyType = activity.frequencyType.rawValue
//                            dbActivity?.currentRunId = activity.userParticipationStatus.activityRunId
//                            dbActivity?.participationStatus = activity.userParticipationStatus.status.rawValue
//                            
//                            do {
//                                let json = ["data":activity.frequencyRuns]
//                                let data =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
//                                dbActivity?.frequencyRunsData = data
//                            }
//                            catch{
//                                
//                            }
//                        
//                        
//                        
//                    })

                }
            }
            else {
                
                dbActivity = DBHandler.getDBActivity(activity: activity)
                dbActivities.append(dbActivity!)
            }
            
        }
        
        
        print("DBPath : \(realm.configuration.fileURL)")
        if dbActivities.count > 0 {
            try! realm.write({
                realm.add(dbActivities, update: true)
                
                
            })
        }
       
    }
    
    private class func getDBActivity(activity:Activity)->DBActivity{
        
        let dbActivity = DBActivity()
        
        dbActivity.studyId = activity.studyId
        dbActivity.actvityId = activity.actvityId
        dbActivity.type = activity.type?.rawValue
        dbActivity.name = activity.name
        dbActivity.startDate = activity.startDate
        dbActivity.endDate = activity.endDate
        dbActivity.version = activity.version
        //dbActivity.updatedVersion = activity.version
        dbActivity.branching = activity.branching!
        dbActivity.frequencyType = activity.frequencyType.rawValue
        dbActivity.currentRunId = activity.userParticipationStatus.activityRunId
        dbActivity.participationStatus = activity.userParticipationStatus.status.rawValue
        dbActivity.completedRuns = activity.userParticipationStatus.compeltedRuns
        dbActivity.id = activity.studyId! + activity.actvityId!
        do {
            let json = ["data":activity.frequencyRuns]
            let data =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
            dbActivity.frequencyRunsData = data
        }
        catch{
            
        }
        
        
        //save overview
        let dbActivityRuns = List<DBActivityRun>()
        for activityRun in activity.activityRuns {
            
            //let activityRun = activity.activityRuns[sectionIndex]
            let dbActivityRun = DBActivityRun()
            dbActivityRun.startDate = activityRun.startDate
            dbActivityRun.endDate = activityRun.endDate
            dbActivityRun.activityId = activity.actvityId
            dbActivityRun.studyId = activity.studyId
            dbActivityRun.runId = activityRun.runId
            dbActivityRun.isCompleted = activityRun.isCompleted
            
            dbActivityRuns.append(dbActivityRun)
        }
        
        dbActivity.activityRuns.append(objectsIn: dbActivityRuns)
      
        return dbActivity
    }
    
    
    class func updateActivityRestortionDataFor(activity:Activity,studyId:String,restortionData:Data?){
        
        let realm = try! Realm()
        let dbActivities = realm.objects(DBActivityRun.self).filter({$0.activityId == activity.actvityId && $0.studyId == studyId && $0.runId == activity.currentRun.runId}) //.filter("studyId == %@ && actvityId == %@ && runId == %@",studyId,activity.actvityId,activity.currrentRun.runId)
        let dbActivity = dbActivities.last
        
        print("DBPath : \(realm.configuration.fileURL)")
        try! realm.write({
            dbActivity?.restortionData = restortionData
            //realm.add(dbActivity!, update: true)
        })
        
        
    }
    
    class func updateActivityMetaData(activity:Activity){
        
        let realm = try! Realm()
        let dbActivities = realm.objects(DBActivity.self).filter({$0.actvityId == activity.actvityId && $0.studyId == activity.studyId})
        let dbActivity = dbActivities.last
        
        try! realm.write({
            dbActivity?.shortName = activity.shortName
            
        })
        
    }
    
    
    class func loadActivityListFromDatabase(studyId:String,completionHandler:@escaping (Array<Activity>) -> ()){
        
        
        let realm = try! Realm()
        let dbActivities = realm.objects(DBActivity.self).filter("studyId == %@",studyId)
        var date = Date().utcDate()
        
        let difference = UserDefaults.standard.value(forKey: "offset") as? Int
        if difference != nil {
            date = date.addingTimeInterval(TimeInterval(difference!))
        }
        
        var activities:Array<Activity> = []
        for dbActivity in dbActivities {
            
            let activity = Activity()
            activity.actvityId  = dbActivity.actvityId
            activity.studyId    = dbActivity.studyId
            activity.name       = dbActivity.name
            activity.startDate  = dbActivity.startDate
            activity.endDate    = dbActivity.endDate
            activity.type       = ActivityType(rawValue:dbActivity.type!)
            activity.frequencyType = Frequency(rawValue:dbActivity.frequencyType!)!
            activity.totalRuns = dbActivity.activityRuns.count
            activity.version = dbActivity.version
            activity.branching = dbActivity.branching
            
            do {
                let frequencyRuns = try JSONSerialization.jsonObject(with: dbActivity.frequencyRunsData!, options: []) as! [String:Any]
                activity.frequencyRuns = frequencyRuns["data"] as! Array<Dictionary<String, Any>>?
            }
            catch{
                
            }
            
            
            print("Database \(activity.totalRuns)")
            
            if activity.totalRuns != 0 {
                
                
                
                var runs:Array<ActivityRun> = []
                for dbRun in dbActivity.activityRuns {
                    let run = ActivityRun()
                    run .activityId = dbRun.activityId
                    run.complitionDate = dbRun.complitionDate
                    run.startDate = dbRun.startDate
                    run.endDate = dbRun.endDate
                    run.runId = dbRun.runId
                    run.studyId = dbRun.studyId
                    run.isCompleted = dbRun.isCompleted
                    run.restortionData = dbRun.restortionData
                    runs.append(run)
                }
                activity.activityRuns = runs
                
                
                var runsBeforeToday:Array<ActivityRun>! = []
                var run:ActivityRun!
                if activity.frequencyType == Frequency.One_Time && activity.endDate == nil {
                    //runsBeforeToday = runs
                    run = runs.last
                }
                else {
                    
                    runsBeforeToday = runs.filter({$0.endDate <= date})
                    
                    run = runs.filter({$0.startDate <= date && $0.endDate > date}).first //current run
                    
                }
                
                //var runsBeforeToday = runs.filter({$0.endDate <= date})
                
                //let run = runs.filter({$0.startDate <= date && $0.endDate > date}).first //current run
                
                let completedRuns = runs.filter({$0.isCompleted == true})
                //let incompleteRuns = runsBeforeToday.count - completedRuns.count
                
                
                activity.compeltedRuns = completedRuns.count
                //activity.incompletedRuns = (incompleteRuns < 0) ? 0 :incompleteRuns
                activity.currentRunId =  (run != nil) ? (run?.runId)! : runsBeforeToday.count
                activity.currentRun = run
                
                
                //check for completed runs
                //if activity.compeltedRuns == 0 &&  dbActivity.completedRuns != 0 {
                    activity.compeltedRuns = dbActivity.completedRuns
                    
                
                    
                //}
                
                let userStatus = UserActivityStatus()
                userStatus.activityId = dbActivity.actvityId
                userStatus.activityRunId = String(activity.currentRunId)
                userStatus.studyId = dbActivity.studyId
                
                if String(activity.currentRunId) == dbActivity.currentRunId {
                    userStatus.status = UserActivityStatus.ActivityStatus(rawValue:dbActivity.participationStatus)!
                }
                
                userStatus.compeltedRuns = activity.compeltedRuns
                userStatus.incompletedRuns = activity.incompletedRuns
                userStatus.totalRuns = activity.totalRuns
                
                let incompleteRuns = activity.currentRunId - activity.compeltedRuns
                activity.incompletedRuns = (incompleteRuns < 0) ? 0 :incompleteRuns
                if activity.currentRun == nil {
                    userStatus.status = UserActivityStatus.ActivityStatus.abandoned
                  
                }
                else {
                    
                    if userStatus.status != UserActivityStatus.ActivityStatus.completed {

                        var incompleteRuns = activity.currentRunId - activity.compeltedRuns
                        incompleteRuns -= 1
                        activity.incompletedRuns = (incompleteRuns < 0) ? 0 :incompleteRuns
                    }
                   
                }
                activity.userParticipationStatus = userStatus
                
                
                
                //append to user class participatesStudies also
                let activityStatus = User.currentUser.participatedActivites.filter({$0.activityId == activity.actvityId && $0.studyId == activity.studyId}).first
                let index = User.currentUser.participatedActivites.index(where:{$0.activityId == activity.actvityId && $0.studyId == activity.studyId })
                if activityStatus != nil {
                    User.currentUser.participatedActivites[index!] = userStatus
                }
                else {
                    User.currentUser.participatedActivites.append(userStatus)
                }
                
                
            }
            
            

            
            
            
            activities.append(activity)
            
        }
        
        completionHandler(activities)
        
    }
    
    class func loadAllStudyRuns(studyId:String,completionHandler:@escaping (_ completion:Int,_ adherence:Int) -> ()){
        
        let date = Date()
        let realm = try! Realm()
        let studyRuns = realm.objects(DBActivityRun.self).filter("studyId == %@",studyId)
        let completedRuns = studyRuns.filter({$0.isCompleted == true})
        let runsBeforeToday = studyRuns.filter({($0.endDate == nil) || ($0.endDate <= date)})
        var incompleteRuns = runsBeforeToday.count - completedRuns.count
        
        if incompleteRuns < 0 {
            incompleteRuns = 0
        }
        
        let completion = ceil( Double(self.divide(lhs: (completedRuns.count + incompleteRuns)*100, rhs: studyRuns.count)) )
        let adherence = ceil (Double(self.divide(lhs: (completedRuns.count)*100, rhs: (completedRuns.count + incompleteRuns))))
        //let completion = ceil( Double((completedRuns.count + incompleteRuns)*100/studyRuns.count) )
        //let adherence = ceil (Double((completedRuns.count)*100/(completedRuns.count + incompleteRuns)))
        
        completionHandler(Int(completion),Int(adherence))
        
        
        print("complete: \(completedRuns.count) , incomplete: \(incompleteRuns)")
        
    }
    static func divide(lhs: Int, rhs: Int) -> Int {
        if rhs == 0 {
            return 0
        }
        return lhs/rhs
    }
    
    class func saveActivityRuns(activityId:String,studyId:String,runs:Array<ActivityRun>){
        
        let realm = try! Realm()
        let dbActivities = realm.objects(DBActivity.self).filter("studyId == %@ && actvityId == %@",studyId,activityId)
        let dbActivity = dbActivities.last
        
        //save overview
        let dbActivityRuns = List<DBActivityRun>()
        for sectionIndex in 0...(runs.count-1) {
            
            let activityRun = runs[sectionIndex]
            let dbActivityRun = DBActivityRun()
            dbActivityRun.startDate = activityRun.startDate
            dbActivityRun.endDate = activityRun.endDate
            dbActivityRun.activityId = activityId
            dbActivityRun.studyId = studyId
            dbActivityRun.runId = activityRun.runId
            dbActivityRun.isCompleted = activityRun.isCompleted
            
            dbActivityRuns.append(dbActivityRun)
        }
        debugPrint("DBPath : \(realm.configuration.fileURL)")
        try! realm.write({
            
            //realm.add(dbActivityRuns)
            dbActivity?.activityRuns.append(objectsIn: dbActivityRuns)
            //dbStudy?.websiteLink = overview.websiteLink
            
            
        })
        
    }
    
    class func updateRunToComplete(runId:Int,activityId:String,studyId:String){
        
        let realm = try! Realm()
        let dbRuns = realm.objects(DBActivityRun.self).filter("studyId == %@ && activityId == %@ && runId == %d",studyId,activityId,runId)
        let dbRun = dbRuns.last
        
        try! realm.write({
            
           dbRun?.isCompleted = true
           //realm.add(dbRun!, update: true)
            
        })
        
    }
    
    class func updateActivityParticipationStatus(activity:Activity){
        
        let realm = try! Realm()
        let studies =  realm.objects(DBActivity.self).filter({$0.actvityId == activity.actvityId && $0.studyId == activity.studyId})
        let dbActivity = studies.last
        
        try! realm.write({
            
            dbActivity?.currentRunId = activity.userParticipationStatus.activityRunId
            dbActivity?.participationStatus = activity.userParticipationStatus.status.rawValue
            dbActivity?.completedRuns = activity.compeltedRuns
            
//            dbStudy?.participatedStatus = study.userParticipateState.status.rawValue
//            dbStudy?.participatedId = study.userParticipateState.participantId
//            dbStudy?.joiningDate = study.userParticipateState.joiningDate
            
            
        })
        
        
        
    }
    
    class func saveResponseDataFor(activity:Activity,toBeSynced:Bool,data:Dictionary<String,Any>){
        
        let realm = try! Realm()
        let currentRun = activity.currentRun
        let dbRuns = realm.objects(DBActivityRun.self).filter({$0.studyId == currentRun?.studyId && $0.activityId == activity.actvityId && $0.runId == currentRun?.runId}) //filter("studyId == %@ && activityId == %@ && runId == %d",studyId,activityId,runId)
        let dbRun = dbRuns.last
        
        
        
        try! realm.write({
            
            dbRun?.toBeSynced = true
            do {
                let json = ["data":data]
                let jsonData =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
                dbRun?.responseData = jsonData
            }
            catch{
                
            }
            
        })
    }
    
    class func isDataAvailableToSync(completionHandler:@escaping (Bool) -> ()){
        
        let realm = try! Realm()
        let dbRuns = realm.objects(DBActivityRun.self).filter({$0.toBeSynced == true})
        if dbRuns.count > 0{
            completionHandler(true)
        }
        else {
            completionHandler(false)
        }
    }
    
    //MARK:-  Activity MetaData
    class func saveActivityMetaData(activity:Activity, data:Dictionary<String,Any>){
        
        let realm = try! Realm()
        let metaData = DBActivityMetaData()
        metaData.actvityId = activity.actvityId;
        metaData.studyId = activity.studyId;
        
        do {
            let json = data
            let data =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
            metaData.metaData = data
        }
        catch{
            
        }
        
        try! realm.write({
            
            realm.add(metaData)
            
            
        })
        
    }
    
    class func loadActivityMetaData(activity:Activity,completionHandler:@escaping (Bool) -> ()){
        
        let realm = try! Realm()
        let dbMetaDataList = realm.objects(DBActivityMetaData.self).filter({$0.actvityId == activity.actvityId && $0.studyId == activity.studyId})
        
        if dbMetaDataList.count != 0 {
            let metaData = dbMetaDataList.last
            
            do {
                let response = try JSONSerialization.jsonObject(with: (metaData?.metaData)!, options: []) as! [String:Any]
                
                Study.currentActivity?.setActivityMetaData(activityDict:response[kActivity] as! Dictionary<String, Any>)
                
                if Utilities.isValidObject(someObject: Study.currentActivity?.steps as AnyObject?){
                    
                    ActivityBuilder.currentActivityBuilder = ActivityBuilder()
                    ActivityBuilder.currentActivityBuilder.initWithActivity(activity:Study.currentActivity! )
                }
                
                completionHandler(true)
                
            }
            catch{
                completionHandler(false)
            }
        }
        else {
             completionHandler(false)
        }
        
        

        
        
    }
    class func deleteMetaDataForActivity(activity:Activity){
        
        let realm = try! Realm()
        let dbMetaDataList = realm.objects(DBActivityMetaData.self).filter({$0.actvityId == activity.actvityId && $0.studyId == activity.studyId})
        
        if dbMetaDataList.count != 0 {
            let metaData = dbMetaDataList.last
            try! realm.write({
                realm.delete(metaData!)
                
            })

            
        }
    }

    //MARK:- Dashboard - Statistics
    class func saveDashBoardStatistics(studyId:String,statistics:Array<DashboardStatistics>){
        
        let realm = try! Realm()
        let dbStatisticsArray = realm.objects(DBStatistics.self).filter({$0.studyId == studyId})// "studyId == %@",study?.studyId)
        
        
        var dbStatisticsList:Array<DBStatistics> = []
        for stats in statistics {
            
            var dbStatistics:DBStatistics?
            if dbStatisticsArray.count != 0 {
                dbStatistics = dbStatisticsArray.filter({$0.activityId == stats.activityId!}).last!
                
                if dbStatistics == nil {
                    
                    dbStatistics = DBHandler.getDBStatistics(stats: stats)
                    dbStatisticsList.append(dbStatistics!)
                }
                else {
                    
                    try! realm.write({
                        
                        dbStatistics?.activityId = stats.activityId
                        dbStatistics?.activityVersion = stats.activityVersion
                        dbStatistics?.calculation = stats.calculation
                        dbStatistics?.dataSourceKey = stats.dataSourceKey
                        dbStatistics?.dataSourceType = stats.dataSourceType
                        dbStatistics?.displayName = stats.displayName
                        dbStatistics?.title = stats.title
                        dbStatistics?.statType = stats.statType
                        dbStatistics?.studyId = stats.studyId
                        dbStatistics?.unit = stats.unit
                        
                    })
                    
                }
            }
            else {
                
                dbStatistics = DBHandler.getDBStatistics(stats: stats)
                dbStatisticsList.append(dbStatistics!)
            }
            
        }
        
        
        print("DBPath : \(realm.configuration.fileURL)")
        if dbStatisticsList.count > 0 {
            try! realm.write({
                realm.add(dbStatisticsList, update: true)
                
            })
        }
    }
    
    private class func getDBStatistics(stats:DashboardStatistics)->DBStatistics{
        
        let dbStatistics = DBStatistics()
        dbStatistics.activityId = stats.activityId
        dbStatistics.activityVersion = stats.activityVersion
        dbStatistics.calculation = stats.calculation
        dbStatistics.dataSourceKey = stats.dataSourceKey
        dbStatistics.dataSourceType = stats.dataSourceType
        dbStatistics.displayName = stats.displayName
        dbStatistics.title = stats.title
        dbStatistics.statType = stats.statType
        dbStatistics.studyId = stats.studyId
        dbStatistics.unit = stats.unit
        dbStatistics.statisticsId = stats.studyId! + stats.title!
        
        return dbStatistics
        
    }
    
    class func loadStatisticsForStudy(studyId:String,completionHandler:@escaping (Array<DashboardStatistics>) -> ()){
        
        
        let realm = try! Realm()
        let dbStatisticsList = realm.objects(DBStatistics.self).filter("studyId == %@",studyId)
        
        var statsList:Array<DashboardStatistics> = []
        for dbStatistics in dbStatisticsList {
            
            let stats = DashboardStatistics()
            stats.activityId =  dbStatistics.activityId
            stats.activityVersion  = dbStatistics.activityVersion
            stats.calculation = dbStatistics.calculation
            stats.dataSourceKey = dbStatistics.dataSourceKey
            stats.dataSourceType = dbStatistics.dataSourceType
            stats.displayName = dbStatistics.displayName
            stats.title = dbStatistics.title
            stats.statType = dbStatistics.statType
            stats.studyId = dbStatistics.studyId
            stats.unit = dbStatistics.unit
            stats.statList = dbStatistics.statisticsData
            
            statsList.append(stats)
        }
        completionHandler(statsList)
        
    }
    
    //MARK:- Dashboard - Charts
    class func saveDashBoardCharts(studyId:String,charts:Array<DashboardCharts>){
        
        let realm = try! Realm()
        let dbChartsArray = realm.objects(DBCharts.self).filter({$0.studyId == studyId})// "studyId == %@",study?.studyId)
        
        
        var dbChartsList:Array<DBCharts> = []
        for chart in charts {
            
            var dbChart:DBCharts?
            if dbChartsArray.count != 0 {
                dbChart = dbChartsArray.filter({$0.activityId == chart.activityId!}).last!
                
                if dbChart == nil {
                    
                    dbChart = DBHandler.getDBChart(chart: chart)
                    dbChartsList.append(dbChart!)
                }
                else {
                    
                    try! realm.write({
                        
                        dbChart?.activityId = chart.activityId
                        dbChart?.activityVersion = chart.activityVersion
                        dbChart?.chartType = chart.chartType
                        dbChart?.chartSubType = chart.chartSubType
                        dbChart?.dataSourceTimeRange = chart.dataSourceTimeRange
                        dbChart?.dataSourceKey = chart.dataSourceKey
                        dbChart?.dataSourceType = chart.dataSourceType
                        dbChart?.displayName = chart.displayName
                        dbChart?.title = chart.title
                       
                        dbChart?.studyId = chart.studyId
                       
                        
                    })
                    
                }
            }
            else {
                
                dbChart = DBHandler.getDBChart(chart: chart)
                dbChartsList.append(dbChart!)
            }
            
        }
        
        
        print("DBPath : \(realm.configuration.fileURL)")
        if dbChartsList.count > 0 {
            try! realm.write({
                realm.add(dbChartsList, update: true)
                
            })
        }
    }
    
    private class func getDBChart(chart:DashboardCharts)->DBCharts{
        
        let dbChart = DBCharts()
        dbChart.activityId = chart.activityId
        dbChart.activityVersion = chart.activityVersion
        dbChart.chartType = chart.chartType
        dbChart.chartSubType = chart.chartSubType
        dbChart.dataSourceTimeRange = chart.dataSourceTimeRange
        dbChart.dataSourceKey = chart.dataSourceKey
        dbChart.dataSourceType = chart.dataSourceType
        dbChart.displayName = chart.displayName
        dbChart.title = chart.title
        
        dbChart.studyId = chart.studyId
        
        dbChart.chartId = chart.studyId! + chart.title!
        
        return dbChart
        
    }
    
    class func loadChartsForStudy(studyId:String,completionHandler:@escaping (Array<DashboardCharts>) -> ()){
        
        let realm = try! Realm()
        let dbChartList = realm.objects(DBCharts.self).filter("studyId == %@",studyId)
        
        var chartList:Array<DashboardCharts> = []
        for dbChart in dbChartList {
            
            let chart = DashboardCharts()
            chart.activityId =  dbChart.activityId
            chart.activityVersion  = dbChart.activityVersion
            chart.chartType = dbChart.chartType
            chart.chartSubType = dbChart.chartSubType
            chart.dataSourceTimeRange = dbChart.dataSourceTimeRange
            chart.dataSourceKey = dbChart.dataSourceKey
            chart.dataSourceType = dbChart.dataSourceType
            chart.displayName = dbChart.displayName
            chart.title = dbChart.title
          
            chart.studyId = dbChart.studyId
           
            chart.statList = dbChart.statisticsData
            
            chartList.append(chart)
        }
        completionHandler(chartList)
    }
    
    
    class func saveStatisticsDataFor(activityId:String,key:String,data:Float){
        
        let realm = try! Realm()
        let dbStatisticsList = realm.objects(DBStatistics.self).filter("activityId == %@ && dataSourceKey == %@",activityId,key)
        
        let dbChartsList = realm.objects(DBCharts.self).filter("activityId == %@ && dataSourceKey == %@",activityId,key)
        
        let dbStatistics = dbStatisticsList.last
        let dbChart = dbChartsList.last
        
        //save data
        let statData = DBStatisticsData()
        statData.startDate = Date()
        statData.data = data
        
        try! realm.write({
            if dbStatistics != nil {
                dbStatistics?.statisticsData.append(statData)
            }
            if dbChart != nil {
                dbChart?.statisticsData.append(statData)
            }
            
        })
        
     }
    
    
    //MARK:- RESOURCES
    class func saveResourcesForStudy(studyId:String,resources:Array<Resource>){
        
        let realm = try! Realm()
        let dbResourcesArray = realm.objects(DBResources.self).filter({$0.studyId == studyId})
        
        var dbResourcesList:Array<DBResources> = []
        for resource in resources {
            
            var dbResource:DBResources?
            if dbResourcesArray.count != 0 {
                dbResource = dbResourcesArray.filter({$0.resourceId == resource.resourcesId}).last
                
                if dbResource == nil {
                    
                    dbResource = DBHandler.getDBResource(resource: resource)
                    dbResource?.studyId = studyId
                    dbResourcesList.append(dbResource!)
                }
                else {
                    
                    try! realm.write({
                      
                        dbResource?.title = resource.title
                       
                        dbResource?.audience = resource.audience?.rawValue
                        dbResource?.endDate = resource.endDate
                        dbResource?.startDate = resource.startDate
                        dbResource?.key = resource.key
                        dbResource?.povAvailable = resource.povAvailable
                        dbResource?.serverUrl = resource.file?.link
                        dbResource?.level = resource.level?.rawValue
                        dbResource?.notificationMessage = resource.notificationMessage
                        
                        if resource.povAvailable {
                            dbResource?.anchorDateEndDays = resource.anchorDateEndDays!
                            dbResource?.anchorDateStartDays = resource.anchorDateStartDays!
                        }
                        
                    })
                    
                }
            }
            else {
                
                dbResource = DBHandler.getDBResource(resource: resource)
                dbResource?.studyId = studyId
                
                dbResourcesList.append(dbResource!)
            }
            
        }
        
        
        print("DBPath : \(realm.configuration.fileURL)")
        if dbResourcesList.count > 0 {
            try! realm.write({
                realm.add(dbResourcesList, update: true)
                
            })
        }
    }
    
    private class func getDBResource(resource:Resource)->DBResources{
        
        let dbResource = DBResources()
        dbResource.resourceId = resource.resourcesId
        dbResource.title = resource.title
        dbResource.audience = resource.audience?.rawValue
        dbResource.endDate = resource.endDate
        dbResource.startDate = resource.startDate
        dbResource.key = resource.key
        dbResource.povAvailable = resource.povAvailable
        dbResource.serverUrl = resource.file?.link
        dbResource.level = resource.level?.rawValue
        dbResource.type = resource.type
        dbResource.notificationMessage = resource.notificationMessage
        
        if resource.povAvailable {
            dbResource.anchorDateEndDays = resource.anchorDateEndDays!
            dbResource.anchorDateStartDays = resource.anchorDateStartDays!
        }
        
        return dbResource
        
    }
    
    class func loadResourcesForStudy(studyId:String,completionHandler:@escaping (Array<Resource>) -> ()){
        
        
        let realm = try! Realm()
        let dbResourceList = realm.objects(DBResources.self).filter("studyId == %@",studyId)
        
        var resourceList:Array<Resource> = []
        for dbResource in dbResourceList {
            
            let resource = Resource()
            resource.resourcesId = dbResource.resourceId
            resource.title = dbResource.title
            resource.anchorDateEndDays = dbResource.anchorDateEndDays
            resource.anchorDateStartDays = dbResource.anchorDateStartDays
            resource.audience = Audience(rawValue:dbResource.audience!)
            resource.endDate  = dbResource.endDate
            resource.startDate = dbResource.startDate
            resource.key = dbResource.key
            resource.povAvailable = dbResource.povAvailable
            resource.notificationMessage = dbResource.notificationMessage
            resource.level = ResourceLevel(rawValue:dbResource.level!)
            
            let file = File()
            file.link = dbResource.serverUrl
            file.localPath = dbResource.localPath
            file.mimeType = MimeType(rawValue:dbResource.type!)
            file.name = dbResource.title
            
            resource.file = file
                
            resourceList.append(resource)
        }
        completionHandler(resourceList)
        
    }
    
    class func getResourcesWithAnchorDateAvailable(studyId:String,completionHandler:@escaping (Array<DBResources>) -> ()){
        
        let realm = try! Realm()
        let dbResourceList:Array<DBResources> = realm.objects(DBResources.self).filter({$0.studyId == studyId && $0.povAvailable == true})
        
        completionHandler(dbResourceList)
    }
    
    class func updateResourceLocalPath(resourceId:String,path:String){
        let realm = try! Realm()
        let dbResource = realm.objects(DBResources.self).filter("resourcesId == %@",resourceId).last!
        try! realm.write({
            dbResource.localPath = path
            
        })
    }
    
     //MARK:- NOTIFICATION
    func saveNotifications(notifications:Array<AppNotification>){
        
        let realm = try! Realm()
        
        var dbNotificationList:Array<DBNotification> = []
        for notification in notifications {
            
            let dbNotification = DBNotification()
            dbNotification.id = notification.id!
            dbNotification.title = notification.title!
            dbNotification.message = notification.message!
            
            
            if notification.studyId != nil {
                dbNotification.studyId = notification.studyId!
            }
            else{
                dbNotification.studyId = ""
            }
            
            
            if notification.activityId != nil {
                dbNotification.activityId = notification.activityId!
            }
            else{
                dbNotification.activityId = ""
            }
            
            dbNotification.isRead = notification.read!
            
            dbNotification.notificationType = notification.type.rawValue
            dbNotification.subType = notification.subType.rawValue
            dbNotification.audience = notification.audience!.rawValue
            dbNotification.date = notification.date!
            
            dbNotificationList.append(dbNotification)
            
        }
        
        
        print("DBPath : \(realm.configuration.fileURL)")
        try! realm.write({
            realm.add(dbNotificationList, update: true)
            
        })
        
        
    }
    
    class func loadNotificationListFromDatabase(completionHandler:@escaping (Array<AppNotification>) -> ()){
        
        
        let realm = try! Realm()
        let dbNotifications = realm.objects(DBNotification.self).sorted(byKeyPath: "date", ascending: false)
        
        var notificationList:Array<AppNotification> = []
        for dbnotification in dbNotifications {
            
            let notification = AppNotification()
            
            notification.id = dbnotification.id
            notification.title = dbnotification.title
            notification.message = dbnotification.message
            notification.studyId = dbnotification.studyId
            notification.activityId = dbnotification.activityId
            notification.type =    AppNotification.NotificationType(rawValue:dbnotification.notificationType!)!
            
            notification.subType = AppNotification.NotificationSubType(rawValue:dbnotification.subType!)!
            
            notification.audience = Audience(rawValue:dbnotification.audience!)!
            notification.date =  dbnotification.date
            
            notification.read = dbnotification.isRead
            
            notificationList.append(notification)
            
            
        }
        completionHandler(notificationList)
        
    }
    
    class func saveLocalNotification(notification:AppLocalNotification){
        
        
        let realm = try! Realm()
        
        
        let dbNotification = DBLocalNotification()
        dbNotification.id = notification.id
        dbNotification.title = notification.title
        dbNotification.message = notification.message
        
        
        if notification.studyId != nil {
            dbNotification.studyId = notification.studyId
        }
        else{
            dbNotification.studyId = ""
        }
        
        
        if notification.activityId != nil {
            dbNotification.activityId = notification.activityId
        }
        else{
            dbNotification.activityId = ""
        }
        
        dbNotification.isRead = notification.read!
        
        dbNotification.notificationType = notification.type.rawValue
        dbNotification.subType = notification.subType.rawValue
        dbNotification.audience = notification.audience!.rawValue
        dbNotification.startDate = notification.startDate
        dbNotification.endDate = notification.endDate
        
        
        
        print("DBPath : \(realm.configuration.fileURL)")
        try! realm.write({
            realm.add(dbNotification, update: true)
            
        })
    }
    
    class func getLocalNotification(completionHandler:@escaping (Array<AppLocalNotification>) -> ()){
        
        let realm = try! Realm()
        let todayDate = Date()
        let dbNotifications = realm.objects(DBLocalNotification.self).filter({$0.startDate! <= todayDate && $0.endDate! >= todayDate})
        
        var notificationList:Array<AppLocalNotification> = []
        for dbnotification in dbNotifications {
            
            let notification = AppLocalNotification()
            
            notification.id = dbnotification.id
            notification.title = dbnotification.title
            notification.message = dbnotification.message
            notification.studyId = dbnotification.studyId
            notification.activityId = dbnotification.activityId
            notification.type =    AppNotification.NotificationType(rawValue:dbnotification.notificationType!)!
            
            notification.subType = AppNotification.NotificationSubType(rawValue:dbnotification.subType!)!
            
            notification.audience = Audience(rawValue:dbnotification.audience!)!
            //notification.date =  dbnotification.date
            
            notification.read = dbnotification.isRead
            notification.startDate = dbnotification.startDate
            notification.endDate = dbnotification.endDate
            
            notificationList.append(notification)
            
            
        }
        completionHandler(notificationList)
    }
    
    class func isNotificationSetFor(notification:String,completionHandler:@escaping (Bool) -> ()){
        let realm = try! Realm()
       
        let dbNotifications = realm.object(ofType: DBLocalNotification.self, forPrimaryKey: notification)
        
        if dbNotifications == nil{
            completionHandler(false)
        }
        completionHandler(true)
        
    }

    //MARK:- DELETE
    class func deleteAll(){
        
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
}
