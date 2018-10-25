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
        
        var fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Book")
        //fetchRequest.predicate = NSPredicate(format: "title = %@", title)
        var results: [NSManagedObject] = []

        
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
            
            //Check whether the book title exists in the database.
            fetchRequest.predicate = NSPredicate(format: "title == %@", titleTextField.text!)
            
            do {
                results = (try self.managedObjectContext?.fetch(fetchRequest))!
            }
            catch {
                print("Error executing fetch request: \(error)")
            }
            
            //If the book exists display an error alert.
            if ( results.count > 0 ) {
                //(fetchRequest.predicate == NSPredicate(format: "title = %@", NSString(value: titleTextField.text! as String))) {
                //( results = try managedObjectContext.fetch(fetchRequest) ) {
                //( managedObjectContext?.fetch(fetchRequest).contains("\(titleTextField.text!)" ))
                //( entity.propertiesByName.keys.contains("\(titleTextField.text!)") ) {
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
        /*if segue.identifier == "toFilterViewController" {
         if let indexPath = tableView.indexPathForSelectedRow {
         let object = fetchedResultsController.object(at: indexPath)
         let controller = segue.destination as! PlayerListViewController
         controller.currentTeam = object
         controller.managedObjectContext = managedObjectContext
         controller.navigationItem.leftItemsSupplementBackButton = true
         }
         }*/
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
        } /*else if editingStyle == .insert {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            context.insert(fetchedResultsController.object(at: indexPath))
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        } */
        tableView.reloadData()
    }
    
    // MARK: - Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = fetchedResultsController.object(at: indexPath)
        let context = self.managedObjectContext
        
        let alert = UIAlertController(title: "Book Information", message: "Edit book information", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = book.title
            textField.textAlignment = .center
            textField.keyboardType = .default
        }
        
        alert.addTextField { textField in
            //textField.addConstraint(textField.heightAnchor.constraint(equalToConstant: 10))
            //textField.isEnabled = true
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
            
            /*if ( tableView.cellForRow(at: indexPath)?.isSelected == true &&
                ( ( (book.title?.elementsEqual(titleTextField.text!))! == true && (book.title?.count == titleTextField.text?.count) ) && ( (book.author?.elementsEqual(authorTextField.text!))! == true && (book.author?.count == authorTextField.text?.count)) &&
                ( (book.releaseYear?.elementsEqual(releaseYearTextField.text!))! == true && (book.releaseYear?.count == releaseYearTextField.text?.count)) )
                )*/
                //( alert.textFields?[0].text == book.title && alert.textFields?[1].text == book.author && alert.textFields?[2].text == book.releaseYear )
                //||
                /*( (book.title?.isEqualToString(find: titleTextField.text!))! &&  (book.author?.isEqualToString(find: authorTextField.text!))! &&
                 (book.releaseYear?.isEqualToString(find: releaseYearTextField.text!))!
                 ) )*/
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
                    //tableView.reloadData()
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
        present(alert, animated: true)
        
        //context?.save()
        //tableView.reloadData()
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
/*
    var fetchedResultsController: NSFetchedResultsController<Book> {
       
        //
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
    */
    
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
    
    /*class TextField: UITextField {
        
        let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        
        override open func textRect(forBounds bounds: CGRect) -> CGRect {
            return UIEdgeInsetsInsetRect(bounds, padding)
        }
        
        override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
            return UIEdgeInsetsInsetRect(bounds, padding)
        }
        
        override open func editingRect(forBounds bounds: CGRect) -> CGRect {
            return UIEdgeInsetsInsetRect(bounds, padding)
        }
    }*/
    
}

extension TableViewController: FilterViewControllerDelegate {
    func filterViewController(filter: FilterViewController, didSelectPredicate predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?) {
        //fetchRequest.predicate = nil
        //fetchRequest.sortDescriptors = nil
        //fetchRequest.predicate = predicate
        
        //if let sr = sortDescriptor {
        //    fetchRequest.sortDescriptors = [sr]
        //}
        
        fetchAndReload(sort: [sortDescriptor!])
    }
}

extension String {
    func isEqualToString(find: String) -> Bool {
        return String(format: self) == find
    }
}

