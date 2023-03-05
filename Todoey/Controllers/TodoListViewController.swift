//
//  ViewController.swift
//  Todoey
//
//  Created by Matthew Cheung on 6/2/2023.
//  Copyright © 2023 Matthew Cheung. All rights reserved.
//

import UIKit
import RealmSwift
import Chameleon

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var todoItems: Results<Items>?
    let realm = try! Realm()
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let titleColor = selectedCategory?.cellColor{
            title = selectedCategory!.name
            guard let navBar = navigationController?.navigationBar else {
                fatalError("No Navigation Controller loaded up ")
            }
            navBar.scrollEdgeAppearance?.backgroundColor = UIColor(hexString: titleColor)
            navBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn: UIColor(hexString: titleColor)!, isFlat: true)
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(contrastingBlackOrWhiteColorOn: UIColor(hexString: titleColor)!, isFlat: true)]
            searchBar.barTintColor = UIColor(hexString: titleColor)
            searchBar.searchTextField.backgroundColor = UIColor.flatWhite()

        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if  let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            if let cellColor = UIColor(hexString: selectedCategory!.cellColor)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)){
                cell.backgroundColor = cellColor
                cell.textLabel?.textColor = UIColor.init(contrastingBlackOrWhiteColorOn: cellColor, isFlat: true)
            }
           
            cell.accessoryType = item.done == true ? .checkmark : .none
        }else{
            cell.textLabel?.text = "No Items Added"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row]{
            do {
                try realm.write{
                    item.done = !item.done
                }
            }catch{
                print(error)
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write{
                        let item = Items()
                        item.title = textField.text!
                        item.done = false
                        item.dateCreated = Date()
                        currentCategory.items.append(item)
                    }
                }catch{
                    print(error)
                }
            }
            self.tableView.reloadData()
        }
        alert.addTextField{(alerTextField) in
            alerTextField.placeholder = "Create new item"
            textField = alerTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func loadItems(){
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
        
    }
    override func updateModel(_ indexPath: IndexPath) {
        do {
            try self.realm.write{
                self.realm.delete((self.todoItems?[indexPath.row])!)
            }
        }catch{
            print(error)
        }
    }
}
    extension TodoListViewController: UISearchBarDelegate{
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
        }
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchBar.text?.count == 0 {
                loadItems()
                DispatchQueue.main.async {
                    searchBar.resignFirstResponder()
                }
            }
        }
    }

