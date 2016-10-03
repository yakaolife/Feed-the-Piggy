//
//  ItemDetailViewController.swift
//  FeedThePiggy
//
//  Created by Ya Kao on 10/2/16.
//  Copyright © 2016 Betsy Kao. All rights reserved.
//

import UIKit

class ItemDetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var currentTotalLabel: UILabel!
    @IBOutlet weak var creationDate: UILabel!
    let dateFormatter: DateFormatter = DateFormatter()
    
    var foodItem: FoodItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateStyle = .medium
        
        nameLabel.text = foodItem.name
        priceLabel.text = String(format:"%.f",foodItem.price)
        currentTotalLabel.text = String(format:"%.f", foodItem.currentTotal)
        let date = dateFormatter.string(from: foodItem.creationdate as! Date)
        creationDate.text = date
        
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
