//
//  LaunchScreenViewController.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 7.9.2024.
//

import Foundation
import UIKit

final class LaunchScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lbBlue
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "LaunchImage")
        imageView.contentMode = .scaleAspectFill
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        Logger.log("Загружен Launch screen")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
            onboardingCompleted ? self.switchToMainScreen() : self.switchToOnboardingScreen()
        }
    }
    
    private func switchToMainScreen() {
        let tabBarController = TabBarController()
        
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = tabBarController
            UIView.transition(with: window, duration: 0.2, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    private func switchToOnboardingScreen() {
        let onboardingViewController = OnboardingPageViewController()
        
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = onboardingViewController
            UIView.transition(with: window, duration: 0.2, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
}
