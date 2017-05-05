//
//  StudyDashboard.swift
//  FDA
//
//  Created by Surender Rathore on 5/3/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import RealmSwift


enum StatisticsFormula:String{
   case Summation
   case Average
   case Maximum
   case Minimum 

}

class StudyDashboard: NSObject {
    
    var statistics:Array<DashboardStatistics>! = []
    var charts:Array<DashboardCharts>! = []
    static var instance = StudyDashboard()
}


class DashboardStatistics {
    
    var statisticsId:String?
    var studyId:String?
    var title:String?
    var displayName:String?
    var unit:String?
    var calculation:String?
    var statType:String?
    var activityId:String?
    var activityVersion:String?
    var dataSourceType:String?
    var dataSourceKey:String?
    var statList = List<DBStatisticsData>()
    
    init() {
        
    }
    
    init(detail:Dictionary<String,Any>) {
        
        if Utilities.isValidObject(someObject: detail as AnyObject?){
            
            
            if Utilities.isValidValue(someObject: detail["title"] as AnyObject ){
                self.title = detail["title"] as? String
            }
            else {
                self.title = "123"
            }
            if Utilities.isValidValue(someObject: detail["displayName"] as AnyObject ){
                self.displayName = detail["displayName"] as? String
            }
            if Utilities.isValidValue(someObject: detail["statType"] as AnyObject ){
                self.statType = detail["statType"] as? String
            }
            if Utilities.isValidValue(someObject: detail["unit"] as AnyObject ){
                self.unit = detail["unit"] as? String
            }
            if Utilities.isValidValue(someObject: detail["calculation"] as AnyObject ){
                self.calculation = detail["calculation"] as? String
            }
            
            let datasource = detail["dataSource"] as! Dictionary<String,Any>
            
            if Utilities.isValidValue(someObject: datasource["type"] as AnyObject ){
                self.dataSourceType = datasource["type"] as? String
            }
            if Utilities.isValidValue(someObject: datasource["key"] as AnyObject ){
                self.dataSourceKey = datasource["key"] as? String
            }
            
            let activity = datasource["activity"] as! Dictionary<String,Any>
            if Utilities.isValidValue(someObject: activity[kActivityId] as AnyObject ){
                self.activityId = activity[kActivityId] as? String
            }
            if Utilities.isValidValue(someObject: activity["version"] as AnyObject ){
                self.activityVersion = activity["version"] as? String
            }
            self.studyId = Study.currentStudy?.studyId

            self.statisticsId = self.studyId! + self.title!
        }
    }
    
}

class DashboardCharts {
}