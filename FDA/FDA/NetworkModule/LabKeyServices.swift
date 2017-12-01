//
//  LabKeyServices.swift
//  FDA
//
//  Created by Surender Rathore on 2/15/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

//api keys
let kEnrollmentToken        = "token"
let kParticipantId          = "participantId"
let kEnrollmentTokenValid   = "valid"
let kDeleteResponses        = "deleteResponses"

class LabKeyServices: NSObject {
    
    let networkManager = NetworkManager.sharedInstance()
    var delegate:NMWebServiceDelegate! = nil
    var activityId:String!  //Temp: replace with request parameters
    var keys:String!  //Temp: replace with request parameters
    var requestParams:Dictionary<String,Any>? = [:]
    var headerParams:Dictionary<String,String>? = [:]
    
    
    //MARK:Requests
    func enrollForStudy(studyId:String, token:String , delegate:NMWebServiceDelegate){
        self.delegate = delegate
        let method = ResponseMethods.enroll.method
        
        let params = [kEnrollmentToken:token,
                      kStudyId:studyId]
        
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func verifyEnrollmentToken(studyId:String,token:String, delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        
        let method = ResponseMethods.validateEnrollmentToken.method
        
        let params = [kEnrollmentToken:token,
                      kStudyId:studyId
        ]
        
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func withdrawFromStudy(studyId:String,participantId:String,deleteResponses:Bool,delegate:NMWebServiceDelegate){
        self.delegate = delegate
        let method = ResponseMethods.withdrawFromStudy.method
        
        let params = [
                      kParticipantId:participantId,
                      kDeleteResponses:deleteResponses
            ] as [String : Any]
        
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func processResponse(metaData:Dictionary<String,Any>,activityType:String,responseData:Dictionary<String,Any>,participantId:String,delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        let method = ResponseMethods.processResponse.method
        
        let params = [kActivityType:activityType ,
                      kActivityInfoMetaData:metaData,
                      kParticipantId: participantId,
                      kActivityResponseData :responseData
            ] as [String : Any]
        
        print("processresponse \(params)")
        self.sendRequestWith(method:method, params: params, headers: nil)
        
    }
    
    func processResponse(responseData:Dictionary<String,Any>, delegate:NMWebServiceDelegate){
        self.delegate = delegate
        
        let method = ResponseMethods.processResponse.method
       /*
        let studyId =  "CAFDA12" // Study.currentStudy?.studyId!
        let activiyId = "QR-4" // Study.currentActivity?.actvityId!
        let activityName =  "QR4" //Study.currentActivity?.shortName!
        let activityVersion = "1.0" //Study.currentActivity?.version!
        let currentRunId = Study.currentActivity?.currentRunId
        
        */
        
        
        let currentUser = User.currentUser
        if let userStudyStatus = currentUser.participatedStudies.filter({$0.studyId == Study.currentStudy?.studyId!}).first {
            
            
            let studyId =  Study.currentStudy?.studyId!
            let activiyId =  Study.currentActivity?.actvityId!
            let activityName =  Study.currentActivity?.shortName!
            let activityVersion = Study.currentActivity?.version!
            let currentRunId = Study.currentActivity?.currentRunId
            
            
            
            let info =  [kStudyId:studyId! ,
                         kActivityId:activiyId! ,
                         kActivityName:activityName! ,
                         "version" :activityVersion! ,
                         kActivityRunId:"\(currentRunId!)"
                ] as [String : String]
            
            let ActivityType = Study.currentActivity?.type?.rawValue
            
            let params = [kActivityType:ActivityType! ,
                          kActivityInfoMetaData:info,
                          kParticipantId: userStudyStatus.participantId! as String,  //"43decbe8662d1f3c198b19d79c6df7d6",
                          kActivityResponseData :responseData
                ] as [String : Any]
            
            print("processresponse \(params)")
            self.sendRequestWith(method:method, params: params, headers: nil)
            
            
        }
        
        
   
        
        
    }
    
    func getParticipantResponse(tableName:String,activityId:String,keys:String,participantId:String,delegate:NMWebServiceDelegate){
        
        
        
        
        
        self.delegate = delegate
        self.activityId = activityId
        self.keys = keys
        let method = ResponseMethods.executeSQL.method
        let query = "SELECT " + keys + ",Created" + " FROM " + tableName
        let params = [
            
                      kParticipantId: participantId,
                      "sql" :query
            ] as [String : Any]
        
       
        self.sendRequestWith(method:method, params: params, headers: nil)
        
    }
    
    func syncOfflineSavedData(method:Method, params:Dictionary<String, Any>?,headers:Dictionary<String, String>? , delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        self.sendRequestWith(method:method, params: params!, headers: headers)
    }
    
    //MARK:Parsers
    func handleEnrollForStudy(response:Dictionary<String, Any>){
        
    }
    
    func handleVerifyEnrollmentToken(response:Dictionary<String, Any>){
        
    }
    
    func handleWithdrawFromStudy(response:Dictionary<String, Any>){
        
    }
    
    func handleProcessResponse(response:Dictionary<String, Any>){
        
    }
    
   
    func handleGetParticipantResponse(response:Dictionary<String, Any>){
        
        
        
        var dashBoardResponse:Array<DashboardResponse> = []
        let keysArray = self.keys.components(separatedBy: ",")
        for  key in keysArray{
            
            let newkey = key.replacingOccurrences(of: "\"", with: "")
            let responseData = DashboardResponse()
            responseData.activityId = activityId
            responseData.key = newkey
            responseData.type = "int"
            responseData.isPHI = "true"
            
            dashBoardResponse.append(responseData)
        }

        
        if let rows = response["rows"] as? Array<Dictionary<String,Any>>{
            print("rows \(rows)")
            
            for rowDetail in rows {
                if let data =  rowDetail["data"] as? Dictionary<String,Any>{
                    //created date
                    let dateDetail = data["Created"]  as? Dictionary<String,Any>
                    let date = dateDetail?["value"] as! String
                    
                    //handle for fetel Kick
//                    if let fkid = data["FetalKickId"] {
//
//                        let responseData = dashBoardResponse.first
//                        //count
//                        let countDetail = data["count"]  as? Dictionary<String,Any>
//                        let count = countDetail?["value"] as! Float
//
//                        //duration
//                        let durationDetail = data["duration"]  as? Dictionary<String,Any>
//                        let duration = durationDetail?["value"] as! Float
//
//                        let valueDetail = ["value":duration,
//                                           "count":count,
//                                           "date":date] as Dictionary<String,Any>
//
//                        responseData?.values.append(valueDetail)
//
//                    }
//                    else {
//                        for responseData in dashBoardResponse {
//
//                            if let keyValue = data[responseData.key!] as? Dictionary<String,Any> {
//
//                                if Utilities.isValidValue(someObject: keyValue["value"] as AnyObject?) {
//                                    let value = keyValue["value"] as! Float
//                                    let valueDetail = ["value":value,
//                                                       "count":Float(0.0),
//                                                       "date":date] as Dictionary<String,Any>
//
//                                    responseData.values.append(valueDetail)
//                                }
//
//
//                            }
//                        }
//                    }
                  
                  //FetalKick
                  if  data["count"] != nil && data["duration"] != nil  {
                    
                    let responseData = dashBoardResponse.first
                    //count
                    let countDetail = data["count"]  as? Dictionary<String,Any>
                    let count = countDetail?["value"] as! Float
                    
                    //duration
                    let durationDetail = data["duration"]  as? Dictionary<String,Any>
                    let duration = durationDetail?["value"] as! Float
                    
                    let valueDetail = ["value":duration,
                                       "count":count,
                                       "date":date] as Dictionary<String,Any>
                    
                    responseData?.values.append(valueDetail)
                    
                  } //Speatial Memory
                  else if data["NumberofFailures"] != nil && data["NumberofGames"] != nil   &&   data["Score"] != nil {
                    
                    let responseData = dashBoardResponse.first
                    //numberOfFailuresDetail
                    let numberOfFailuresDetail = data["NumberofFailures"]  as? Dictionary<String,Any>
                    let numberOfFailures = numberOfFailuresDetail?["value"] as! Float
                    
                    //score
                    let scoreDetail = data["Score"]  as? Dictionary<String,Any>
                    let score = scoreDetail?["value"] as! Float
                    
                    //numberOfGames
                    let numberOfGamesDetail = data["NumberofGames"]  as? Dictionary<String,Any>
                    let numberOfGames = numberOfGamesDetail?["value"] as! Float
                    
                    let valueDetail1 = ["value":numberOfFailures,
                                       "count":numberOfFailures,
                                       "date":date] as Dictionary<String,Any>
                    let valueDetail2 = ["value":score,
                                        "count":score,
                                        "date":date] as Dictionary<String,Any>
                    let valueDetail3 = ["value":numberOfGames,
                                        "count":numberOfGames,
                                        "date":date] as Dictionary<String,Any>
                    
                    responseData?.values.append(valueDetail1)
                    responseData?.values.append(valueDetail2)
                    responseData?.values.append(valueDetail3)
                    
                  }
                  else {
                    for responseData in dashBoardResponse {
                      
                      if let keyValue = data[responseData.key!] as? Dictionary<String,Any> {
                        
                        if Utilities.isValidValue(someObject: keyValue["value"] as AnyObject?) {
                          let value = keyValue["value"] as! Float
                          let valueDetail = ["value":value,
                                             "count":Float(0.0),
                                             "date":date] as Dictionary<String,Any>
                          
                          responseData.values.append(valueDetail)
                        }
                        
                        
                      }
                    }
                  }
                  
                }
            }
            
            
        }
        
        //StudyDashboard.instance.dashboardResponse = dashBoardResponse
        StudyDashboard.instance.saveDashboardResponse(responseList: dashBoardResponse)
        
        //save in database as well
        //TBD
    
    }
    
    
    private func sendRequestWith(method:Method, params:Dictionary<String, Any>,headers:Dictionary<String, String>?){
        
        self.requestParams = params
        self.headerParams = headers
        
        networkManager.composeRequest(ResponseServerConfiguration.configuration,
                                      method: method,
                                      params: params as NSDictionary?,
                                      headers: headers as NSDictionary?,
                                      delegate: self)
    }
}
extension LabKeyServices:NMWebServiceDelegate{
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        if delegate != nil {
            delegate.startedRequest(manager, requestName: requestName)
        }
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        
        switch requestName {
        case ResponseMethods.validateEnrollmentToken.description as String: break
        case ResponseMethods.enroll.description as String:
            self.handleEnrollForStudy(response: response as! Dictionary<String, Any>)
        case ResponseMethods.getParticipantResponse.description as String: break
        case ResponseMethods.executeSQL.description as String:
            self.handleGetParticipantResponse(response: response as! Dictionary<String, Any>)
        case ResponseMethods.processResponse.description as String: break
        case ResponseMethods.withdrawFromStudy.description as String: break
        default:
            print("Request was not sent with proper method name")
        }
        
        if delegate != nil {
            delegate.finishedRequest(manager, requestName: requestName, response: response)
        }
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        if delegate != nil {
            delegate.failedRequest(manager, requestName: requestName, error: error)
        }
        
        if requestName as String == ResponseMethods.processResponse.description {
            
            if (error.code == NoNetworkErrorCode) {
                //save in database
                print("save in database")
                DBHandler.saveRequestInformation(params: self.requestParams, headers: self.headerParams, method: requestName as String, server: "response")
            }
        }
    }
}
