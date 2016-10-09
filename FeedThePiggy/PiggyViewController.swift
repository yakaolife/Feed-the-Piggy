//
//  PiggyViewController.swift
//  FeedThePiggy
//
//  Created by Ya Kao on 9/18/16.
//  Copyright © 2016 Betsy Kao. All rights reserved.
//

import UIKit
import CoreData


class PiggyViewController: UIViewController, SelectItemProtocol{

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let foodItem = UIImage(named: "food")
        self.tabBarController?.tabBar.items?[1].image = foodItem
        let insets = UIEdgeInsets(top: 5.0, left: 0, bottom: -5.0, right: 0)
        self.tabBarController?.tabBar.items?[1].imageInsets = insets
    }
    
    func selected(foodItem: FoodItem) {
        print("We got food item! \(foodItem.name)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectItemSegue"{
            let navigationVC = segue.destination as! UINavigationController
            let tableViewVC = navigationVC.topViewController as! SelectItemViewController
            tableViewVC.fromPiggyView = true
            tableViewVC.selectItemDelegate = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
