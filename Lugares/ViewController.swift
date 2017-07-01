//
//  ViewController.swift
//  Lugares
//
//  Created by Eduardo De La Cruz on 24/4/17.
//  Copyright © 2017 Eduardo De La Cruz. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController // Tambien se puede hacer dejando el UIViewController dejando el view controller en la vista y agregando UITableViewDataSource y UITableViewDelegate
{
    //MARK: - Global variables and constants
    
    override var prefersStatusBarHidden: Bool {return true} // Oculta la barra de estado, operador bateria etc etc
    var places : [Place] = []
    var searchResults : [Place] = []
    var fetchResultsController : NSFetchedResultsController<Place>!
    var searchController: UISearchController! // Variable para barra de busqueda con ! porque se va a crear justo en el viewDidLoad por lo que no hay pete
    
    //MARK: - Predefined methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil) // Modifica el boton de retorno a la vista principal que se encuentra en la barra de navegacion
        
        self.searchController = UISearchController(searchResultsController: nil) //Se inicializa la barra de busqueda diciendole con el nil que es nuestro propio ViewController el que la va a tener no tenemos que crear otro porque la tabla que tenemos esta muy guapo y bien disenado
        self.tableView.tableHeaderView = self.searchController.searchBar // Le estamos diciendo donde se coloca en la vista en este caso en la cabecera
        self.searchController.searchResultsUpdater = self // Asigna a la case actual que sea quien va a sobreescribir los metodos del delegado del UISarchResultsController implementa los metdos del delegado
        self.searchController.dimsBackgroundDuringPresentation = false // Controla el contenido que se difumina durante la busqueda en falso no hace transicion rara
        self.searchController.searchBar.placeholder = "Buscar lugares..."
        self.searchController.searchBar.tintColor = UIColor.white // Texto de la barra de busqueda en este caso se puso blanca
        self.searchController.searchBar.barTintColor = UIColor.darkGray // Color de fondo de la barra puesta en gris oscuro
        
        let fetchRequest : NSFetchRequest<Place> = NSFetchRequest(entityName: "Place")
        let sortDescriptor =  NSSortDescriptor(key: "name", ascending: true) // Ordenar la info
        
        fetchRequest.sortDescriptors = [sortDescriptor] // Se le eplica los ordenamientos deseados ya que .sortDescriptors es un array de odenaciones en este caso solo solicitamos 1
        
        if let container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
        {
            let context = container.viewContext
            
            self.fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil) // Peticion de un contexto, fetchRequest: Objeto que quiero trakear que quiero estar al tanto de ellos, Contexto es el que acabo de recuperar del delegado, y los demas no se necesitan porque son para hacer mas eficiente una busqueda en caso de tener muchos datos o si vienen de iCloud
            
            self.fetchResultsController.delegate = self //Se le asigna el delegado al controlador que somos nosotros mismos
            
            do
            {
                try fetchResultsController.performFetch() // Que intente hacer la actualizacion
                self.places = fetchResultsController.fetchedObjects! // En caso que la actualizacion sea correcta se le meta al array de lugares para ser mostrados y tiene ! ya que esta aqui o se fue al catch por un erro o fue exitoso
                
                let defaults = UserDefaults.standard
                
                if !defaults.bool(forKey: "hasLoadedDefaultInfo") // Determina si el usuario ha ingresado algun dato antes, si no crea los defaults
                {
                    self.loadDefaultData()
                    defaults.set(true, forKey: "hasLoadedDefaultInfo")
                }
            }
            catch
            {
                print("Error: \(error)")
            }
        }
        
        /*if let container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
        {
            let context = container.viewContext
            
            let request : NSFetchRequest<Place> = NSFetchRequest(entityName: "Place") //Se hace una peticion para recuperar la entidad Place, Se le indica que tipo de objeto va a recuperar en este caso objetos de tipo Place
            //let request : NSFetchRequest<Place> = Place.fetchRequest() // No se utiliza este ya que como se hizo la Clase no se ha autogenerado un objeto de Tipo NSFetchRequest se ha adaptdo, se utiliza cuando de la propia clase se crea una subclase con las opciones de xcode
            
            do
            {
                self.places = try context.fetch(request) // Se recupero el array de places
            }
            catch
            {
                print("Error: \(error)")
            }
        }*/ // Forma que funciona pero es mas arcaica
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated) // Se debe llamar para invocar al super antes de empezar a modificar
        
        navigationController?.hidesBarsOnSwipe = true // Hace que al hacer swipe la barra de navegacion desaparezca
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        let defaults = UserDefaults.standard
        let hasViewedTutorial = defaults.bool(forKey: "hasViewedTutorial")
        
        if hasViewedTutorial
        {
            return // Se acaba la ejecucion del metodo por lo que no muestra el tutorial
        }
        
        if let pageVC = storyboard?.instantiateViewController(withIdentifier: "WalkthroughController") as? TutorialPageViewController // Nos permite mostrar cuando aparezca la vista el tutorial
        {
            self.present(pageVC, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UITableViewDataSource methods
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if self.searchController.isActive
        {
            return self.searchResults.count // En el caso de que se este haciendo una busqueda de lugares la cantidad de rows dependera de cuantos hits haya
        }
        else
        {
            return self.places.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let place : Place!
        
        if self.searchController.isActive
        {
            place = self.searchResults[indexPath.row] // En el caso de que se este haciendo una busqueda de lugares la row es la que aparezca en la busqueda
        }
        else
        {
            place = self.places[indexPath.row]
        }
        
        let cellID = "PlaceCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! PlaceCell
        
        cell.thumbnailImageView.image = UIImage(data: place.image! as Data)
        cell.nameLabel.text = place.name
        cell.timeLabel.text = place.type
        cell.ingredientsLabel.text = place.location
        
        /*if place.isFavorite
        {
            cell.accessoryType = .checkmark
        }
        else
        {
            cell.accessoryType = .none
        }*/
        
        /*cell.thumbnailImageView.layer.cornerRadius = 34 // Hace la imagen circular con el radio dado
         cell.thumbnailImageView.clipsToBounds = true // Corta todo lo que queda fuera del circulo que creamos antes en el caso de este ejemplo lo hicimos desde el Main.Storyboard por eso esta comentado*/
        
        return cell
    }
    
    /*override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) // Funcion que habilita el deslizado a la izquierda para poder borrar etc
    {
        if editingStyle == .delete // Ya que la funcion permite borrar, agregar o no hacer nada hacemos este if para programar el borrado
        {
            self.places.remove(at: indexPath.row) // Hace que se borre la receta del modelo (array) pero falta hacer que se actualize la vista para que no pete
        }
        
        self.tableView.deleteRows(at: [indexPath], with: .fade) // Actualiza la vista eliminando con la animacion fade la receta que se esta borrando sin tener que recargar toda la vista en caso de terner 10000000000 recetas que en caso de usar el reloadData() seria ineficiente
    }*/
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? // Metodo para modificar las opciones que aparecen al deslizar a la izquierda uno de los row
    {
        //Accion Compartir
        
        let shareAction = UITableViewRowAction(style: .default, title: "Compartir")
        { (action, indexPath) in
            
            let place : Place!
            
            if self.searchController.isActive
            {
                place = self.searchResults[indexPath.row] // En el caso de que se este haciendo una busqueda de lugares la row es la que aparezca en la busqueda
            }
            else
            {
                place = self.places[indexPath.row]
            }
            
            let shareDefaulText = "Estoy visitando \(place.name) en la app del curso de iOS 10 con Juan Gabriel"
            
            let activityController = UIActivityViewController(activityItems: [shareDefaulText , place.image!], applicationActivities: nil)
            
            self.present(activityController, animated: true, completion: nil)
        }
        
        shareAction.backgroundColor = UIColor(red: 30.0/255.0, green: 164.0/255.0, blue: 253.0/255, alpha: 1.0) // Cambia el color de fondo de la opcion compartir
        
        // Accion Borrar
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Borrar")
        { (action, indexPath) in
            if let container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
            {
                let context = container.viewContext // Obtenemos el contexto del container de Core Data
                let placeToDelete = self.fetchResultsController.object(at: indexPath) // Obtenemos el lugar a borrar
                
                context.delete(placeToDelete) // Se borra a nivel de memoria el que queremos
                
                do
                {
                    try context.save() // Salvamos el contexto para que se actualize la base de datos y se termine el proceso de borrado
                }
                catch
                {
                    print("Error \(error)")
                }
            }
        }
        
        deleteAction.backgroundColor = UIColor(red: 202.0/255.0, green: 202.0/255.0, blue: 202.0/255.0, alpha: 1.0) // Cambia el color de fondo de la opcion borrar
        
        // Accion Favorito
        
        let favouriteAction = UITableViewRowAction(style: .default, title: "Favorito")
        { (action, indexPath) in
            let place = self.places[indexPath.row]
            
            let alertController = UIAlertController(title: place.name , message: "Valora este plato" , preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        favouriteAction.backgroundColor = UIColor(red: 30.0/255.0, green: 253.0/255.0, blue:100.0/255.0, alpha: 1.0) // Cambia el color de fondo de la opcion favorito
        
        return [shareAction , favouriteAction , deleteAction]
    }
    
    //MARK: - Custom Methods
    
    func filterContentFor(textToSearch: String)
    {
        self.searchResults = self.places.filter({ (place) -> Bool in // Del array de lugares filtro poara cada uno de esos lugares
            let nameToFind = place.name.range(of: textToSearch, options: NSString.CompareOptions.caseInsensitive) // Me quedo con el nombre a buscar y si contiene el rango del texto a buscar de forma que no le importen las mayusculas o minusculas
            return nameToFind != nil // Si no encuentra nada segun las condiciones exigidas el nameToFind va a ser nul por lo que al compararlo con el nameToFind != nil se devuelve false, si NO es nulo se devuelve el resultado
        })
    }
    
    func loadDefaultData()
    {
        let names = ["Alexanderplatz", "Atomium" , "Big Ben" , "Cristo Redentor", "Torre Eiffel", "Gran Muralla", "Torre de Pisa", "La Seu de Mallorca"]
        let types = ["Plaza", "Museo" , "Monumento" , "Monumento", "Monumento", "Monumento", "Monumento", "Catedral"]
        let locations = ["Alexanderstraße 4 10178 Berlin Deutschland", "Atomiumsquare 1 1020 Brussels Belgium", "London SW1A 0AA England", "Cristo Redentor João Pessoa - PB Brasil", "5 Avenue Anatole France 75007 Paris France", "Great Wall, Mutianyu Beijing China", "Leaning Tower of Pisa 56126 Pisa, Province of Pisa Italy", "La Seu Plaza de la Seu 5 07001 Palma Baleares, España"]
        let telephones = ["+34902022445", "+34902022445", "+34902022445", "+34902022445", "+34902022445", "+34902022445", "+34902022445", "+34902022445"]
        let websites = ["https://www.disfrutaberlin.com/alexanderplatz", "http://atomium.be", "http://www.parliament.uk/bigben", "http://imaginariodejaneiro.com/10-curiosidades-sobre-la-estatua-del-cristo-redentor/", "http://www.toureiffel.paris/es/", "http://www.nationalgeographic.com.es/historia/grandes-reportajes/la-gran-muralla-china_8272", "http://www.vivetoscana.com/la-torre-de-pisa-historia-y-curiosidades-de-uno-de-los-monumentos-mas-famosos-de-toscana/", "http://catedraldemallorca.org"]
        let images = [#imageLiteral(resourceName: "alexanderplatz"), #imageLiteral(resourceName: "atomium"), #imageLiteral(resourceName: "bigben"), #imageLiteral(resourceName: "cristoredentor"), #imageLiteral(resourceName: "torreeiffel"), #imageLiteral(resourceName: "murallachina"), #imageLiteral(resourceName: "torrepisa"), #imageLiteral(resourceName: "mallorca")]
        
        if let container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer // Consigue el container del AppDelegeta, UIApplication: Se utiliza para acceder a datos especificos de la app, .shared: poque es una instancia compartida por todas las App, al finas casteado como AppDelegate y del Delegado sacamos el container
        {
            let context = container.viewContext // El context de la vista es quien se encarga de almacenar los datos directamente de Core Data
            
            for i in 0..<names.count
            {
                let place = NSEntityDescription.insertNewObject(forEntityName: "Place", into: context) as? Place // Insertar un nuevo objeto dentro de la Entidad Place
                
                place?.name = names[i]
                place?.type = types[i]
                place?.location = locations[i]
                place?.telephone = telephones[i]
                place?.website = websites[i]
                place?.rating = "rating"
                place?.image = UIImagePNGRepresentation(images[i])! as NSData // Transforma un objeto de timpo imagen a tipo NSData
            }
            
            do
            {
                try context.save()
            }
            catch
            {
                print("Ha habido un error al guardar el lugar en Core Data")
            }
        }
    }
    
    //MARK: - UITableViewDelegate methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showDetail"
        {
            if let indexPath = self.tableView.indexPathForSelectedRow
            {
                let selectedPlace : Place!
                
                if self.searchController.isActive
                {
                    selectedPlace = self.searchResults[indexPath.row] // En el caso de que se este haciendo una busqueda de lugares la row es la que aparezca en la busqueda
                    searchController.isActive = false // Hace que se quite la barra de busqueda al selaccionar el lugar encontrado
                }
                else
                {
                    selectedPlace = self.places[indexPath.row]
                }              
                
                let destinationViewController = segue.destination as! DetailViewController
                
                destinationViewController.place = selectedPlace
                
                destinationViewController.hidesBottomBarWhenPushed = true // Oculta la barra inferior de pestanas
            }
        }
    }
    
    // MARK: - Navigation
    
    @IBAction func unwindToMainViewController(segue: UIStoryboardSegue)
    {
        /*if segue.identifier == "unwindToMainViewController"
        {
            /*if let addPlaceVC = segue.source as? AddPlaceViewController
            {
                if let newPlace = addPlaceVC.place
                {
                    self.places.append(newPlace)
                }
            }*/
        }*/
    }
}

extension ViewController : NSFetchedResultsControllerDelegate
{
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) // Cuando el contexto cambia entramos en modo edicion o sea que la tableView pueede cambiar
    {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) // Ha cambiado algun objeto con tipo de cambio, cual cambio y la ubicacion en el indexPath
    {
        switch type
        {
            case .insert:
                if let newIndexPath = newIndexPath
                {
                    self.tableView.insertRows(at: [newIndexPath], with: .fade)
                }
            case .delete:
                if let indexPath = indexPath
                {
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            case .update:
                if let indexPath = indexPath
                {
                    self.tableView.reloadRows(at: [indexPath], with: .fade)
                }
            case .move:
                if let indexPath = indexPath, let newIndexPath = newIndexPath
                {
                    self.tableView.moveRow(at: indexPath, to: newIndexPath)
                }
        }
        
        self.places = controller.fetchedObjects as! [Place]
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) // Finaliza el modo edicion
    {
        self.tableView.endUpdates()
    }
}

extension ViewController : UISearchResultsUpdating
{
    func updateSearchResults(for searchController: UISearchController) // Se llama cuando hay un cambio en el searchController
    {
        if let searchText = searchController.searchBar.text // Nos quedamos con el texto que ha cambiado en la searchBar
        {
            self.filterContentFor(textToSearch: searchText) // Se filtra el contenido que nos acaba de llegar
            self.tableView.reloadData() // Se recarga la tabla pero hay condiciones que tener en cuenta ya que en este momento se recarga TODA la table y queremos que se muestre solo los que acabamos de filtrar
        }
    }
}
