//
//  TutorialPageViewController.swift
//  Lugares
//
//  Created by Eduardo De La Cruz on 8/6/17.
//  Copyright © 2017 Eduardo De La Cruz. All rights reserved.
//

import UIKit

class TutorialPageViewController: UIPageViewController
{
    // MARK: - Global Variables
    
    override var prefersStatusBarHidden: Bool {return true} // Oculta la barra de estado, operador bateria etc etc
    var tutorialSteps : [TutorialStep] = []
    
    // MARK: - Predefined Init
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let firstStep = TutorialStep(index: 0, heading: "Personaliza", content: "Crea nuevos lugares, sube imagenes y ubicalos con solo unos pocos segundos", image: #imageLiteral(resourceName: "tuto-intro-1"))
        self.tutorialSteps.append(firstStep)
        
        let secondStep = TutorialStep(index: 1, heading: "Encuentra", content: "Ubica y encuentra tus lugares favoritos a traves del mapa", image: #imageLiteral(resourceName: "tuto-intro-2"))
        self.tutorialSteps.append(secondStep)
        
        let thirdStep = TutorialStep(index: 2, heading: "Descubre", content: "Descubre lugares increibles cerca de ti y compartelos con tus amigos", image: #imageLiteral(resourceName: "tuto-intro-3"))
        self.tutorialSteps.append(thirdStep)
        
        dataSource = self // Definimos que el dataSourse del UIPageViewController somos nosotros mismos
        
        if let startVC = self.pageViewController(atIndex: 0) // Indicamos quien va a ser el primero de todos ellos
        {
            setViewControllers([startVC], direction: .forward, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func forward(toIndex: Int)
    {
        if let nextVC = self.pageViewController(atIndex: toIndex + 1)
        {
            self.setViewControllers([nextVC], direction: .forward, animated: true, completion: nil)
        }
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

// MARK: - Extensions

extension TutorialPageViewController : UIPageViewControllerDataSource
{
    // Configuracion de la pagina que viene despues de la actual
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! TutorialContentViewController).tutorialStep.index
        index += 1
        
        return self.pageViewController(atIndex: index)
    }
    
    // Configuracion de la pagina que viene antes de la actual
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! TutorialContentViewController).tutorialStep.index
        index -= 1
        
        return self.pageViewController(atIndex: index)
    }
    
    // Validacion de existencia de pagina siguiente o anterior o define el pageContentViewController y asignarle el TutrialStep que le corresponde
    func pageViewController(atIndex: Int) -> TutorialContentViewController?
    {
        if atIndex == NSNotFound || atIndex < 0 || atIndex >= self.tutorialSteps.count
        {
            return nil
        }
        
        if let pageContetViewController = storyboard?.instantiateViewController(withIdentifier: "WalkthroughPageContent") as? TutorialContentViewController
        {
            pageContetViewController.tutorialStep = self.tutorialSteps[atIndex]
            
            return pageContetViewController
        }
        
        return nil
    }
    
    /*func presentationCount(for pageViewController: UIPageViewController) -> Int // Pinta el numero de bolitas segun la cantidad de paginas que tenga el tutorial, formato por defecto
    {
        return self.tutorialSteps.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int // Enciende la bolita indicada de marcador de pagina del tutorial, formato por defecto
    {
        if let pageContentVC = storyboard?.instantiateViewController(withIdentifier: "WalkthroughPageContent") as? TutorialContentViewController
        {
            if let tutorialStep = pageContentVC.tutorialStep
            {
                return tutorialStep.index
            }
            
        }
        
        return 0
    }*/
}
