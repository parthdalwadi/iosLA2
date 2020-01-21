//
//  ViewController.swift
//  Parth_C0766346_LA2
//
//  Created by Parth Dalwadi on 2020-01-19.
//  Copyright © 2020 Parth Dalwadi. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

     let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var titleL: UITextField!
    @IBOutlet weak var detailL: UITextView!
    @IBOutlet weak var daysNeededL: UITextField!
   
    @IBOutlet weak var added: UILabel!
    @IBOutlet weak var timeStampL: UILabel!
    @IBOutlet weak var created_on_L: UILabel!
    
    //var d_tvc: TaskListTVC?
    var isNewTask = false
    var taskName: String?
    var currTask: NSManagedObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // set context for accessing task entity
        if !isNewTask {
            timeStampL.isHidden = false
            created_on_L.isHidden = false
            displayTaskDetails(taskTitle: taskName!)}
        else{
            timeStampL.isHidden = true
            created_on_L.isHidden = true
            titleL.isEnabled = true
        }
       
        var tapG = UITapGestureRecognizer(target: self, action: #selector(removeKeypad))
        view.addGestureRecognizer(tapG)
        
    }
    
    

    @objc func removeKeypad(){
        
        titleL.resignFirstResponder()
        detailL.resignFirstResponder()
        daysNeededL.resignFirstResponder()
        
    }

    
    
    func saveTask() {
        
        if isNewTask {
            currTask = NSEntityDescription.insertNewObject(forEntityName: "Task", into: context)
            
        }
        
        
                currTask!.setValue(titleL.text, forKey: "title")
                currTask!.setValue(detailL.text, forKey: "details")
                currTask!.setValue(isNewTask ? NSDate() : (currTask?.value(forKey: "createdOn")) , forKey: "createdOn")
                currTask!.setValue(Int(daysNeededL.text!) ?? 0, forKey: "daysNeeded")
                currTask!.setValue(0, forKey: "daysAdded")

        
                  // save context
                  do {
                      try context.save()
                    
                  } catch {
                      print(error)
                  }
        
    }
    
    
    
    func displayTaskDetails(taskTitle: String){
        
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "title=%@", taskTitle)
        
        do {
            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
            
            currTask = results[0]
            
            titleL.text = taskTitle
            titleL.isEnabled = false
            detailL.text = currTask!.value(forKey: "details") as! String
            daysNeededL.text = "\(currTask!.value(forKey: "daysNeeded")!)"
            timeStampL.text = "\((currTask!.value(forKey: "createdOn") as! NSDate).description.dropLast(5))"
            
            added.text = "Added Days: \((currTask!.value(forKey: "daysAdded")!))"
            
            }catch {
            print("error occured in fetching")
            }
        
        
    }
    
    
}

