//
//  ViewController.swift
//  Assignment3
//
//  Created by Joshua Aaron Flores Stavedahl on 10/16/18.
//  Copyright © 2018 Northern Illinois University. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    // MARK: - Properties
    
    var coreDataStack: CoreDataStack!
    var fetchedResultsController: NSFetchedResultsController<Book>!
    
    // MARK: - UIViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fetchData()
        downloadJSONDataIfNeeded()
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
        
        let alert = UIAlertController(title: "Secret Team", message: "Add a new team", preferredStyle: .alert)
        
        alert.addTextField {
            textField in
            textField.placeholder = "Team Name"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Division"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            
            guard let nameTextField = alert.textFields?.first, let divisionTextField = alert.textFields?.last else {
                return
            }
            
            let book = Book(context: self.coreDataStack.managedContext)
            
            book.name = nameTextField.text
            book.releaseYear = divisionTextField.text
            book.imageName = team.teamName
            self.coreDataStack.saveContext()
        }
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Table view data source methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        guard let sections = fetchedResultsController?.sections else {
            return 0
        }
        
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let sectionInfo = fetchedResultsController.sections?[section]
        return sectionInfo?.name
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Configure the cell...
        configure(cell: cell, for: indexPath)
        
        return cell
    }
    
    // MARK: - Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let team = fetchedResultsController.object(at: indexPath)
        team.wins = team.wins + 1
        coreDataStack.saveContext()
        tableView.reloadData()
    }
    
    // MARK: - Helper methods
    
    // Configure table cell
    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        
        guard let cell = cell as? TeamCell else {
            return
        }
        
        let team = fetchedResultsController.object(at: indexPath)
        
        cell.logoImageView.image = UIImage(named: team.imageName!)
        cell.teamLabel.text = team.teamName
        cell.scoreLabel.text = "Wins: \(team.wins)"
    }
    
    // Fetch data
    func fetchData() {
        
        // 1
        let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
        
        let divisionSort = NSSortDescriptor(key: #keyPath(Team.division), ascending: true)
        let scoreSort = NSSortDescriptor(key: #keyPath(Team.wins), ascending: false)
        let nameSort = NSSortDescriptor(key: #keyPath(Team.teamName), ascending: true)
        fetchRequest.sortDescriptors = [divisionSort, scoreSort, nameSort]
        
        fetchRequest.fetchBatchSize = 20
        
        // 2
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.managedContext, sectionNameKeyPath: #keyPath(Team.division), cacheName: "nfl")
        
        fetchedResultsController.delegate = self
        
        // 3
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        
    }
    
    // Check if database is empty and download data if needed
    func downloadJSONDataIfNeeded() {
        let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
        let count = try! coreDataStack.managedContext.count(for: fetchRequest)
        
        guard count == 0 else {
            fetchData()
            return
        }
        
        do {
            let results = try coreDataStack.managedContext.fetch(fetchRequest)
            results.forEach({ coreDataStack.managedContext.delete($0) })
            
            coreDataStack.saveContext()
            downloadJSONData()
        } catch let error as NSError {
            print("Error fetching: \(error), \(error.userInfo)")
        }
    }
    
    // Download JSON data
    func downloadJSONData() {
        
        guard let url = URL(string: "https://www.prismnet.com/~mcmahon/CS321/teams.json") else {
            // Perform some error handling
            print("Error: Invalid URL for JSON data.")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {
            [weak self] (data, response, error) in
            
            let httpResponse = response as? HTTPURLResponse
            
            guard httpResponse!.statusCode == 200, data != nil, error == nil else {
                print("Error: No JSON data downloaded")
                return
            }
            
            // Download succeeded
            let array: [AnyObject]
            print(String(data: data!, encoding: .utf8) ?? "Nope")
            
            let teamEntity = NSEntityDescription.entity(forEntityName: "Team", in: self!.coreDataStack.managedContext)!
            
            do {
                array = try JSONSerialization.jsonObject(with: data!, options: []) as! [AnyObject]
            } catch {
                print("Unable to parse JSON data.")
                return
            }
            
            let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            privateMOC.parent = self!.coreDataStack.managedContext
            
            privateMOC.perform {
                for dictionary in array {
                    let team = Team(entity: teamEntity, insertInto: privateMOC)
                    team.teamName = dictionary["teamName"] as? String
                    team.division = dictionary["division"] as? String
                    team.wins = Int32(dictionary["wins"] as! Int)
                    team.imageName = dictionary["imageName"] as? String
                }
                
                do {
                    try privateMOC.save()
                    self!.coreDataStack.managedContext.performAndWait {
                        do {
                            try self!.coreDataStack.managedContext.save()
                        } catch {
                            fatalError("Failure to save context: \(error)")
                        }
                    }
                } catch {
                    fatalError("Failure to save context: \(error)")
                }
                
                DispatchQueue.main.async {
                    self!.fetchData()
                }
            }
        }
        
        task.resume()
    }
}

// MARK: - NSFetchedResultsControllerDelegate methods

extension TableViewController: NSFetchedResultsControllerDelegate {
    
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
            let cell = tableView.cellForRow(at: indexPath!) as! TeamCell
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
    }
}

