//
//  ViewController.swift
//  ToDoey With Realm
//
//  Created by indianrenters on 07/09/19.
//  Copyright © 2019 indianrenters. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryListViewController: UITableViewController {
    
    let realm = try! Realm()
    var categoryArray: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loadCategories()
        
        
    }
    
    //MARK: - TabelView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Category Available"
        
        return cell
        
    }
    
    //MARK: - Add New Category
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var categoryTextField = UITextField()
        
        let alert = UIAlertController(title: "Add New Categoty", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            let category = Category()
            
            category.name = categoryTextField.text!
            
            do{
                try self.realm.write {
                    self.realm.add(category)
                }
            }
            catch{
                print("Error \(error)")
            }
 
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (textField) in
            
            textField.placeholder = "Add New Category"
            categoryTextField = textField
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Retrive data from database
    
    func loadCategories()
    {
        categoryArray = realm.objects(Category.self)
        tableView.reloadData()
    }
}

