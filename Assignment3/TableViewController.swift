//
//  ViewController.swift
//  Assignment3
//
//  Created by Joshua Aaron Flores Stavedahl on 10/16/18.
//  Copyright © 2018 Northern Illinois University. All rights reserved.
//

import UIKit
import CoreData
import AudioToolbox
import AVFoundation

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
    @IBAction func addBook(_ sender: AnyObject) {
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Book")
        //fetchRequest.predicate = NSPredicate(format: "title = %@", title)
        var titleResults: [NSManagedObject] = []
        var authorResults: [NSManagedObject] = []
        var ratingInt: Int?
        var yearInt: Int?
        
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
        
        alert.addTextField { textField in
            textField.placeholder = "Rating ( 1 - 5 )"
            textField.textAlignment = .center
            textField.keyboardType = .numberPad
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            
            guard let titleTextField = alert.textFields?[0], let authorTextField = alert.textFields?[1], let releaseYearTextField = alert.textFields?[2], let ratingTextField = alert.textFields?[3] else {
                return
            }
            
            ratingInt = Int("\(ratingTextField)")
            yearInt = Int("\(releaseYearTextField)")
            
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
            /*if ( titleResults.count > 0  ) {
                
                print("Executed title condition only")
                
                let titleAlert = UIAlertController(title: "Book already exists?", message: "\n If this is a book written by a different author with the same name add it, otherwise lease edit a current book.", preferredStyle: .alert)
                titleAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(titleAlert, animated: true, completion: nil)
            }*/
            if ( titleResults.count > 0 && authorResults.count > 0 ) {
        
                
                let systemSoundID: SystemSoundID = 1016
                
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                AudioServicesPlaySystemSound (systemSoundID)
                
                let alert = UIAlertController(title: "Book already exists!", message: "\n Try adding a different book or edit the current one to update it.", preferredStyle: .alert)
                
                self.present(alert, animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
                    alert.dismiss(animated: true, completion: nil)
                })
                
            } /*else if ( ratingInt! > 5 ) {
                
            } else if ( yearInt! > 2019 ) {
                
            }*/ else {
            
            self.save(title: titleTextField.text!, author: authorTextField.text!, releaseYear: releaseYearTextField.text!, rating: ratingTextField.text!)
            self.tableView.reloadData()
            }
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        alert.addAction(saveAction)
        present(alert, animated: true)
    }

    
    func save(title: String, author: String, releaseYear: String, rating: String) {
        let context = self.managedObjectContext
        
        //Insert a new team into the context
        let entity = NSEntityDescription.entity(forEntityName: "Book", in: context!)!
        let book = Book(entity: entity, insertInto: context)
        book.title = title
        book.author = author
        book.releaseYear = releaseYear
        book.rating = rating
        
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
        if segue.identifier == "toFilterViewController" {
            guard let navController = segue.destination as? UINavigationController, let filterViewCcontroller = navController.topViewController as? FilterViewController else {
                return
            }
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = segue.destination as! DetailViewController
                controller.books = [object]
                controller.managedObjectContext = managedObjectContext
                filterViewCcontroller.fetchedResultsController = fetchedResultsController
                filterViewCcontroller.delegate = self
                    //controller.navigationItem.leftItemsSupplementBackButton = true
            }
        } else if segue.identifier == "toDetailViewController" {
            guard let detailViewController = segue.destination as? DetailViewController else {
                return
            }
            if let indexPath = tableView?.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                detailViewController.detailItem = object
                //detailViewController.books = [object]
                detailViewController.managedObjectContext = managedObjectContext
            }
        }
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
        
        let viewAction = UIAlertAction(title: "View", style: .default) {
            [unowned self] action in
            
            self.performSegue(withIdentifier: "toDetailViewController", sender: self)
        }
        
        let editAction = UIAlertAction(title: "Edit", style: .default) {
            [unowned self] action in
            
            let book = self.fetchedResultsController.object(at: indexPath)
            let context = self.managedObjectContext
            
            let alert = UIAlertController(title: "Book Information", message: "Edit book information", preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.text = book.title
                textField.textAlignment = .center
                textField.keyboardType = .default
                if ( textField.text == "")
                {
                    textField.placeholder = "Title"
                }
            }
            
            alert.addTextField { textField in
                textField.text = book.author
                textField.textAlignment = .center
                textField.keyboardType = .default
                if ( textField.text == "")
                {
                    textField.placeholder = "Author"
                }
            }
            
            alert.addTextField { textField in
                textField.text = book.releaseYear
                textField.textAlignment = .center
                textField.keyboardType = .numberPad
                if ( textField.text == "")
                {
                    textField.placeholder = "Release Year"
                }
            }
            
            alert.addTextField { textField in
                textField.text = book.rating
                textField.textAlignment = .center
                textField.keyboardType = .numberPad
                if ( textField.text == "")
                {
                    textField.placeholder = "Rating"
                }
            }
            
            let saveAction = UIAlertAction(title: "Save", style: .default) {
                [unowned self] action in
                
                guard let titleTextField = alert.textFields?[0], let authorTextField = alert.textFields?[1], let releaseYearTextField = alert.textFields?[2], let ratingTextField = alert.textFields?[3] else {
                    return
                }

                if ( tableView.cellForRow(at: indexPath)?.isSelected == true && ( ( book.title! == titleTextField.text!   &&  book.author! == authorTextField.text! && book.releaseYear! == releaseYearTextField.text! && book.rating! == ratingTextField.text! ) ) )
                {
                    print("Row is identical, no update needed.")
                } else {
                    
                    book.title! = titleTextField.text!
                    book.author! = authorTextField.text!
                    book.releaseYear! = releaseYearTextField.text!
                    book.rating = ratingTextField.text!
                    
                    self.save(title: titleTextField.text!, author: authorTextField.text!, releaseYear: releaseYearTextField.text!, rating:  ratingTextField.text!)
                    
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
        editOrViewAlert.addAction(viewAction)
        self.present(editOrViewAlert, animated: true)
    }
    
    // MARK: - Helper methods
    
    // Configure table cell
    func configureCell(_ cell: UITableViewCell, withBook book : Book) {
        
        guard let cell = cell as? BookCell else {
            return
        }
        
        var ratingInt: Int?
        var year: Int?
        
        if book.rating == nil {
            book.rating = "0"
            ratingInt = Int(book.rating!)!
            //book.image = 0 as NSObject
        }
        
        ratingInt = Int(book.rating!)
        year = Int(book.releaseYear!)
        
        cell.titleLabel!.text = book.title
        cell.authorLabel!.text = "Author: \(book.author!)"
        cell.releaseYearLabel!.text = "Release Year: " + "\(book.releaseYear!)"
        cell.ratingLabel!.text = "Rating : \(ratingInt!) / 5"
        //cell.ratingLabel!.text = "Rating : \(String(describing: ratingInt)) / 5"
        
        if ratingInt == nil {
            cell.ratingLabel.text = "Rating : 0 / 5"
            cell.ratingLabel.textColor = UIColor.blue
            cell.ratingLabel.someTextColorChange(fullText: cell.ratingLabel.text!, changeText: "Rating: ")
        } else if ratingInt! == 1 {
            cell.ratingLabel!.textColor = UIColor.red
            cell.ratingLabel!.shadowColor = UIColor.gray
            cell.ratingLabel!.someTextColorChange(fullText: cell.ratingLabel.text!, changeText: "Rating: ")
        }else if ratingInt! == 2  {
            cell.ratingLabel!.textColor = UIColor.darkGray
            cell.ratingLabel!.shadowColor = UIColor.black
            cell.ratingLabel!.someTextColorChange(fullText: cell.ratingLabel.text!, changeText: "Rating: ")
        } else if ratingInt! == 3  {
            cell.ratingLabel!.textColor = UIColor.brown
            //cell.ratingLabel!.shadowColor = UIColor.black
            cell.ratingLabel!.someTextColorChange(fullText: cell.ratingLabel.text!, changeText: "Rating: ")
        } else if ratingInt! == 4  {
            cell.ratingLabel!.textColor = UIColor.purple
            //cell.ratingLabel!.shadowColor = UIColor.black
            cell.ratingLabel!.someTextColorChange(fullText: cell.ratingLabel.text!, changeText: "Rating: ")
        } else if ratingInt! == 5 {
            cell.ratingLabel!.textColor = UIColor.green
            cell.ratingLabel!.someTextColorChange(fullText: cell.ratingLabel.text!, changeText: "Rating: ")
        } else {
            cell.ratingLabel!.textColor = UIColor.orange
            cell.ratingLabel!.someTextColorChange(fullText: cell.ratingLabel.text!, changeText: "Rating: ")
        }
        
        if year == nil {
            cell.releaseYearLabel!.text = "Undeclared"
            cell.releaseYearLabel!.textColor = UIColor.darkGray
            cell.releaseYearLabel!.someTextColorChange(fullText: cell.ratingLabel.text!, changeText: "Release Year: ")
        } else if year! < 1989 {
            cell.releaseYearLabel!.textColor = UIColor.darkGray
            //cell.releaseYearLabel!.shadowColor = UIColor.black
            cell.releaseYearLabel!.someTextColorChange(fullText: cell.ratingLabel.text!, changeText: "Release Year: ")
        } else if year! >= 1989 && year! < 1999 {
            cell.releaseYearLabel!.textColor = UIColor.brown
            //cell.releaseYearLabel!.shadowColor = UIColor.black
            cell.releaseYearLabel!.someTextColorChange(fullText: cell.ratingLabel.text!, changeText: "Release Year: ")
        } else if year! >= 1999 && year! < 2010 {
            cell.releaseYearLabel!.textColor = UIColor.purple
            //cell.releaseYearLabel!.shadowColor = UIColor.black
            cell.releaseYearLabel!.someTextColorChange(fullText: cell.ratingLabel.text!, changeText: "Release Year: ")
        } else if year! >= 2010 && year! < 2017 {
            cell.releaseYearLabel!.textColor = UIColor.green
            //cell.releaseYearLabel!.shadowColor = UIColor.black
            cell.releaseYearLabel!.someTextColorChange(fullText: cell.ratingLabel.text!, changeText: "Release Year: ")
        } else {
            cell.releaseYearLabel!.textColor = UIColor.orange
            cell.releaseYearLabel!.someTextColorChange(fullText: cell.ratingLabel.text!, changeText: "Release Year: ")
        }
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
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: #keyPath(Book.title), cacheName: "Library")
        
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

extension UILabel {
    func someTextColorChange (fullText : String , changeText : String ) {
        let strNumber: NSString = fullText as NSString
        let range = (strNumber).range(of: changeText)
        let attribute = NSMutableAttributedString.init(string: fullText)
        attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black , range: range)
        self.attributedText = attribute
    }
}

