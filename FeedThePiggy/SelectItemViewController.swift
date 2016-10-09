//
//  SelectItemViewController.swift
//  FeedThePiggy
//
//  Created by Ya Kao on 9/18/16.
//  Copyright © 2016 Betsy Kao. All rights reserved.
//

import UIKit
import CoreData

protocol SelectItemProtocol {
    
    func selected(foodItem: FoodItem);
}


class SelectItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellIdentifier = "ItemCell"
    
    var selectItemDelegate: SelectItemProtocol?
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var fromPiggyView: Bool = false
    
    var selectedFoodItem: FoodItem? = nil
    
    var context: NSManagedObjectContext = {
       let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController<FoodItem> = {
        //Init fetch request
        //let fetchRequest = NSFetchRequest<FoodItem>(entityName: "FoodItem")
        let fetchRequest: NSFetchRequest<FoodItem> = FoodItem.fetchRequest()
        
        //Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "creationdate", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        //init fetched result controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Search set up
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
        
        
        print(context)
        
        if !fromPiggyView{
            self.navigationItem.leftBarButtonItem = nil
        }
        
        //Load data
        do{
            try self.fetchedResultsController.performFetch()
        }catch{
            let fetchError  = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
    }
    
    //MARK: - IBActions
    
    @IBAction func cancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - TableView methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let sections = fetchedResultsController.sections{
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections{
            return sections.count
        }
        
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        print("section: \(indexPath.section), row: \(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ItemCell
        
        //Configure table view cell
        configure(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configure(_ cell: ItemCell, atIndexPath indexPath: IndexPath){
       //Fetch record
        let record = fetchedResultsController.object(at: indexPath)
        
        //Update cell
        if let name = record.value(forKey: "name") as? String{
            cell.itemName.text = name
        }
        
        if let price = record.value(forKey: "price") as? Double{
            //TODO: check if we need formatting...
            cell.price.text = String(format: "%.11f", price)
        }
        
        if let currentTotal = record.value(forKey: "currentTotal") as? Double{
            cell.currentTotal.text = String(format:"%.11f", currentTotal)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //TODO: Update item currentTotal, and then
        let cell = tableView.cellForRow(at: indexPath) as! ItemCell
        
        if !fromPiggyView {
            
            self.selectedFoodItem = self.fetchedResultsController.object(at: indexPath)
            self.performSegue(withIdentifier: "DetailViewSegue", sender: self)
            
        }else{
            //Select to use
            let item = self.fetchedResultsController.object(at: indexPath)
            let price = item.value(forKey: "price") as! Double
            let currentTotal = item.value(forKey: "currentTotal") as! Double
            
            item.setValue(price+currentTotal, forKey: "currentTotal")
            
            do{
                try self.context.save()
                self.selectItemDelegate?.selected(foodItem: item)
                print("\n update currentTotal success")
                
            }catch{
                let updateError = error as NSError
                print("\(updateError), \(updateError.userInfo)")
                
            }
            print("selected \(cell.itemName.text) with price \(cell.price.text)");
            
            dismiss(animated: true, completion: nil)
        }
        

    }
    
    //MARK: - Cell Swipe actions
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //Edit and Delete (TODO: Detail view?)
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            //Edit action
            self.selectedFoodItem = self.fetchedResultsController.object(at: indexPath)
            self.performSegue(withIdentifier: "AddNewItemSegue", sender: self)
            
        }
        
        edit.backgroundColor = UIColor.orange
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
            //Delete
            
            let deleteObject = self.fetchedResultsController.object(at: indexPath)
            //let deleteObject = self.fetchedResultsController.ob
            self.context.delete(deleteObject)
            
            do{
                try self.context.save()
                print("Delete success!")
            }catch{
                let deleteError  = error as NSError
                print("\(deleteError), \(deleteError.userInfo)")
                
            }

        }
        
        delete.backgroundColor = UIColor.red
        
        let info = UITableViewRowAction(style: .normal, title: "Info") { (action, indexPath) in
            //Info
            self.selectedFoodItem = self.fetchedResultsController.object(at: indexPath)
            self.performSegue(withIdentifier: "DetailViewSegue", sender: self)
        }
        
        info.backgroundColor = UIColor.gray
        
        return [edit, delete, info];
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    
    //MARK: - Other methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddNewItemSegue" {
            if let viewController = segue.destination as? NewItemViewController{
                
                if selectedFoodItem != nil{
                    //Edit mode!
                    viewController.isEdit = true
                    viewController.foodItem = selectedFoodItem
                    
                }
                viewController.managedObjectContext = context
            }
        }
        
        if segue.identifier == "DetailViewSegue" {
            if let viewController = segue.destination as? ItemDetailViewController{
                viewController.foodItem = selectedFoodItem
            }
        }
    }

}



extension SelectItemViewController: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        print("updateSearchResults")
    }
}

extension SelectItemViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print("searchBar: selectedScopeButtonIndexDidChange")
    }
}

extension SelectItemViewController: NSFetchedResultsControllerDelegate{
    //methods
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type{
        case .insert:
            if let indexPath = newIndexPath{
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        case .delete:
            if let indexPath = indexPath{
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
        case .update:
            if let indexPath = indexPath{
                let cell = tableView.cellForRow(at: indexPath) as! ItemCell
                configure(cell, atIndexPath: indexPath)
            }
            break
        case .move:
            if let indexPath = indexPath{
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath{
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break
            
        }
    }
    
}
