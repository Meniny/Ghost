//
//  DisplayViewController.swift
//  Sample
//
//  Created by Meniny on 2018-01-25.
//  Copyright © 2018年 Meniny Lab. All rights reserved.
//

import UIKit

class DisplayViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    
    var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.textView.text = self.text
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
