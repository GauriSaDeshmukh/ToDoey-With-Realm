//
//  ItemListTableViewController.swift
//  ToDoey With Realm
//
//  Created by indianrenters on 07/09/19.
//  Copyright © 2019 indianrenters. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ItemListTableViewController: SwipeTableViewController {
    
    @IBOutlet weak var iTemSearchBar: UISearchBar!
    
    let realm = try! Realm()
    var itemsObject: Results<Items>?
    
    var selectedCategory: Category?
    {
        didSet
        {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory?.name
        guard let category = selectedCategory?.color else{fatalError()}
        updateNavBar(withHexCode: category)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateNavBar(withHexCode: "1D9BF6")
        
    }
    
    //MARK: - Update Navigation Bar
    func updateNavBar(withHexCode colorHexCode: String)
    {
        guard let navBar = navigationController?.navigationBar else{fatalError()}
        guard let categoryColor = UIColor(hexString: colorHexCode) else {fatalError()}
        
        navBar.barTintColor = categoryColor
        navBar.tintColor = ContrastColorOf(categoryColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [.foregroundColor : ContrastColorOf(categoryColor, returnFlat: true)]
        iTemSearchBar.barTintColor = categoryColor
    }
    
    // MARK: - Tableview DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemsObject?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let toDoItem = itemsObject?[indexPath.row]
        {
            cell.textLabel?.text = toDoItem.title
            
            cell.accessoryType = toDoItem.done ? .checkmark : .none
            
            if let categoryColor = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemsObject!.count))
            {
                cell.backgroundColor = categoryColor
                
                cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
            }
            
        }
        else
        {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = itemsObject?[indexPath.row]
        {
            do{
                try realm.write {
                    
                    item.done = !item.done
                }
            }
            catch
            {
                print("Error in saving done \(error)")
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    
    //MARK: - Add New Item
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var itemTextField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory
            {
                do
                {
                    try self.realm.write {
                        
                        let newitem = Items()
                        newitem.title = itemTextField.text!
                        newitem.dateCreated = Date()
                        currentCategory.item.append(newitem)
                    }
                }
                catch
                {
                    print("Error in adding new item \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (textField) in
            
            textField.placeholder = "Create New Item"
            itemTextField = textField
            
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func loadItems()
    {
        itemsObject = selectedCategory?.item.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    //MARK: - SwipeTableViewCotroller delegate Method
    
    override func deleteRow(indexPath: IndexPath) {
        
        if let item = self.itemsObject?[indexPath.row]
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

extension ItemListTableViewController: UISearchBarDelegate
{
    
    //MARK: - SearchBar Mrthods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        itemsObject = selectedCategory?.item.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count == 0
        {
            loadItems()
            
            DispatchQueue.main.async {
                
                searchBar.resignFirstResponder()
                
            }
        }
        
    }
}
