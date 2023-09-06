//
//  ViewController.swift
//  NetfilxClone
//
//  Created by tungdd on 26/06/2023.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        navigationController?.setNavigationBarHidden(true, animated: true)
        let vc1 = UINavigationController(rootViewController: HomeViewController())
        vc1.tabBarItem.image = UIImage(named: "Home")
        vc1.tabBarItem.selectedImage = UIImage(named: "SelectedHome")
        let vc2 = UINavigationController(rootViewController: UpcomingViewController())
        vc2.tabBarItem.image = UIImage(named: "Ticket")
        vc2.tabBarItem.selectedImage = UIImage(named: "SelectedTicket")
        let vc3 = UINavigationController(rootViewController: SearchViewController())
        vc3.tabBarItem.image = UIImage(named: "Search")
        vc3.tabBarItem.selectedImage = UIImage(named: "SelectedSearch")
        let vc4 = UINavigationController(rootViewController: FavouriteViewController())
        vc4.tabBarItem.image = UIImage(systemName: "heart.circle")
        vc4.tabBarItem.selectedImage = UIImage(systemName: "heart.circle.fill")
        tabBar.tintColor = #colorLiteral(red: 0.4686928988, green: 0.01086951792, blue: 0.8312569261, alpha: 1)
        tabBar.unselectedItemTintColor = #colorLiteral(red: 0.4686928988, green: 0.01086951792, blue: 0.8312569261, alpha: 1)
        tabBar.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        setViewControllers([vc1,vc2,vc3,vc4], animated: true)
    }


}

