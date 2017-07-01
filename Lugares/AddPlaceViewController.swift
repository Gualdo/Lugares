//
//  AddPlaceViewController.swift
//  Lugares
//
//  Created by Eduardo De La Cruz on 25/5/17.
//  Copyright © 2017 Eduardo De La Cruz. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class AddPlaceViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate
{
    override var prefersStatusBarHidden: Bool {return true} // Oculta la barra de estado de bateria operador etc etc
    
    // MARK: - IBOutlets

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var textfieldName: UITextField!
    @IBOutlet var textfieldType: UITextField!
    @IBOutlet var textfieldAdress: UITextField!
    @IBOutlet var textfieldTelephone: UITextField!
    @IBOutlet var textfieldWebsite: UITextField!
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    // MARK: - Global Variables / Constants
    
    var rating : String?
    var place : Place?
    let defaultColor = UIColor(red: 236.0/255.0, green: 134.0/255.0, blue: 144.0/255.0, alpha: 1.0)
    let selectedColor = UIColor.red
    
    // MARK: - Predefined Init
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.textfieldName.delegate = self
        self.textfieldType.delegate = self
        self.textfieldAdress.delegate = self
        self.textfieldTelephone.delegate = self
        self.textfieldWebsite.delegate = self
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBActions
    
    @IBAction func ratingPressed(_ sender: UIButton)
    {
        switch sender.tag
        {
            case 1:
                self.rating = "dislike"
                self.button1.backgroundColor = selectedColor
                self.button2.backgroundColor = defaultColor
                self.button3.backgroundColor = defaultColor
            case 2:
                self.rating = "good"
                self.button1.backgroundColor = defaultColor
                self.button2.backgroundColor = selectedColor
                self.button3.backgroundColor = defaultColor
            case 3:
                self.rating = "great"
                self.button1.backgroundColor = defaultColor
                self.button2.backgroundColor = defaultColor
                self.button3.backgroundColor = selectedColor
            default:
                break
        }
    }
    
    @IBAction func savePressed(_ sender: UIBarButtonItem)
    {
        if let name = self.textfieldName.text,
               let type = self.textfieldType.text,
               let adress = self.textfieldAdress.text,
               let telephone = textfieldTelephone.text,
               let website = textfieldWebsite.text,
               let theImage = self.imageView.image,
               let rating = self.rating
        {
            if let container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer // Consigue el container del AppDelegeta, UIApplication: Se utiliza para acceder a datos especificos de la app, .shared: poque es una instancia compartida por todas las App, al finas casteado como AppDelegate y del Delegado sacamos el container
            {
                let context = container.viewContext // El context de la vista es quien se encarga de almacenar los datos directamente de Core Data
                
                self.place = NSEntityDescription.insertNewObject(forEntityName: "Place", into: context) as? Place // Insertar un nuevo objeto dentro de la Entidad Place
                
                self.place?.name = name
                self.place?.type = type
                self.place?.location = adress
                self.place?.telephone = telephone
                self.place?.website = website
                self.place?.rating = rating
                self.place?.image = UIImagePNGRepresentation(theImage) as NSData? // Transforma un objeto de timpo imagen a tipo NSData
                
                self.savePlaceToIcloud(place: self.place) // Para subir a la nube
                
                do
                {
                    try context.save()
                }
                catch
                {
                    print("Ha habido un error al guardar el lugar en Core Data")
                }
            }
            
            self.performSegue(withIdentifier: "unwindToMainViewController", sender: self) // Hace que al crearse el lugar se devuelva a la pantalla principal            
        }
        else
        {
            let alertController = UIAlertController(title: "Falta algun dato", message: "Revisa que lo tengas todo relleno", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Custom Function
    
    func getDocumentsDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        return documentsDirectory
    }
    
    func savePlaceToIcloud(place: Place!)
    {
        let record = CKRecord(recordType: "Place")
        
        record.setValue(place.name, forKey: "name")
        record.setValue(place.type, forKey: "type")
        record.setValue(place.location, forKey: "location")
        record.setValue(place.telephone, forKey: "telephone")
        record.setValue(place.website, forKey: "website")
        
        let originalImage = UIImage(data: place.image! as Data)!
        let scaleFactor = (originalImage.size.width > 1024) ? 1024/originalImage.size.width : 1.0 // Condicion ternaria que traduce: if originalImge.size.width > 1024 ejecuta 1024/originalImage.size.with else ejecuta 1.0
        let scaledImage = UIImage(data: place.image! as Data, scale: scaleFactor)
        
        do
        {
            let imagePath = self.getDocumentsDirectory().appendingPathComponent(place.name)
            
            if let imageJPEG = UIImageJPEGRepresentation(scaledImage!, 0.8)
            {
                try imageJPEG.write(to: imagePath , options: [.atomicWrite])
            }
            
            let imageAsset = CKAsset(fileURL: imagePath)
            
            record.setValue(imageAsset, forKey: "image")
            
            let publicDB = CKContainer.default().publicCloudDatabase
            
            publicDB.save(record)
            { (record, error) in
                if error != nil
                {
                    print(error as Any)
                }
                
                do
                {
                    try FileManager.default.removeItem(at: imagePath)
                }
                catch
                {
                    print("Hemos fallado al guardar el objeto en iCloid")
                }
            }
        }
        catch
        {
            print("Error al guardar la imagen")
        }      
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if indexPath.row == 0
        {
            // Hay que gestionar la seleccion de la imagen del lugar
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) // Si esta disponible la opcion la libreria de photos
            {
                let imagePicker = UIImagePickerController()
                
                imagePicker.allowsEditing = false // No dejo al usuario editar
                imagePicker.sourceType = .photoLibrary // El tipo es la biblioteca de fotos del usuario
                imagePicker.delegate = self // Asignamos que nosotros mismo somos el delegado
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true) // Una vez que el usuario ha hecho click se deselecciona para que no quede preseleccionada por estetica
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        self.imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.imageView.contentMode = .scaleAspectFill // Hace que la imagen ocupe todo el espacio
        self.imageView.clipsToBounds = true // Recorta los bordes para mejor estetica
        
        let leadingConstraint = NSLayoutConstraint(item: self.imageView, attribute: .leading, relatedBy: .equal, toItem: self.imageView.superview, attribute: .leading, multiplier: 1, constant: 0) // Restriccion de la ImageView de modo que el borde izquierdo sea de 0 comparado con la vista que lo contiene
        
        leadingConstraint.isActive = true // Hace que funcione el Contraint
        
        let trailingConstraint = NSLayoutConstraint(item: self.imageView, attribute: .trailing, relatedBy: .equal, toItem: self.imageView.superview, attribute: .trailing, multiplier: 1, constant: 0)
        
        trailingConstraint.isActive = true
        
        let topConstraint = NSLayoutConstraint(item: self.imageView, attribute: .top, relatedBy: .equal, toItem: self.imageView.superview, attribute: .top, multiplier: 1, constant: 0)
        
        topConstraint.isActive = true
        
        let bottomConstraint = NSLayoutConstraint(item: self.imageView, attribute: .bottom, relatedBy: .equal, toItem: self.imageView.superview, attribute: .bottom, multiplier: 1, constant: 0)
        
        bottomConstraint.isActive = true
        
        dismiss(animated: true, completion: nil) // Oculta el ViewController de las imgenes, asigna la imagen que selecciono el usuario con el picker al ImageView
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // Al darle al enter nos esconde el teclado
    {
        textField.resignFirstResponder()
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
