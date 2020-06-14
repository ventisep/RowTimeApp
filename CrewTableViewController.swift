//
//  CrewTableViewController.swift
//  RowTime
//
//  Created by Paul Ventisei on 08/05/2016.
//  Copyright © 2016 Paul Ventisei. All rights reserved.
//

import UIKit
import CoreData
import Firebase

@available(iOS 13.0, *)
class CrewTableViewController: UITableViewController, UISearchResultsUpdating, UpdateableFromFirestoreListener{

    
    
    // MARK: Public Properties
    
    var event: Event?  = nil
    var eventId: String = ""
    var eventRef: DocumentReference?
    let crewData = CrewData()
    var times: [RecordedTime]? = nil
    
    // MARK: Private Properties
    
    private var filteredCrews = [Crew]()
    private var filterOn: Bool = false
    private let searchController = UISearchController.init(searchResultsController: nil) //searchResultsController nil if you want to display the search results in the same view controller that displays your searchable content.
    

    //MARK: Public Functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // set up the crewData datamodel delegate
        
        crewData.delegate = self
        
        // Set up the search controller

        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false;
        searchController.searchBar.sizeToFit()
        searchController.delegate = self as? UISearchControllerDelegate
        
        tableView.tableHeaderView = searchController.searchBar;
        tableView.delegate = self
        
        definesPresentationContext = true

        crewData.setCrewListener(forEvent: self.event!)
    }

    @IBAction func RefreshControl(_ sender: UIRefreshControl, forEvent event: UIEvent) {
        
        //refresh the crew data by using the crewData object and calling its refresh method
        //this recalculates the calculated times only as the model is updated by the listener
        
        tableView.reloadData()
        refreshControl?.endRefreshing()

    }
    
    //MARK: - UISearchResultsUpdating protocol conformance
    
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchString = self.searchController.searchBar.text
        //let buttonIndex = searchController.searchBar.selectedScopeButtonIndex
        
        if searchString != "" {
            filterOn = true
            filteredCrews.removeAll(keepingCapacity: true)
            
            let searchFilter: (Crew) -> Bool = { crew in
                if crew.crewName.contains(searchString!) {
                    return true
                } else {
                    return false
                }
            }
            
            filteredCrews = crewData.crewlist.filter(searchFilter)
            
        } else {
            filterOn = false
        }

        
        self.tableView.reloadData()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        // PV: updated to 1 section
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // PV: updated to count of rows in the crewlist array
        if filterOn{
            return filteredCrews.count
        } else {
            return crewData.crewlist.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "CrewTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CrewTableViewCell
        
        // Fetches the appropriate crew for the data source layout.
        var crew = crewData.crewlist[(indexPath as NSIndexPath).row]
        if filterOn {
            crew = filteredCrews[(indexPath as NSIndexPath).row]
        }
        
        cell.set(crew: crew)
        

        return cell
    }


    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowTimes" {
        
            let timerViewController = segue.destination as! TimerViewController
            
            // Get the cell that generated this segue.
            if let selectedCrewCell = sender as? CrewTableViewCell {
            
                let indexPath = tableView.indexPath(for: selectedCrewCell)!
                if filterOn {
                    timerViewController.crew = filteredCrews[(indexPath as NSIndexPath).row]
                } else {
                    timerViewController.crew = crewData.crewlist[(indexPath as NSIndexPath).row]
                }

                timerViewController.event = event
                timerViewController.eventId = eventId
                timerViewController.recordMode = true
            }
        }
        if segue.identifier == "addCrew" {
            let crewViewController = segue.destination as! CrewViewController
            crewViewController.event = event
        }
    }
    
    @IBAction func unwindToCrewList(_ sender: UIStoryboardSegue){
        if sender.identifier == "unwindAddCrew" {
            print("unwinding adding a crew")
            if let sourceViewController = sender.source as? CrewViewController, let crew = sourceViewController.crew {
                
            // Add a new crew. not needed becasue listener picks it up
            //    let newIndexPath = IndexPath(row: crewData.crewlist.count, section: 0)
            //    crewData.crewlist.append(crew)
            //    tableView.insertRows(at: [newIndexPath], with: .bottom)
            }
        } else if sender.identifier == "unwindCancelCrew" {
            print("Unwinding Cancel of Adding a Crew")
        }
        self.tableView.reloadData()

    }
    
    override func didMove(toParent parent: UIViewController?) {
        if !(parent?.isEqual(self.parent) ?? false) {
            print("Parent view loaded")
            crewData.stopListening()
        }

        super.didMove(toParent: parent)
    }
    
    // MARK: - update from model
    
    
    @IBAction func Sort(_ sender: UIBarButtonItem) {
        // var menustyle = UIAlertActionStyle(rawValue: 1)
        // let menu = UIAlertAction(title: "menu", style: menustyle!, handler: <#T##((UIAlertAction) -> Void)?##((UIAlertAction) -> Void)?##(UIAlertAction) -> Void#>)
    }
    
    func didUpdateModel() {
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    func willUpdateModel() {
        refreshControl?.beginRefreshing()
    }
}

