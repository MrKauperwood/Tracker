//
//  TabBarController.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 7.9.2024.
//

import Foundation
import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackerVC = UINavigationController(rootViewController: TrackersViewController())
        trackerVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "TrackersLogo"), tag: 0)
        
        let statisticVC = UINavigationController()
        statisticVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "StatisticLogo"), tag: 1)
        
        viewControllers = [trackerVC, statisticVC]
        
        // Установка серого бордера для Tab Bar
        tabBar.layer.borderWidth = 0.5 // Устанавливаем ширину границы
        tabBar.layer.borderColor = UIColor.lightGray.cgColor // Устанавливаем цвет границы
        
        Logger.log("Загружен Tab bar контроллер")
    }
}

