//
//  Theme.swift
//  FeedThePiggy
//
//  Created by Ya Kao on 9/18/16.
//  Copyright © 2016 Betsy Kao. All rights reserved.
//

import UIKit

let pinkColor = UIColor(red: 255/255, green: 178/255, blue: 182/255, alpha: 1.0)

struct ThemeManager{
    
    static func set(){
        //UINavigationBar.appearance().barTintColor = UIColor.blue
        UITabBar.appearance().tintColor = pinkColor
        UITabBar.appearance().backgroundColor = UIColor.white
        

        UISearchBar.appearance().backgroundColor = UIColor.clear
        UISearchBar.appearance().barTintColor = pinkColor
        UISearchBar.appearance().tintColor = UIColor.white

        //To make an opaque Navigation bar, hack
        let backgroundImage = UIImage.tinyImageWithColor(color: pinkColor)
        UINavigationBar.appearance().setBackgroundImage(backgroundImage, for: .default)
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().shadowImage = backgroundImage;
        UINavigationBar.appearance().tintColor = UIColor.white
        
    }
}
//To make an opaque Navigation bar, hack

extension UIImage{
    class func tinyImageWithColor(color: UIColor) -> UIImage{
        let rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let cgSize: CGSize = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(cgSize, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
        
    }
}
