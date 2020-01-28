//
//  SpacesTableViewController.swift
//  CabinAR
//
//  Created by Pascal Rettig on 3/27/19.
//  Copyright © 2019 Pascal Rettig. All rights reserved.
//

import UIKit
import CoreLocation


class SpacesTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var spaces: [CabinSpace]?
    var locationManager: CLLocationManager?
    
    var userLocation: CLLocationCoordinate2D?

    let refreshControlView = UIRefreshControl()


    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "backButton")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "backButton")
        //self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        self.navigationController?.navigationBar.tintColor = UIColor.lightGray

        let settings = UIBarButtonItem(image: UIImage(named:"config"), style: .plain, target: self, action: #selector(openSettings))
        navigationItem.rightBarButtonItems = [settings]
    
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControlView
        } else {
            tableView.addSubview(refreshControlView)
        }
        (refreshControlView).addTarget(self, action: #selector(refreshSpaces(_:)), for: .valueChanged)

        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        
    }
        
    override func viewDidAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.reloadScene {
            loadSpaces()
            appDelegate.reloadScene = false
        }
       
    }
    
    @objc private func refreshSpaces(_ sender: Any) {
        
        
        loadSpaces()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
             manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.userLocation = location.coordinate
            print("Found user's location: \(location)")
            loadUserAndSpaces()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
        loadUserAndSpaces()
    }

    @objc func openSettings() {
        performSegue(withIdentifier: "optionsSegue", sender: self )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        

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
        self.refreshControlView.beginRefreshing()
        CabinARApi.api.getNearbySpaces(self.userLocation) { spaces in
            
            DispatchQueue.main.async {
                self.refreshControlView.endRefreshing()
                self.spaces = spaces
                self.refreshTable()

            }
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Nearby"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return spaces?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.white
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "spaceCell", for: indexPath) as! SpaceTableViewCell

        // Configure the cell...
        
        let space = spaces![indexPath.row]
        cell.title.text = space.name
        cell.subtitle.text = space.tagline
        
        if let icon_url = space.icon_url {
            cell.icon.kf.setImage(with:  icon_url, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, URL) in
                cell.setNeedsLayout()
            })
        } else {
            cell.icon.image = nil
        }

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
