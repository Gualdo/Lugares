//
//  ReviewViewController.swift
//  MisRecetas
//
//  Created by Eduardo D De La Cruz Marr on 23/2/17.
//  Copyright © 2017 Eduardo D De La Cruz Marrero. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController
{
    //MARK: - Global Variables
    
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var ratingStackView: UIStackView!
    @IBOutlet var firstButton: UIButton!
    @IBOutlet var secondButton: UIButton!
    @IBOutlet var thirdButton: UIButton!
    
    var ratingSelected : String?
    
    var place : Place!
    
    override var prefersStatusBarHidden: Bool {return true} // Oculta la barra de estado, operador bateria etc etc
    
    //MARK: - Predefined methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        let blurEffect = UIBlurEffect(style: .dark) // Crea un efecto de blur
        
        let blurEffectView = UIVisualEffectView(effect: blurEffect) // Asigna el efecto de blur a la vista del efecto
        
        blurEffectView.frame = view.bounds // Hace que el efecto de difuminado sea del tamaño completo de la pantalla
        
        backgroundImageView.image = UIImage(data: place.image! as Data) // Asigna al ImageView de la vista la imagen del lugar que viene del segue
        
        backgroundImageView.addSubview(blurEffectView) // Se coloca el efecto de difuminado SOBRE la vista
        
        let scale = CGAffineTransform(scaleX: 0.0, y: 0.0) // Hace que el StackView sea de tamaño 0, al principio no aparecera
        
        let translation = CGAffineTransform(translationX: 0.0, y: 500.0)
        
        // ratingStackView.transform = scale.concatenating(translation) // Combinar escalado con translacion
        
        self.firstButton.transform = scale.concatenating(translation) // Combinar escalado con translacion
        
        self.secondButton.transform = scale.concatenating(translation) // Combinar escalado con translacion
        
        self.thirdButton.transform = scale.concatenating(translation) // Combinar escalado con translacion
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
       /* UIView.animate(withDuration: 0.5, delay: 0.0, options: [],
                       animations:
                       {
                            self.ratingStackView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                       },
                       completion: nil) // Con este metodo se hace la llamada TRANSFORMACION AFIN para pasar de tamaño 0 definido arriba a el tamaño original
        */
        /*UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: [], //Damping es el peso del objeto mientras > menos rebota y velocity es la velocidad del rebote
                       animations:
                       {
                            self.ratingStackView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                       },
                       completion: nil) // Metodo para hacer que el StackView aparezca rebotando en la pantalla*/
        
        UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: [],
                       animations:
                       {
                            self.firstButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                       })
                       { (success) in // Complete usado para llevar a cabo la animacion del segundo boton
                            UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: [],
                                           animations:
                                           {
                                                self.secondButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                           })
                                           { (success) in // Complete usado para llevar a cabo la animacion del tercer boton
                                                UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: [],
                                                               animations:
                                                               {
                                                                    self.thirdButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                                               },
                                                               completion: nil) // Complete en nil ya que no hay que hacer nada mas
                                           }
                       }
        
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ratingPressed(_ sender: UIButton)
    {
        switch sender.tag // Luego de colocarle a cada uno de los botones un tag en el StoryBoard y colnectar los 3 a este mismo Action se valida la info segun cada uno de ellos
        {
            case 1:
                ratingSelected = "dislike"
            case 2:
                ratingSelected = "good"
            case 3:
                ratingSelected = "great"
            default:
                break
        }
        
        performSegue(withIdentifier: "unwindToDetailView", sender: sender) // Se forza un segue para atras
    }
}
