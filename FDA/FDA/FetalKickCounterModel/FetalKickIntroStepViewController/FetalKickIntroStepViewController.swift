//
//  FetalKickIntroStepViewController.swift
//  FDA
//
//  Created by Arun Kumar on 4/11/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import Foundation
import ResearchKit

let kFetalKickIntroStepDefaultIdentifier = "FetalIntroStepIdentifier"

class FetalKickCounterIntroStepType : ORKStep {
    static func stepViewControllerClass() -> FetalKickIntroStepViewController.Type {
        return FetalKickIntroStepViewController.self
    }
}

class FetalKickIntroStep: ORKStep {
    var introTitle:String? // MainTitle for the Task
    var subTitle:String? //Subtitle for Task
    var displayImage:UIImage?
}

class FetalKickIntroStepViewController:  ORKStepViewController {
    

    var titleLabel:UILabel? //Custom Title Label
    @IBOutlet weak var descriptionLabel:UILabel?
    var iconImage:UIImage?
    
    @IBOutlet weak var buttonNext:UIButton?   // button to start task as well as increment the counter
    
    //Mark: ORKStepViewController overriden methods
    
    override init(step: ORKStep?) {
        super.init(step: step)
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let step = step as? FetalKickIntroStep {
        
            self.titleLabel?.text = step.introTitle
            self.descriptionLabel?.text = step.subTitle
            self.iconImage = step.displayImage
            buttonNext?.layer.borderColor =   kUicolorForButtonBackground
        }
    }
    
    override func hasNextStep() -> Bool {
        super.hasNextStep()
        return true
    }
    
    override func goForward(){
        super.goForward()
    }
    
    //Mark:IBActions
    
    @IBAction func nextButtonAction(_ sender:UIButton){
        self.goForward()
    }
    
}



