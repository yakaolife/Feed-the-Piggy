//
//  NewItemViewController.swift
//  FeedThePiggy
//
//  Created by Ya Kao on 10/1/16.
//  Copyright © 2016 Betsy Kao. All rights reserved.
//

import UIKit
import CoreData

class NewItemViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var currentTotalLabel: UILabel!
    @IBOutlet weak var seGoalButton: UIButton!
    @IBOutlet weak var goalView: UIView!
    @IBOutlet weak var goalTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var clearDateButton: UIButton!

    var enddateSelected:NSDate?
    var datePicker: UIDatePicker!
    
    var isEdit : Bool = false
    var setGoalExpanded: Bool = false
    let dateFormatter = DateFormatter()
    
    //Will be empty if Create New/not edit
    var foodItem: FoodItem?
    var managedObjectContext : NSManagedObjectContext!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        //Styling
        seGoalButton.backgroundColor = pinkColor
        seGoalButton.tintColor = UIColor.white

        //Adding Save (and Select) button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(save(_:)))
        
        nameTextField.delegate = self
        
        if !isEdit {
            //New!
            currentTotalLabel.isHidden = true
            goalView.isHidden = true
            clearDateButton.isHidden = true
            
        }else if foodItem != nil {
            //edit mode
            //populate the values
            nameTextField.text = foodItem?.name
            priceTextField.text = String(format:"%.11f", (foodItem?.price)!)
            currentTotalLabel.text = String(format:"%.11f", (foodItem?.currentTotal)!)
            
            dateFormatter.dateStyle = .medium
            
            if (foodItem?.goalSet)!{
                goalTextField.text = String(format:"%.11f", (foodItem?.goal)!)
            }
            
            if (foodItem?.enddateSet)!{
                endDateTextField.text = dateFormatter.string(from: (foodItem?.enddate)! as Date)
                clearDateButton.isHidden = false
                
            }else{
                clearDateButton.isHidden = true
            }
            
            if !(foodItem?.goalSet)! && !(foodItem?.enddateSet)!{
                //We can hide the whole goalView
                goalView.isHidden = true
            }
            
            
        }
        
    }

    
    @IBAction func endDateTextFieldClicked(_ sender: UITextField) {
        //print("endDateTextFieldClicked!")
        datePicker = UIDatePicker()
        datePicker.backgroundColor = UIColor.white
        datePicker.datePickerMode = .date
        sender.inputView = datePicker
        
        //Add toolbar for cancel, and done
        let toolBar = UIToolbar()
        toolBar.isTranslucent = true
        toolBar.tintColor = pinkColor
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(NewItemViewController.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(NewItemViewController.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: true)
        
        toolBar.isUserInteractionEnabled = true
        sender.inputAccessoryView = toolBar
        
    }
    
    func doneClick(){
        //print("done click!")
        enddateSelected = datePicker.date as NSDate?
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .none
        endDateTextField.text = dateformatter.string(from: datePicker.date)
        clearDateButton.isHidden = false
        endDateTextField.resignFirstResponder()
    }
    
    func cancelClick(){
        endDateTextField.resignFirstResponder()
    }
    
    @IBAction func clearDate(_ sender: UIButton) {
        enddateSelected = nil
        endDateTextField.text = ""
        clearDateButton.isHidden = true;
    }
    
    @IBAction func setGoalButtonClicked(_ sender: AnyObject) {
        goalView.isHidden = !goalView.isHidden
        
        if goalView.isHidden {
            seGoalButton.setTitle("Set Goal", for: .normal)
        }else {
            seGoalButton.setTitle("Hide Goal", for: .normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func save(_ sender: AnyObject) {
        
        //TODO: Take care of the case for Edit!!!
        
        let name = nameTextField.text
        let price = Double(priceTextField.text!)
        
        var goal : Double?
        if goalTextField.text != nil {
            goal = Double(goalTextField.text!)
        }else{
            goal = 0.0
        }
        let enddate = enddateSelected
        
        if let nameIsEmpty = name?.isEmpty ,
            nameIsEmpty == false && price != nil{
            
            if isEdit {
                let objectID = foodItem?.objectID
//                let fetchRequest: NSFetchRequest<FoodItem> = FoodItem.fetchRequest()
//                fetchRequest.resultType = .managedObjectResultType
                
                
                do{
                    
                    let result = try managedObjectContext.existingObject(with: objectID!)
                    print("got the one we want!")
                    //Update
                    result.setValue(name, forKey: "name")
                    result.setValue(price!, forKey: "price")
                    let gS = goal != 0 ? true : false
                    result.setValue(gS, forKey: "goalSet")
                    let eS = enddate != nil ? true : false
                    result.setValue(eS, forKey: "enddateSet")
                    result.setValue(goal, forKey: "goal")
                    result.setValue(enddate, forKey: "enddate")
                    
                    do{
                        try managedObjectContext.save()
                        print("Update success!")

                    }catch{
                        let updateError = error as NSError
                        print("\(updateError), \(updateError.userInfo)")
                    }

                }catch{
                    let updateError = error as NSError
                    print("\(updateError), \(updateError.userInfo)")
                }
            
                
            }else{
                //New!
                //Create Entity
                let entity = NSEntityDescription.entity(forEntityName: "FoodItem", in: managedObjectContext)
                let record = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
                
                //Populate
                record.setValue(name, forKey: "name")
                record.setValue(price, forKey: "price")
                record.setValue(NSDate(), forKey: "creationdate")
                
                do{
                    //Save
                    try record.managedObjectContext?.save()
                    print("Saved success!")
                    _ = self.navigationController?.popViewController(animated: true)
                    //dismiss(animated: true, completion: nil)
                }catch{
                    let saveError = error as NSError
                    print("\(saveError), \(saveError.userInfo)")
                    
                    //Show Alert View
                    showAlert(title: "Error", message: "Something is wrong when saving", cancelButtonTitle: "Cancel")
                }

            }
            
        }else{
            print("required field empty")
            showAlert(title: "Error", message: "Required fields are empty", cancelButtonTitle: "Try again")
        }
        
        _ = self.navigationController?.popViewController(animated: true)
        //dismiss(animated: true, completion: nil)
    }
    
    //Dismiss keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //MARK: - Helper Methods
    func showAlert(title: String, message: String, cancelButtonTitle: String){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: cancelButtonTitle, style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    //Parsing the string value out of the textfield
    func priceParsing(input: String) -> String{
        return ""
    }

}
