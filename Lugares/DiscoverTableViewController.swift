//
//  DiscoverTableViewController.swift
//  Lugares
//
//  Created by Eduardo De La Cruz on 14/6/17.
//  Copyright © 2017 Eduardo De La Cruz. All rights reserved.
//

import UIKit
import CloudKit

class DiscoverTableViewController: UITableViewController
{
    // MARK: - IBOutlets
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    // MARK: - Global Variables
    
    var places: [CKRecord] = [] // Obejto especifico para objeto recuperados de iCloud
    var imageCache: NSCache = NSCache<CKRecordID , NSURL>()
    var lastCursor: CKQueryCursor?
    var hasLoadedInfo: Bool = false
    
    // MARK: - Predefined Init
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        spinner.hidesWhenStopped = true // Cuando el spinner se detenga por codigo inmediatamente el mismo se oculta
        spinner.center = self.view.center // Se alinea el spinner en toda la mitad del centro
        self.view.addSubview(spinner) // Se agrega el spinner (subvista) a la vista principal en la que estamos (DiscoverTableViewController)
        spinner.startAnimating() // Empieza a dar vueltas el spinner
        
        self.refreshControl = UIRefreshControl() // Con todo este grupo de codigo lo que se hace es refrescar y pedir mas lugares al halar hacia abajo al estilo correo electronico
        self.refreshControl?.tintColor = UIColor.gray
        self.refreshControl?.backgroundColor = UIColor.white
        self.refreshControl?.addTarget(self, action: #selector(DiscoverTableViewController.LoadDataFromiCloud), for: .valueChanged)
        
        self.LoadDataFromiCloud()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Custom Functions
    
    func LoadDataFromiCloud()
    {
        let iCloudContainer = CKContainer.default() // Se solicita el continer de iCloud
        let publicDB = iCloudContainer.publicCloudDatabase // Nos quedamos especificamente con la base de datos publica del container de iCloud
        let predicate = NSPredicate(value: true) // Predicado de busqueda
        let query = CKQuery(recordType: "Place", predicate: predicate) // Query para traer la info que pida el predicado en el record Place
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)] // Se utiliza para que aparezcan los items ordenados por la fecha de creacion que se coloca automaticamente en el cloud
        
        // Load with Operational API
        
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.desiredKeys = ["name"] // Trae solo el nombre de los places para que sea mas rapido, luego se cargaran las imagenes
        queryOperation.queuePriority = .veryHigh // Prioridad se coloca muy alta para que la consulta se haga rapido
        queryOperation.resultsLimit = 3 // Se piden resultados de a 3
        if self.lastCursor != nil
        {
            queryOperation.cursor = self.lastCursor
        }
        else if hasLoadedInfo
        {
            self.refreshControl?.endRefreshing()
            return
            /*self.places.removeAll() // Limpio el array de places
            self.tableView.reloadData() // Recarga la tabla*/
        }
        queryOperation.recordFetchedBlock = { (record: CKRecord?) in // Nos permite definir el bloque de recuperacion de objetos a ejecutar, cada vez que llegue un objeto de tipo place desde iCloud se ejecuta
            
            if let record = record
            {
                self.places.append(record) // Se van anadiendo uno a uno segun van llegando
            }
        }
        queryOperation.queryCompletionBlock = { [unowned self] (cursor, error) in
            
            if error != nil
            {
                print(error?.localizedDescription as Any)
                return
            }
            
            self.hasLoadedInfo = true
            self.lastCursor = cursor
            
            OperationQueue.main.addOperation({
                self.refreshControl?.endRefreshing()
                self.spinner.stopAnimating() // Se detiene el spinner antes de que se recargue la tabla
                self.tableView.reloadData()
            })
        }
        
        publicDB.add(queryOperation)
        
        /*// Load with Convenience API // No es tan eficiente ya que no permite filtrar tan especificamente por ello se usa el API Operational
        
        publicDB.perform(query, inZoneWith: nil){ (results, error) in
            
            print("Consulta de lugares completada")
            
            if error != nil
            {
                print(error?.localizedDescription as Any)
                return
            }
            
            if let results = results
            {
                self.places = results
                
                OperationQueue.main.addOperation({  // Esto lo que hace es pasar el reloadData() al hilo principal de la ejecusion
                    self.tableView.reloadData()
                })
            }
        }*/
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete implementation, return the number of rows
        return self.places.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell 
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverCell", for: indexPath)

        // Configure the cell...
        
        let place = self.places[indexPath.row]
        
        if let name = place.object(forKey: "name") as? String
        {
            cell.textLabel?.text = name
        }
        
        cell.imageView?.image = #imageLiteral(resourceName: "PlaceHolder")
        
        if let imageFileURL = self.imageCache.object(forKey: place.recordID)
        {
            print("Imagen cargada de cache")
            cell.imageView?.image = UIImage(data: NSData(contentsOf: imageFileURL as URL)! as Data)
        }
        else
        {
            let publicDB = CKContainer.default().publicCloudDatabase
            let fetchImageOperation = CKFetchRecordsOperation(recordIDs: [place.recordID])
            
            fetchImageOperation.desiredKeys = ["image"]
            fetchImageOperation.queuePriority = .veryHigh
            fetchImageOperation.perRecordCompletionBlock = { (record, recordID, error) in
                if error != nil
                {
                    print(error?.localizedDescription as Any)
                    return
                }
                
                if let record = record
                {
                    OperationQueue.main.addOperation({ // Voy al hilo principal
                        if let image = record.object(forKey: "image") as? CKAsset
                        {
                            let imageAsset = image
                            
                            self.imageCache.setObject(imageAsset.fileURL as NSURL, forKey: place.recordID)
                            
                            cell.imageView?.image = UIImage(data: NSData(contentsOf: imageAsset.fileURL)! as Data)
                        }
                    })
                }
            }
            
            publicDB.add(fetchImageOperation)
        }
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool 
    {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) 
    {
        if editingStyle == .delete 
        {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } 
        else if editingStyle == .insert 
        {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) 
    {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool 
    {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) 
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
