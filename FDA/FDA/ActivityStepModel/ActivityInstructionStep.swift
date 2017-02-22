//
//  ActivityInstructionStep.swift
//  FDA
//
//  Created by Arun Kumar on 2/13/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import ResearchKit
class ActivityInstructionStep: ActivityStep {
    
    
    var image:UIImage?
    var imageLocalPath:String?
    var imageServerURL:String?
    
    
    override init() {
        super.init()
        self.imageLocalPath = ""
        self.imageServerURL = ""
        self.image = UIImage()
        
    }
    
    override func initWithDict(stepDict: Dictionary<String, Any>) {
        
        
        if Utilities.isValidObject(someObject: stepDict as AnyObject?){
            
            super.initWithDict(stepDict: stepDict)
            
            // load image from server
            // save it locally and set the local path
            
            
        }
        else{
            Logger.sharedInstance.debug("Instruction Step Dictionary is null:\(stepDict)")
        }
        
    }
    
    func getInstructionStep() -> ORKInstructionStep? {
        /* method creates ORKInstructionStep based on ActivityStep data
         returns ORKInstructionStep
         */
        if   Utilities.isValidValue(someObject:title  as AnyObject?) && Utilities.isValidValue(someObject:text  as AnyObject?) && Utilities.isValidValue(someObject:key  as AnyObject?)   {
            
            let instructionStep = ORKInstructionStep(identifier: key!)
            
            instructionStep.title = NSLocalizedString(title!, comment: "")
            
            instructionStep.text = text!
            
            //let handSolidImage = UIImage(named: "hand_solid")!
            //instructionStep.image = handSolidImage.withRenderingMode(.alwaysTemplate)
            
            return instructionStep
            
        }
        else{
            Logger.sharedInstance.debug("Instruction Step Data is null ")
            
            return nil
        }
        
        
    }
    
    
    
}