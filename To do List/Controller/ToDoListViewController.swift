import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var todoItems: Results<Item>?
    
    let realm = try! Realm()
    
    var selectedCategory : Category?{
        
        didSet{
            
            loadItems()
            
        }
    }
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0
        
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let colourHex = selectedCategory?.color{
            
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller Doesn't Exist")}
            
            if let navBarColour = UIColor(hexString: colourHex){
                
                navBar.backgroundColor = navBarColour
                
                navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
                
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColour, returnFlat: true)]
                
                searchBar.barTintColor = navBarColour
            }
        }
    }
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row]{
            
            cell.textLabel?.text = item.title
            
            if let colour = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage:
                                                                                    
                                                                                    CGFloat(indexPath.row) / CGFloat(todoItems!.count))
                
            {
                cell.backgroundColor = colour
                
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
                
            }
            //Ternary operator to make a verification of item checkmark
            cell.accessoryType = item.done ? .checkmark : .none
            
        }else{
            
            cell.textLabel?.text = "No items added"
            
        }
        
        return cell
        
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            
            do{
                
                try realm.write{
                    
                    item.done = !item.done
                    
                }
                
            }catch{
                
                print("Error Saving Done Status,\(error)")
            }
            
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    //MARK: -  Add New Item
    @IBAction func addBTNPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            //What will happen when user press our UIAlertBTN
            if let currentCategory = self.selectedCategory {
                
                do{
                    
                    try self.realm.write{
                        
                        let newItem = Item()
                        
                        newItem.title = textField.text!
                        
                        newItem.dateCreated = Date()
                        
                        currentCategory.items.append(newItem)
                        
                    }
                    
                }catch{
                    
                    print("Error Saving New Items, \(error)")
                    
                }
                
            }
            
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Create new Item"
            
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    //MARK: - Model Manipulation Methods
    
    
    //Take our data and decode it in cache
    func loadItems(){
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    //MARK: - Delete from Swipe
    
    override func updModel(at indexPath: IndexPath) {
        
        if let itemForDelete = self.todoItems?[indexPath.row] {
            
            do {
                
                try self.realm.write {
                    
                    self.realm.delete(itemForDelete)
                    
                }
                
            } catch {
                
                print("Error deleting item, \(error)")
                
            }
            
        }
        
    }
    
}
//MARK: - Search Bar Methods
extension ToDoListViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        
        if searchBar.text?.count == 0 {
            
            loadItems()
            
            DispatchQueue.main.async {
                
                searchBar.resignFirstResponder()
                
            }
            
        }
    }
}


