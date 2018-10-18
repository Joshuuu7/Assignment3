//
//  ViewController.swift
//  Assignment3
//
//  Created by Joshua Aaron Flores Stavedahl on 10/16/18.
//  Copyright © 2018 Northern Illinois University. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    // MARK: - Outlets
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    // MARK: - Properties
    
    //var coreDataStack: CoreDataStack!
    //var fetchedResultsController: NSFetchedResultsController<Book>!
    
    // MARK: - UIViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fetchData()
        //downloadJSONDataIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIResponder methods
    
    // Enable add button in response to shake gesture
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        
        if motion == .motionShake {
            addButton.isEnabled = true
        }
    }
    
    // MARK: - Actions
    
    // Add a new team to the database
    @IBAction func addTeam(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "Secret Book", message: "Add a new book", preferredStyle: .alert)
        
        alert.addTextField {
            textField in
            textField.placeholder = "Book Title"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Author"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Release Year"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            
            guard let titleTextField = alert.textFields?[0], let authorTextField = alert.textFields?[1], let releaseYearTextField = alert.textFields?[2] else {
                return
            }
            
            self.save(title: titleTextField.text!, author: authorTextField.text!, releaseYear: releaseYearTextField.text!)
            self.tableView.reloadData()
        }
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        present(alert, animated: true)
    }
    
    func save(title: String, author: String, releaseYear: String) {
        let context = self.fetchedResultsController.managedObjectContext
        
        //Insert a new team into the context
        let entity = NSEntityDescription.entity(forEntityName: "Book", in: context)!
        let book = Book(entity: entity, insertInto: context)
        book.title = title
        book.author = author
        book.releaseYear = releaseYear
        
        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    // MARK: - Segues
    
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlayers" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = segue.destination as! PlayerListViewController
                controller.currentTeam = object
                controller.managedObjectContext = managedObjectContext
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }*/
    
    // MARK: - Table view data source methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let sectionInfo = fetchedResultsController.sections?[section]
        return sectionInfo?.name
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Configure the cell...
        let book = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withBook: book)
        return cell
    }
    
    // MARK: - Table view delegate methods
    
    /*override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = fetchedResultsController.object(at: indexPath)
        //team.wins = team.wins + 1
        coreDataStack.saveContext()
        tableView.reloadData()
    }*/
    
    // MARK: - Helper methods
    
    // Configure table cell
    func configureCell(_ cell: UITableViewCell, withBook book : Book) {
        
        guard let cell = cell as? BookCell else {
            return
        }
        
        cell.titleLabel!.text = book.title
        cell.authorLabel!.text = "Author: \(book.author!)"
        cell.releaseYearLabel!.text = "Release Year: \(book.releaseYear!)"
    }

    var fetchedResultsController: NSFetchedResultsController<Book> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Books")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<Book>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(tableView.cellForRow(at: indexPath!)!, withBook: anObject as! Book)
        case .move:
            configureCell(tableView.cellForRow(at: indexPath!)!, withBook: anObject as! Book)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
     // In the simplest, most efficient, case, reload the table view.
     tableView.reloadData()
     }
     */
    


    
    // Fetch data
    /*func fetchData() {
        
        // 1
        let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
        
        let titleSort = NSSortDescriptor(key: #keyPath(Book.title), ascending: true)
        let authorSort = NSSortDescriptor(key: #keyPath(Book.author), ascending: false)
        let releaseYearSort = NSSortDescriptor(key: #keyPath(Book.releaseYear), ascending: true)
        fetchRequest.sortDescriptors = [titleSort, authorSort, releaseYearSort]
        
        fetchRequest.fetchBatchSize = 20
        
        // 2
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: fetchedResultsController.managedContext, sectionNameKeyPath: #keyPath(Book.title), cacheName: "assignment3")
        
        //fetchedResultsController.delegate = self
        
        // 3
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        
    }*/
 
    
// MARK: - NSFetchedResultsControllerDelegate methods

/*extension TableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            let cell = tableView.cellForRow(at: indexPath!) as! BookCell
            configure(cell: cell, for: indexPath!)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        default: break
        }
    }*/
}

