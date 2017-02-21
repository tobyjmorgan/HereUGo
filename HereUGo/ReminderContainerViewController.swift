//
//  ReminderContainerViewController.swift
//  HereUGo
//
//  Created by redBred LLC on 2/19/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit

class ReminderContainerViewController: UIViewController {

    var reminder: Reminder?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ReminderViewController {
            vc.reminder = reminder
        }
    }

}
