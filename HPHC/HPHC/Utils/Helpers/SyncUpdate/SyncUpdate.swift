/*
 License Agreement for FDA My Studies
 Copyright © 2017-2019 Harvard Pilgrim Health Care Institute (HPHCI) and its Contributors. Permission is
 hereby granted, free of charge, to any person obtaining a copy of this software and associated
 documentation files (the &quot;Software&quot;), to deal in the Software without restriction, including without
 limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
 Software, and to permit persons to whom the Software is furnished to do so, subject to the following
 conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial
 portions of the Software.
 Funding Source: Food and Drug Administration (“Funding Agency”) effective 18 September 2014 as
 Contract no. HHSF22320140030I/HHSF22301006T (the “Prime Contract”).
 THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
 OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation
import RealmSwift

class SyncUpdate {
    
    static var currentSyncUpdate = SyncUpdate()
    private init() {}
    
    @objc func updateData(isReachable: Bool) {
        if isReachable {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.syncDataToServer()
            }
        }
    }
    
    /**
     SyncData to server, called to sync responses stored in offline mode to server
     */
    func syncDataToServer() {
        
        let realm = try! Realm()
        guard let toBeSyncedData = realm.objects(DBDataOfflineSync.self)
            .sorted(byKeyPath: "date", ascending: true).first
            else { return }
        
        // Request params
        var params: JSONDictionary?
        
        if let requestParams = toBeSyncedData.requestParams  {
            params = try? JSONSerialization.jsonObject(with: requestParams, options: []) as? JSONDictionary
        }
        
        // Header params
        var headers: Dictionary<String, String>?
        
        if let requestHeaders = toBeSyncedData.headerParams {
            headers = try? JSONSerialization.jsonObject(with: requestHeaders, options: []) as? [String: String]
        }
        
        let methodString = toBeSyncedData.method
        let server = toBeSyncedData.server
        
        if server == "registration" {
            let methodName = methodString?.components(separatedBy: ".").first ?? ""
            let registrationMethod = RegistrationMethods(rawValue: methodName)
            if let method = registrationMethod?.method {
             UserServices().syncOfflineSavedData(method: method,
                                                 params: params,
                                                 headers: headers,
                                                 delegate: self)
            }
        } else if server == "response" {
            
            let methodName = methodString?.components(separatedBy: ".").first ?? ""
            let registrationMethod = ResponseMethods(rawValue: methodName)
            if let method = registrationMethod?.method {
             LabKeyServices().syncOfflineSavedData(method: method,
                                                   params: params,
                                                   headers: headers,
                                                   delegate: self)
            }
        }
        
        // Delete current database object
        try! realm.write {
            realm.delete(toBeSyncedData)
        }
        
    }
    
}

// MARK:- Webservices Delegates
extension SyncUpdate: NMWebServiceDelegate {
    
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
    }
    
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName) : \(String(describing:response))")
        self.syncDataToServer()
    }
    
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
    }
}
