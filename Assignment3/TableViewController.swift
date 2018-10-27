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
    var fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
    var coreDataStack: CoreDataStack!
    var books: [Book] = []
    var fetchedResultsController: NSFetchedResultsController<Book>!
    var sortedFetchedResultsController: NSFetchedResultsController<Book>? = nil
    
    // MARK: - Outlets
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    // MARK: - Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        //let sortDescriptor: NSSortDescriptor?
        //if let sr = sortDescriptor {
            //fetchRequest.sortDescriptors = [sortDescriptor]
        //}
        //var sr = [NSSortDescriptor]()
        //sr.append(sortDescriptor)
        
        fetchAndReload(sort: [sortDescriptor])
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
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Book")
        //fetchRequest.predicate = NSPredicate(format: "title = %@", title)
        var titleResults: [NSManagedObject] = []
        var authorResults: [NSManagedObject] = []

        
        let alert = UIAlertController(title: "Book Information", message: "Add a new book", preferredStyle: .alert)
        
        alert.addTextField {
            textField in
            textField.placeholder = "Book Title"
            textField.textAlignment = .center
            textField.keyboardType = .default
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Author"
            textField.textAlignment = .center
            textField.keyboardType = .default
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Release Year"
            textField.textAlignment = .center
            textField.keyboardType = .numberPad
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            
            guard let titleTextField = alert.textFields?[0], let authorTextField = alert.textFields?[1], let releaseYearTextField = alert.textFields?[2] else {
                return
            }
            
            //Check whether the book title or author exist in the database.
            fetchRequest.predicate = NSPredicate(format: "title == %@", titleTextField.text!)
            fetchRequest.predicate = NSPredicate(format: "author == %@", authorTextField.text!)
            
            do {
                titleResults = (try self.managedObjectContext?.fetch(fetchRequest))!
            }
            catch {
                print("Error executing Title fetch request: \(error)")
            }
            do {
                authorResults = (try self.managedObjectContext?.fetch(fetchRequest))!
            }
            catch {
                print("Error executing Author fetch request: \(error)")
            }
        
            // If the book and author exists as a record display an error alert. Reason: There could be
            // several books with the same name, there are also authors of many books, only in this specific
            // case would this be relevant.
            if ( titleResults.count > 0 && authorResults.count > 0 ) {
        
                let alert = UIAlertController(title: "Book already exists!", message: "\n Try adding a different book or edit the current one to update it.", preferredStyle: .alert)
                
                self.present(alert, animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
                    alert.dismiss(animated: true, completion: nil)
                })
                
            } else {
            
            self.save(title: titleTextField.text!, author: authorTextField.text!, releaseYear: releaseYearTextField.text!)
            self.tableView.reloadData()
            }
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        alert.addAction(saveAction)
        present(alert, animated: true)
    }

    
    func save(title: String, author: String, releaseYear: String) {
        let context = self.managedObjectContext
        
        //Insert a new team into the context
        let entity = NSEntityDescription.entity(forEntityName: "Book", in: context!)!
        let book = Book(entity: entity, insertInto: context)
        book.title = title
        book.author = author
        book.releaseYear = releaseYear
        
        // Save the context.
        do {
            try context?.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "toFilterViewController", let navController = segue.destination as? UINavigationController, let filterViewCcontroller = navController.topViewController
            as? FilterViewController else {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let object = fetchedResultsController.object(at: indexPath)
                    let controller = segue.destination as! TableViewController
                    controller.books = [object]
                    controller.managedObjectContext = managedObjectContext
                    //controller.navigationItem.leftItemsSupplementBackButton = true
                }
                return
        }
        
        filterViewCcontroller.fetchedResultsController = fetchedResultsController
        filterViewCcontroller.delegate = self
    }
    
    @IBAction func unwindToTableViewController(_ segue: UIStoryboardSegue) {
    }
    
    // MARK: - Table view data source methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    
    /*override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let sectionInfo = fetchedResultsController.sections?[section]
        return sectionInfo?.name
    }*/
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
 
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> BookCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookInfoCell", for: indexPath)
        
        // Configure the cell...
        let book = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withBook: book)
        return cell as! BookCell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let editOrViewAlert = UIAlertController(title: "Choose an option", message: "Edit or View Book Details?", preferredStyle: .alert)
        
        let editAction = UIAlertAction(title: "Edit", style: .default) {
            [unowned self] action in
            
            
            let book = self.fetchedResultsController.object(at: indexPath)
            let context = self.managedObjectContext
            
            let alert = UIAlertController(title: "Book Information", message: "Edit book information", preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.text = book.title
                textField.textAlignment = .center
                textField.keyboardType = .default
            }
            
            alert.addTextField { textField in
                textField.text = book.author
                textField.textAlignment = .center
                textField.keyboardType = .default
            }
            
            alert.addTextField { textField in
                textField.text = book.releaseYear
                textField.textAlignment = .center
                textField.keyboardType = .numberPad
            }
            
            let saveAction = UIAlertAction(title: "Save", style: .default) {
                [unowned self] action in
                
                guard let titleTextField = alert.textFields?[0], let authorTextField = alert.textFields?[1], let releaseYearTextField = alert.textFields?[2] else {
                    return
                }

                if ( tableView.cellForRow(at: indexPath)?.isSelected == true && ( ( book.title! == titleTextField.text!   &&  book.author! == authorTextField.text! && book.releaseYear! == releaseYearTextField.text! ) ) )
                {
                    print("Row is identical, no update needed.")
                } else {
                    
                    book.title! = titleTextField.text!
                    book.author! = authorTextField.text!
                    book.releaseYear! = releaseYearTextField.text!
                    
                    self.save(title: titleTextField.text!, author: authorTextField.text!, releaseYear: releaseYearTextField.text!)
                    
                    context?.delete(self.fetchedResultsController.object(at: indexPath))
                    context?.insert(self.fetchedResultsController.object(at: indexPath))
                    
                    do {
                        print("Row is DIFFERENT, updated with Title: \(titleTextField.text!), Author: \(authorTextField.text!), Release: \(releaseYearTextField.text!)")
                        try context?.save()
                        tableView.reloadRows(at: [indexPath], with: .top)
                        tableView.reloadData()
                        
                    } catch {
                        // Replace this implementation with code to handle the error appropriately.
                        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        let nserror = error as NSError
                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                }
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default))
            alert.addAction(saveAction)
            self.present(alert, animated: true)
        }
        editOrViewAlert.addAction(editAction)
        editOrViewAlert.addAction(UIAlertAction(title: "View", style: .default))
        self.present(editOrViewAlert, animated: true)
    }
    
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
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            //configureCell(tableView.cellForRow(at: indexPath!)!, withBook: anObject as! Book)
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            configureCell(tableView.cellForRow(at: indexPath!)!, withBook: anObject as! Book)
        case .move:
            //configureCell(tableView.cellForRow(at: indexPath!)!, withBook: anObject as! Book)
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func fetchAndReload(sort: [NSSortDescriptor]) {
        
        // create fetched fetch request and fetched results controller
        // 1
        let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
        
        let titleAZSort = NSSortDescriptor(key: #keyPath(Book.title), ascending: true)
        //let titleZASort = NSSortDescriptor(key: #keyPath(Book.title), ascending: false)
        
        fetchRequest.sortDescriptors = [titleAZSort]
        
        fetchRequest.fetchBatchSize = 20
        
        // 2
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: #keyPath(Book.title), cacheName: "assignment3")
        
        fetchedResultsController.delegate = self
        
        // 3
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        do {
            //_ = sortedFetchedResultsController?.managedObjectContext
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}

extension TableViewController: FilterViewControllerDelegate {
    func filterViewController(filter: FilterViewController, didSelectPredicate predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?) {
        fetchAndReload(sort: [sortDescriptor!])
    }
}

