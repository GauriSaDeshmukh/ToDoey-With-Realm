//
//  ItemListTableViewController.swift
//  ToDoey With Realm
//
//  Created by indianrenters on 07/09/19.
//  Copyright © 2019 indianrenters. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class ItemListTableViewController: UITableViewController {
    
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
    
    // MARK: - Tableview DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemsObject?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        if let toDoItem = itemsObject?[indexPath.row]
        {
            cell.textLabel?.text = toDoItem.title
            
            cell.accessoryType = toDoItem.done ? .checkmark : .none
        }
        else
        {
            cell.textLabel?.text = "No items added"
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
    
}

extension ItemListTableViewController: UISearchBarDelegate, SwipeTableViewCellDelegate
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
    
    //MARK:- SwipeTableViewCell Delegate Method
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
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
            tableView.reloadData()
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")
        
        return [deleteAction]
    }
}
