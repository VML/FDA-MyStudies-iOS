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
import UIKit
import MessageUI
import WebKit

class WebViewController : UIViewController{
    
    @IBOutlet weak var webView : WKWebView!
    @IBOutlet var barItemShare : UIBarButtonItem?
    
    var activityIndicator:UIActivityIndicatorView!
    var requestLink:String?
    
    var pdfData:Data?
    
    var isEmailAvailable:Bool? = false
    
    var htmlString: String?
    var isLAR: Bool = false
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Used to add a loader
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY-100)
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()

        if self.isEmailAvailable == false {
            
        barItemShare?.isEnabled = false
        self.navigationItem.rightBarButtonItem = nil
            
            barItemShare = nil
        }
        
        if isLAR {
            let path =  AKUtility.baseFilePath + "/study"
            let fileNameLAR: String = "Consent" +  "_" + "\((Study.currentStudy?.studyId)!)" + "LAR" + ".pdf"
            let pdfFilePath = path + "/" + fileNameLAR
            let urlRequest = URLRequest.init(url: URL(fileURLWithPath: pdfFilePath) )
            self.webView.load(urlRequest)

        } else if let requestLink =  requestLink,
            !requestLink.isEmpty,
            let url = URL(string: requestLink) {
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        } else if let html = self.htmlString {
            webView.loadHTMLString(html, baseURL: nil)
        } else if let pdfData = pdfData {
            self.webView.load(pdfData, mimeType: "application/pdf",
                              characterEncodingName: "UTF-8",
                              baseURL: URL(fileURLWithPath: ""))
        } else {
            // VisitWebsite
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }

        webView.navigationDelegate = self
        webView.contentScaleFactor = 1.0
        
        //UIApplication.shared.statusBarStyle = .default
        setNeedsStatusBarAppearanceUpdate()
    }
    
    @IBAction func cancelButtonClicked(_ sender : Any){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonActionShare(_ sender : UIBarButtonItem){
        self.sendConsentByMail()
    }
    
   
    func sendConsentByMail() {
        let mailComposerVC = MFMailComposeViewController()
        
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setSubject("Consent")
       
        if self.pdfData != nil{
           
            let consentName:String! = (Study.currentStudy?.name!)! + "_SignedConsent"
            
            mailComposerVC.addAttachmentData(self.pdfData!, mimeType: "application/pdf", fileName:consentName)
            
            mailComposerVC.setMessageBody("", isHTML: false)
        }
        else if self.htmlString != nil {
            mailComposerVC.setMessageBody(self.htmlString!, isHTML: true)
        }
        
        if MFMailComposeViewController.canSendMail()
        {
            self.present(mailComposerVC, animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController(title:NSLocalizedString(kTitleError, comment: ""),message:kFailedToConnectAppleMail, preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction.init(title:NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                
//                self.dismiss(animated: true, completion: nil)
                
            }))
            UIApplication.topMostViewController?.present(alert, animated: true, completion: nil)

        }
        
        
    }
    
}

extension WebViewController: MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
    }
}





