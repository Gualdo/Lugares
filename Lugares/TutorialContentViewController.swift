//
//  TutorialContentViewController.swift
//  Lugares
//
//  Created by Eduardo De La Cruz on 8/6/17.
//  Copyright © 2017 Eduardo De La Cruz. All rights reserved.
//

import UIKit

class TutorialContentViewController: UIViewController
{
    // MARK: - Outlets
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentImageView: UIImageView!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var nextButton: UIButton!
    
    // MARK: - Global Variables
    
    var tutorialStep : TutorialStep!
    
    // MARK: - Predefined Init
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.titleLabel.text = self.tutorialStep.heading
        self.contentImageView.image = self.tutorialStep.image
        self.contentLabel.text = self.tutorialStep.content
        self.pageControl.currentPage = self.tutorialStep.index // Hace que el punto de marcado de pagina se mueva
        
        switch self.tutorialStep.index
        {
            case 0...1:
                self.nextButton.setTitle("Siguiente", for: .normal)
            case 2:
                self.nextButton.setTitle("Emepzar", for: .normal)
            default:
                break
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    

    @IBAction func nextPressed(_ sender: UIButton)
    {
        switch self.tutorialStep.index
        {
        case 0...1:
            let pageViewController = parent as! TutorialPageViewController
            pageViewController.forward(toIndex: self.tutorialStep.index)
        case 2:
            let defaults = UserDefaults.standard
            
            defaults.set(true, forKey: "hasViewedTutorial")
            
            self.dismiss(animated: true, completion: nil)
        default:
            break
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
