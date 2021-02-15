//
//  ViewController.swift
//  coreData
//
//  Created by MAC on 13/02/21.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var names:[String] = []
    var people:[NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "The List"
        tableSetup()
    }

    func tableSetup(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorColor = .white
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
    }

    @IBAction func addName(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (UIAlertAction) in
            guard let textfield = alert.textFields?.first,let nameToSave = textfield.text else{
                return
            }
            self.save(name: nameToSave)
            self.tableView.reloadData()
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    func save(name:String){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let mangedContact = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: mangedContact)
        
        let person = NSManagedObject(entity: entity!, insertInto: mangedContact)
        
        person.setValue(name, forKey: "name")
        
        do{
            try mangedContact.save()
            people.append(person)
        }catch let error as NSError{
            print("Could not save. \(error),\(error.userInfo)")
        }
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedcontext = appdelegate.persistentContainer.viewContext
        
        let fatchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        do{
            people = try managedcontext.fetch(fatchRequest)
        }catch let error as NSError{
            print("could not fatch.\(error), \(error.userInfo)")
        }
    }
}

extension ViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let person = people[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        
        cell.txtLbl.text = person.value(forKey: "name") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedcontext = appdelegate.persistentContainer.viewContext
           let person = people[indexPath.row]
           if editingStyle == .delete {
            managedcontext.delete(person as NSManagedObject)
               people.remove(at: indexPath.row)
               do {
                   try managedcontext.save()
               } catch
               let error as NSError {
                   print("Could not save. \(error),\(error.userInfo)")
               }
               self.tableView.deleteRows(at: [indexPath], with: .fade)
           }
    }
    
}
