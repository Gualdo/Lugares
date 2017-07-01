//
//  DetailViewController.swift
//  MisRecetas
//
//  Created by Eduardo D De La Cruz Marr on 20/2/17.
//  Copyright © 2017 Eduardo D De La Cruz Marrero. All rights reserved.
//

import UIKit
import MessageUI

class DetailViewController: UIViewController
{
    //MARK: - Global variables and constants
    
    @IBOutlet var placeImageView: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var ratingButton: UIButton!
    
    var place : Place!
    
    override var prefersStatusBarHidden: Bool {return true} // Oculta la barra de estado de bateria operador etc etc
    
    //MARK: - Predefined methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = place.name // Coloca en la barra de navegacion el nombre de la receta
        
        self.placeImageView.image = UIImage(data: self.place.image! as Data)
        
        self.tableView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.25) // Cambia el color del fondo de cada una de las celdas
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero) // Hace que despues de la ultima celda modificada por nosotros no aparezca nada mas ninguno otra celda vacia.
        
        self.tableView.separatorColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.75) // Cambia el color de las divisiones entre cada una de las Row
        
        self.tableView.estimatedRowHeight = 44.0 // Se le da la altura que estimamos que va a tener la fila
        
        self.tableView.rowHeight = UITableViewAutomaticDimension // Se le dice a xcode que dimensiona automaticamente la fila segun la medida que colocamos arriba, con estas dos lineas de codigo hacemos las filas autoescalables y se ajuste a su contenido dinamicamente
        
        self.ratingButton.setImage(UIImage(named: self.place.rating!), for: .normal) // Coloca la imagen que le corresponde al boton de valoracion
    }
    
    override func viewWillAppear(_ animated: Bool) // Semejante al viewDidLoad pero en vez de llamarse solo cuando se carga la vista se llama cada vez que la vista aparezca
    {
        super.viewWillAppear(animated) // Se llama al super
        navigationController?.hidesBarsOnSwipe = false // Hace que no se oculte la barra
        navigationController?.setNavigationBarHidden(false, animated: true) // Si la barra estaba oculta hace que aparezca
    }    
    
    @IBAction func close(segue: UIStoryboardSegue) // Este es el unwind Segue del ReviewViewController
    {
        if let reviewVC = segue.source as? ReviewViewController
        {
            if let rating = reviewVC.ratingSelected
            {
                self.place.rating = rating // Guarda el nombre de la imagen que corresponde al boton de valoracion de ese lugar
                let image = UIImage(named: self.place.rating!)
                // Forma de hacerlo sin declarar lo que tengo justo arriba self.ratingButton.setImage(UIImage(named: self.place.rating!), for: .normal) // Coloca la imagen que le corresponde al boton de valoracion
                self.ratingButton.setImage(image, for: .normal) // Coloca la imagen que le corresponde al boton de valoracion
                
                if let container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
                {
                    let context = container.viewContext
                    
                    do
                    {
                        try context.save()
                    }
                    catch
                    {
                        print("Error: \(error)")
                    }
                }
            }
        }
    }
    
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
     
    }*/
}

//MARK: - UITableViewDataSource methods

extension DetailViewController : UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceDetailViewCell", for: indexPath) as! PlaceDetailViewCell
        
        cell.backgroundColor = UIColor.clear
        
        
        switch indexPath.row // Switch para el row elegido
        {
            case 0:
                cell.keyLabel.text = "Nombre:"
                cell.valueLabel.text = self.place.name
            case 1:
                cell.keyLabel.text = "Tipo:"
                cell.valueLabel.text = "\(self.place.type)"
            case 2:
                cell.keyLabel.text = "Localizacion: "
                cell.valueLabel.text = self.place.location
            case 3:
                cell.keyLabel.text = "Telefono"
                cell.valueLabel.text = self.place.telephone
            case 4:
                cell.keyLabel.text = "Web"
                cell.valueLabel.text = self.place.website
            default:
                break
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate methods

extension DetailViewController : UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch indexPath.row
        {
            case 2:
                //Hemos seleccionado la geolocalizacion
                self.performSegue(withIdentifier: "showMap", sender: nil) // Pasa del ViewController actual al nuevo que es showMap
            
            case 3:
                //Llamar o mandar SMS al lugar en cuestion
                
                let alertController = UIAlertController(title: "Contactar con \(self.place.name)", message: "Como quieres contactar con el numero \(String(describing: self.place.telephone!))?", preferredStyle: .actionSheet)
            
                let callAction = UIAlertAction(title: "Llamar", style: .default, handler: { (action) in
                    // Logica de llamar a un telefono, no corre en simulador, la llamada es una URL asi se maneja
                    
                    if let phoneURL = URL(string: "tel://\(self.place.telephone!)") // Si me deja contruir esta URL es que realmente hay un telefono asignado al lugar tel es por defecto para decir que es una llamada al dispositivo
                    {
                        let app = UIApplication.shared // Devuelve las app que comparten en este caso la nuestra para que app pueda ejecutar metodos
                        if app.canOpenURL(phoneURL)
                        {
                            app.open(phoneURL, options: [:], completionHandler: nil)
                        }
                    }
                })
            
                alertController.addAction(callAction)
            
                let smsAction = UIAlertAction(title: "Mensaje", style: .default, handler: { (action) in
                    // Logica de mandar un SMS
                    
                    if MFMessageComposeViewController.canSendText()
                    {
                        let msg = "Hola desde la app de Lugares creado con Juan Gabriel en iOS 10."
                        let msgVC = MFMessageComposeViewController()
                        
                        msgVC.body = msg
                        msgVC.recipients = [self.place.telephone!]
                        msgVC.messageComposeDelegate = self
                        
                        self.present(msgVC, animated: true, completion: nil)
                    }
                })
            
                alertController.addAction(smsAction)
            
                let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
            
                alertController.addAction(cancelAction)
            
                self.present(alertController, animated: true, completion: nil)
            
            case 4:
                // Logica de abrir la pagina web
            
                if let websiteURL = URL(string: self.place.website!)
                {
                    let app = UIApplication.shared // Abre en el navegador compartido por todos (Safari) Forma tipica...
                    if app.canOpenURL(websiteURL)
                    {
                        app.open(websiteURL, options: [:], completionHandler: nil)
                    }
                }
            
            default:
                break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showReview"
        {            
            let destinationViewController = segue.destination as! ReviewViewController // Crea la conexion de esta clase con la siguiente a traves del segue utilizado
                
            destinationViewController.place = place // Envia la informacion del lugar en el que nos encontramos en esta vista al controller de la siguiente vista
        }
        else if segue.identifier == "showMap"
        {
            let destinationViewController = segue.destination as! MapViewController
            
            destinationViewController.place = self.place
        }
    }
}

extension DetailViewController : MFMessageComposeViewControllerDelegate
{
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult)
    {
        controller.dismiss(animated: true, completion: nil)
        print(result)
    }
}
