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

enum AppConfiguration {
    
    private enum JSONKey {
        static let isShowMenuResourceButton = "shouldShowMenuResourceButton"
        static let shouldShowConsentButtonOnStudyHome = "shouldShowConsentButtonOnStudyHome"
        static let showConsentInStudyResources = "showConsentInStudyResources"
        static let appleID = "appleId"
        static let studyCompletionMessage = "studyCompletionMessage"
    }
    
    private static var appConfig: JSONDictionary {
        var nsDictionary: NSDictionary?
      
        var plistPath = Bundle.main.path(forResource: "AppConfiguration", ofType: ".plist", inDirectory: nil)
        let localeDefault = Locale.preferredLanguages.first ?? "en"
        if !(localeDefault.hasPrefix("es") || localeDefault.hasPrefix("en")) {
          plistPath = Bundle.main.path(forResource: "AppConfiguration", ofType: ".plist", inDirectory: nil, forLocalization: "Base")
        }
        if let path = plistPath {
           nsDictionary = NSDictionary(contentsOfFile: path)
        }
        return nsDictionary as? JSONDictionary ?? [:]
    }
    
    static var isShowMenuResourceButton: Bool {
        return appConfig[JSONKey.isShowMenuResourceButton] as? Bool ?? true
    }
    
    static var shouldShowConsentButtonOnStudyHome:Bool {
        return appConfig[JSONKey.shouldShowConsentButtonOnStudyHome] as? Bool ?? true
    }
    static var showConsentInStudyResources:Bool {
        return appConfig[JSONKey.showConsentInStudyResources] as? Bool ?? true
    }
    
    static var appleID: String? {
        return appConfig[JSONKey.appleID] as? String ?? ""
    }
    
    static var studyCompletionMessage: String? {
        return appConfig[JSONKey.studyCompletionMessage] as? String
    }
}
