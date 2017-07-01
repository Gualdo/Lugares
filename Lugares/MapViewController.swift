//
//  MapViewController.swift
//  Lugares
//
//  Created by Eduardo De La Cruz on 8/5/17.
//  Copyright © 2017 Eduardo De La Cruz. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController
{
    
    var place : Place!
    
    override var prefersStatusBarHidden: Bool {return true} // Oculta la barra de estado de bateria operador etc etc
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.mapView.delegate = self // Hcemos que nostros mismo seamos el delegado
        
        self.mapView.showsTraffic = true
        self.mapView.showsScale = true
        self.mapView.showsCompass = true
        
        print("El mapa debe mostrar " + place.name)
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(place.location)
        { [unowned self] (placemarks, error) in
            if error == nil
            {
                //Procesar los posible lugares y devuelve coordenadas de log y lat
                for placemark in placemarks!
                {
                    let annotation = MKPointAnnotation() // Creacion de una chincheta vacia
                    
                    annotation.title = self.place.name // Se le coloca nombre a la chincheta que va a aparecer en el mapa
                    annotation.subtitle = self.place.type
                    annotation.coordinate = (placemark.location?.coordinate)! // Se le dan las coordendas en las que tiene que aparecer la chincheta en el mapa
                    
                    self.mapView.showAnnotations([annotation], animated: true)
                    self.mapView.selectAnnotation(annotation, animated: true)
                }
            }
            else
            {
                print("Ha habido un error: \(String(describing: error?.localizedDescription))")
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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

extension MapViewController : MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? // Delegado para modificar los mapview
    {
        let identifier = "MyPin"
        
        if annotation.isKind(of: MKUserLocation.self)
        {
            return nil
        }
        
        var annotationView : MKPinAnnotationView? = self.mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil
        {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        }
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 52, height: 52))
        imageView.image = UIImage(data: self.place.image! as Data)
        annotationView?.leftCalloutAccessoryView = imageView
        
        annotationView?.pinTintColor = UIColor.green
        
        return annotationView
    }
}
