//
//  WebViewController.swift
//  Lugares
//
//  Created by Eduardo De La Cruz on 9/6/17.
//  Copyright © 2017 Eduardo De La Cruz. All rights reserved.
//

import UIKit

class WebViewController: UIViewController
{
    // MARK: - Outlets
    
    @IBOutlet var webView: UIWebView!
    
    // MARK: - Global Variables
    
    var urlName : String!
    
    // MARK: - Predefined Init

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let url = URL(string: urlName)
        {
            let request = URLRequest(url: url)
            
            self.webView.loadRequest(request)
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
