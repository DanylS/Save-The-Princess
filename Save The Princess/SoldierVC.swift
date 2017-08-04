//
//  ViewController.swift
//  Save The Princess
//
//  Created by Danyl SEMMACHE on 6/27/17.
//  Copyright © 2017 Danyl SEMMACHE. All rights reserved.
//

import UIKit
import RealmSwift

//////////////////////////
/////// EXTENSION ////////
//////////////////////////

extension UIColor {
    
    func rgb() -> Int? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)
            
            //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
            let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
            return rgb
        } else {
            // Could not extract RGBA components:
            
            return nil
        }
    }
}

class SoldierVC: UIViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate {
    
    //IBOutlet init
    
    @IBOutlet weak var fldName: UITextField!
    @IBOutlet weak var sgGender: UISegmentedControl!
    @IBOutlet weak var fldAge: UITextField!
    @IBOutlet var btnPickColor: UIButton!
    @IBOutlet weak var lblResult: UILabel!
    @IBOutlet weak var btnEnd: UIButton!
    // @IBOutlet weak var lblColor: UILabel!
    
    //Var init
    var nameValue:String = ""
    var genderValue:String = ""
    var ageValue:String = ""
    var colorValue:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.fldName.delegate = self
        //disable autocorrect with keyboard
        self.fldName.autocorrectionType = .no
        //set return key for number pad keyboard
        self.addDoneButtonOnKeyboard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //////////////////////////
    /////// NAME FIELD ///////
    //////////////////////////
    
    //set return key to disable the keyboard when user pick a name
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func nameAction(_ sender: Any) {
        self.nameValue = self.fldName.text!
    }
    
    
    //////////////////////////
    /////// AGE FIELD ////////
    //////////////////////////
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(ViewController.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.fldAge.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        self.fldAge.resignFirstResponder()
    }
    
    
    @IBAction func ageAction(_ sender: Any) {
        print(self.fldAge.text!)
        self.ageValue = self.fldAge.text!
    }
    
    //////////////////////////
    //// SEGMENTED CONTROL ///
    //////////////////////////
    
    //Get the selected value
    @IBAction func sgAction(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            self.genderValue = "Male"
        case 1:
            self.genderValue = "Female"
        case 2:
            self.genderValue = "Other"
        default:
            break;
        }
        
    }
    
    //////////////////////////
    // COLOR PICKER SECTION //
    //////////////////////////
    
    // Generate popover on button press
    @IBAction func colorPickerButton(_ sender: UIButton) {
        
        let popoverVC = storyboard?.instantiateViewController(withIdentifier: "colorPickerPopover") as! ColorPickerViewController
        popoverVC.modalPresentationStyle = .popover
        popoverVC.preferredContentSize = CGSize(width: 284, height: 446)
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = CGRect(x: 0, y: 0, width: 85, height: 30)
            popoverController.permittedArrowDirections = .any
            popoverController.delegate = self
            popoverVC.delegate = self
        }
        present(popoverVC, animated: true, completion: nil)
    }
    
    // Override the iPhone behavior that presents a popover as fullscreen
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .none
    }
    
    func setButtonColor (_ color: UIColor) {
        if let rgb = color.rgb() {
            print(rgb)
            btnPickColor.setTitleColor(color, for:UIControlState())
            //btnPickColor.titleLabel?.text = rgb.description
            self.colorValue = rgb.description
            
            //  self.lblColor.text = "RBG: \(rgb.description)"
            print(colorValue)
        } else {
            print("conversion failed")
        }
    }
    
    //////////////////////////
    ///// CREATION ENDED /////
    //////////////////////////
    
    @IBAction func btnFinish(_ sender: Any) {
        if (!nameValue.isEmpty &&
            !ageValue.isEmpty &&
            !colorValue.isEmpty) {
            
            btnEnd.isHidden = true
            //let nameSoldier = Soldier()
            
            let mySoldier = Soldier()
            mySoldier.name = nameValue
            mySoldier.gender = genderValue
            mySoldier.age = Int(ageValue)!
            mySoldier.color = colorValue
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(mySoldier)
            }
            
            //Soldier.name.append(nameValue)
            lblResult.text = "Success"
            lblResult.textColor = UIColor.green
        }
        else {
            lblResult.text = "Error"
        }
    }
}
