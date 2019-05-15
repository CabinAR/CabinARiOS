//
//  SpacesTableViewController.swift
//  CabinAR
//
//  Created by Pascal Rettig on 3/27/19.
//  Copyright © 2019 Pascal Rettig. All rights reserved.
//

import UIKit

class SpacesTableViewController: UITableViewController {
    
    var spaces: [CabinSpace]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        
        loadUserAndSpaces()

    }
    

    @objc func openSettings() {
        performSegue(withIdentifier: "optionsSegue", sender: self )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        
        let settings = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(openSettings))
        
        navigationItem.rightBarButtonItems = [settings]
    }
    
    func loadUserAndSpaces() {
        CabinARApi.api.getUser() { user in
            if user != nil {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.setUser(user!)
            }
            self.loadSpaces()
        }
    }
    
    func loadSpaces() {
        
        CabinARApi.api.getNearbySpaces() { spaces in
            self.spaces = spaces
            self.refreshTable()
        }
    }
    
    func refreshTable() {
        self.tableView.reloadData()
        //self.refreshControl?.endRefreshing()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return spaces?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "spaceCell", for: indexPath)

        // Configure the cell...
        
        let space = spaces![indexPath.row]
        cell.textLabel?.text = space.name
        cell.detailTextLabel?.text = "Visit Space"

        return cell
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
         if segue.identifier != "optionsSegue" {
            let viewController:SpaceViewController = segue.destination as! SpaceViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            let row = (indexPath! as NSIndexPath).row
            viewController.space = self.spaces![row]
         }
     }
     
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */



}
