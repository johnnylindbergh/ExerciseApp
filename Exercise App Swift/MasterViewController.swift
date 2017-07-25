//
//  MasterViewController.swift
//  Exercise App Swift
//
//  Created by Johnny Lindbergh on 7/15/17.
//  Copyright © 2017 Johnny Lindbergh. All rights reserved.
//
import UIKit

class MasterViewController: UITableViewController, UISearchBarDelegate {

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    var filteredArray = [String]()
    var shouldShowSearchResults = false

    class Workout: NSObject{
        var workoutName:String = ""
        var workoutDescription:String = ""
        var workoutPhoto:String = ""
        
        init(workoutName: String, workoutDescription: String, workoutPhoto:String) {
            self.workoutName = workoutName
            self.workoutDescription = workoutDescription
            self.workoutPhoto = workoutPhoto
        }
    }
    
    
    func createSearchBar(){
        
        let searchBar = UISearchBar()
        searchBar.showsCancelButton = true
        searchBar.placeholder = "Enter Workout Name"
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        searchBar .resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        self.tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredArray = [searchText]
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        shouldShowSearchResults = false
        self.tableView.reloadData()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSearchBar()
        
        let url = URL(string: "http://jlindbergh.com/workouts.json")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil
            {
                print("Error!")
            }
            else
            {
                if let content = data
                {
                    do
                    {
                        let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        for var index in 0 ..< myJson.count{
                                let workout = (myJson as! NSArray)[index] as! NSDictionary
                                let w = Workout(workoutName: workout["workout-name"] as! String, workoutDescription: workout["workout-description"] as! String, workoutPhoto:workout["workout-photo"] as! String);
                                
                                self.objects.insert(w, at: 0)
                                let indexPath = IndexPath(row: 0, section: 0)
                                self.tableView.insertRows(at: [indexPath], with: .automatic)
                                self.tableView.reloadData()

                                
                            
                        }
                      //  self.tableView.reloadData()
                    }
                   catch
                   {
                    print("catch")
                }
                }
            }
        }
        task.resume()
        tableView.reloadData()
        
//        let w = Workout(workoutName: "", workoutDescription: "", workoutPhoto:"");
//        objects.insert(w, at: 0)
//        let indexPath = IndexPath(row: 0, section: 0)
//        tableView.insertRows(at: [indexPath], with: .automatic)
//        self.tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    func insertNewObject(_ sender: Any) {
//        let d = "workout Name";
//        objects.insert(d, at: 0)
//        let indexPath = IndexPath(row: 0, section: 0)
//        tableView.insertRows(at: [indexPath], with: .automatic)
//    }

    // MARK: - Segues
func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    
}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! Workout;
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                let workoutPhotoURL = object.workoutPhoto
                let PictureURL = URL(string: workoutPhotoURL)!
                
                
                let session = URLSession(configuration: .default)
                
                let downloadPicTask = session.dataTask(with: PictureURL) { (data, response, error) in
                    if let e = error {
                        print("Error downloading picture: \(e)")
                    } else {
                        if let res = response as? HTTPURLResponse {
                            print("Downloaded picture with response code \(res.statusCode)")
                            if let imageData = data {
                                let image = UIImage(data: imageData)
                                let imageView = UIImageView(frame: self.CGRectMake(100, 100, 200, 150));
                                imageView.image = image;
                                controller.view.addSubview(imageView);
                            } else {
                                print("Couldn't get image: Image is nil")
                            }
                        } else {
                            print("Couldn't get response code for some reason")
                        }
                    }
                }
                
                downloadPicTask.resume()
                controller.detailItem = object.workoutDescription
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View
    
   

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults{
            return filteredArray.count
        }else{
        return objects.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = objects[indexPath.row] as! Workout
        if shouldShowSearchResults{
            cell.textLabel!.text = filteredArray[indexPath.row]
            return cell
        }else{
        cell.textLabel!.text = object.workoutName
        return cell
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

