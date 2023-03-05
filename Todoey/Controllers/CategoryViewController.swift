//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Matthew Cheung on 26/2/2023.
//  Copyright © 2023 Matthew Cheng. All rights reserved.
//

import UIKit
import RealmSwift
import Chameleon


class CategoryViewController: SwipeTableViewController {
    
    lazy var realm = try! Realm()
    var categoryArray: Results<Category>?


    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("No Navigation bar loaded up")
        }
        navBar.scrollEdgeAppearance?.backgroundColor = UIColor(hexString: "1D9BF6")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super .tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Categories Added yet"
        cell.backgroundColor = UIColor(hexString: categoryArray?[indexPath.row].cellColor ?? "#FFFFFF")
        cell.textLabel?.textColor = UIColor.init(contrastingBlackOrWhiteColorOn: UIColor(hexString: (categoryArray?[indexPath.row].cellColor)!)!, isFlat: true)
        return cell
    }
    
    

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default){(action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.cellColor = UIColor.randomFlat().hexValue()
            self.save(newCategory)
        }
        alert.addTextField{(alertTextField) in
            alertTextField.placeholder = "Create new Category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
    func save(_ category: Category){
        do{
            try realm.write{
                realm.add(category)
            }
        }catch{
            print(error)
        }
        tableView.reloadData()
    }
    
    func loadCategory(){
        categoryArray = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    override func updateModel(_ indexPath: IndexPath) {
        do{
                        try self.realm.write{
                            self.realm.delete((self.categoryArray?[indexPath.row])!)
                        }
                    }catch{
                        print(error)
                    }
    }
}
