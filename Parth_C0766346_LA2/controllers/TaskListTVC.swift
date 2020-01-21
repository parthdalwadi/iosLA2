//
//  TaskListTVC.swift
//  Parth_C0766346_LA2
//
//  Created by Parth Dalwadi on 2020-01-19.
//  Copyright © 2020 Parth Dalwadi. All rights reserved.
//

import UIKit
import CoreData

class TaskListTVC: UITableViewController, UISearchBarDelegate {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var allTasks: [NSManagedObject]?
    var showAlert = false
    var emptyAlert = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAllData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        if !searchText.isEmpty{
            req.predicate = NSPredicate(format: "title contains[c] %@" , searchText)}
        do {
         
            self.allTasks = try self.context.fetch(req) as! [NSManagedObject]
            self.tableView.reloadData()
            
         }catch {
         print("error occured in fetching")
         }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
    

    // MARK: - Table view data source

    @IBAction func unwindToList(_ unwindSegue: UIStoryboardSegue) {
           let s = unwindSegue.source as! ViewController
        
        if(s.titleL.text!.isEmpty || s.detailL.text!.isEmpty || s.daysNeededL.text!.isEmpty){
            
            showAlert = true
            emptyAlert = true
            
        }
        else if (s.isNewTask && isTaskExist(title: s.titleL.text!)){
            
            // alert
            showAlert = true
            emptyAlert = false
           
            
            
        }else{
            s.saveTask()
            showAlert = false
            loadAllData()
            tableView.reloadData()
        }
        
        
           // Use data from the view controller which initiated the unwind segue
       }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        if showAlert{
            
            okAlert(msg: emptyAlert ? "you forgot to add all details!! \n Please add the task again!": "Task with the same name already exists")
            
        }
        
    }
    
    func okAlert(msg: String){
        
        let ac = UIAlertController(title: msg, message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
            self.showAlert = false
        }))
        
        self.present(ac, animated: true, completion: nil)
        
        
        
    }
    
    func isTaskExist(title: String)->Bool{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "title=%@" , title)
        
        var results: [NSManagedObject]
        do {
            results = try context.fetch(fetchRequest) as! [NSManagedObject]
            
          
            }catch {
            print("error occured in fetching")
            return true
            }
        
        return (!results.isEmpty)
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allTasks?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell"){
            
            cell.textLabel?.text = allTasks![indexPath.row].value(forKey: "title") as! String

            let Ndays = allTasks![indexPath.row].value(forKey: "daysNeeded") as! Int
            let Adays = allTasks![indexPath.row].value(forKey: "daysAdded") as! Int
            
            cell.detailTextLabel?.text = (Adays >= Ndays) ? "☑️" :"\(Adays)/\(Ndays)"
            cell.backgroundColor =  (Adays >= Ndays) ? #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1) : #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
            
            return cell }
        
        return UITableViewCell()
    }
    


    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }


    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            
            print("something added")
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }*/
    

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let DeleteAction = UIContextualAction(style: .destructive, title: "Remove Task") { (action, view, success) in
            
            self.context.delete(self.allTasks![indexPath.row])
            self.allTasks?.remove(at: indexPath.row)
            
            do{
                
                try self.context.save()
            }catch{
                print("unable to delete")
            }
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.reloadData()
            
        }
        
        
        let addDay = UIContextualAction(style: .normal , title: "Add a Day") { (action, view, success) in
 
            let days = self.allTasks![indexPath.row].value(forKey: "daysAdded") as! Int
            
            self.allTasks![indexPath.row].setValue(days + 1, forKey: "daysAdded")
            
            do{
                
                try self.context.save()
               
            }catch{
                print("error")
            }
            
            self.tableView.reloadData()
            
        }
        addDay.backgroundColor = #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
        return UISwipeActionsConfiguration(actions: [DeleteAction, addDay])
    }
    
       
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        // re arrange in core data
     
        let fromV = allTasks![fromIndexPath.row]
        let toV = allTasks![to.row]
        
        allTasks![fromIndexPath.row] = toV
        allTasks![to.row] = fromV
        
        tableView.reloadData()
        
        do{
            try context.save()
        
        }catch{
            print("unable to rearrange")
        }
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let taskVC = segue.destination as? ViewController{
            //taskVC.d_tvc = self
            if let btn = sender as? UIBarButtonItem {
                taskVC.isNewTask = true
            }
            
            if let task_Cell = sender as? UITableViewCell {
                taskVC.isNewTask = false
                taskVC.taskName = task_Cell.textLabel?.text
                
            }
            
            
            
        }
    }
    

    
    // function that returns all data
    func loadAllData(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        do {
            allTasks = try context.fetch(fetchRequest) as! [NSManagedObject]
          
            }catch {
            print("error occured in fetching")
            }
    }
    
    
    @IBAction func sort(_ sender: UIBarButtonItem) {
        
        var sortKey = ""
        let ac = UIAlertController(title: "Sort By:", message: "Please select a key", preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Title", style: .default, handler: { (action) in
            sortKey = "title"
            self.performSort(sortKey, sender.title == "up")
            
        }))

        ac.addAction(UIAlertAction(title: "Created On", style: .default, handler: { (action) in
            sortKey = "createdOn"
            self.performSort(sortKey, sender.title == "up")
            
            
        }))

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(ac, animated: true, completion: nil)
        
        
    
    }
    
    
    func performSort(_ sortKey: String, _ isAccending: Bool){
        
        
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        req.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: isAccending)]
        do {
         
            self.allTasks = try self.context.fetch(req) as! [NSManagedObject]
            self.tableView.reloadData()
            
         }catch {
         print("error occured in fetching")
         }
    }

}
