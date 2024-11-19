import Foundation
import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackerVC = UINavigationController(rootViewController: TrackersViewController())
        trackerVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tabbar.trackers.title", comment: ""),
            image: UIImage(named: "TrackersLogo"), tag: 0)
        
        let statisticVC = UINavigationController(rootViewController: StatisticViewController())
        statisticVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tabbar.statistics.title", comment: ""),
            image: UIImage(named: "StatisticLogo"), tag: 1)
        
        viewControllers = [trackerVC, statisticVC]
        
        // Установка серого бордера для Tab Bar
        tabBar.layer.borderWidth = 0.5 
        if traitCollection.userInterfaceStyle == .dark {
            tabBar.layer.borderColor = UIColor.lbBlack.cgColor
        } else {
            tabBar.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        Logger.log("Загружен Tab bar контроллер")
    }
}

