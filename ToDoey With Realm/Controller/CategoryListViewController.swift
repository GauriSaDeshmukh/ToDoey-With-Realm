//
//  ViewController.swift
//  ToDoey With Realm
//
//  Created by indianrenters on 07/09/19.
//  Copyright © 2019 indianrenters. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryListViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loadCategories()
        
       
    }
    
    //MARK: - TabelView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Category Available"
        
        cell.backgroundColor = UIColor.init(hexString: categories?[indexPath.row].color ?? "#000000")
        
        return cell
        
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        //if categories?.count != 0
        //{
            performSegue(withIdentifier: "toDoItemList", sender: self)
       // }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toDoItemList"
        {
            let vc = segue.destination as! ItemListTableViewController
            
            if let indexPath = tableView.indexPathForSelectedRow
            {
                vc.selectedCategory = categories?[indexPath.row]
            }
        }
        
    }
    
    //MARK: - Add New Category
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var categoryTextField = UITextField()
        
        let alert = UIAlertController(title: "Add New Categoty", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            let category = Category()
            
            category.name = categoryTextField.text!
            category.color = UIColor.hexValue(UIColor.randomFlat)()
            
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
            
            textField.placeholder = "Create New Category"
            categoryTextField = textField
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Retrive data from database
    
    func loadCategories()
    {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    override func deleteRow(indexPath: IndexPath) {
        
        if let item = self.categories?[indexPath.row]
        {
            do{
                try self.realm.write {

                    self.realm.delete(item)
                }
            }
            catch
            {
                print("Error in saving done \(error)")
            }
        }
        
    }
}

