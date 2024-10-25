//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Aleksei Bondarenko on 23.10.2024.
//

import UIKit

final class OnboardingPageViewController: UIViewController {

    private var pageViewController: UIPageViewController!
    private let pageControl = UIPageControl()

    private var onboardingPages: [OnboardingContentViewController] = []

    private var currentPageIndex: Int = 0 {
        didSet {
            pageControl.currentPage = currentPageIndex
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupOnboardingPages()  // Создаем страницы
        setupPageViewController()
        setupPageControl()
    }

    private func setupOnboardingPages() {
        let firstPage = OnboardingContentViewController(titleText: "Отслеживайте только то, что хотите", backgroundImageName: "LB_Onboarding1")
        let secondPage = OnboardingContentViewController(titleText: "Даже если это не литры воды и йога", backgroundImageName: "LB_Onboarding2")
        
        // Определяем действие кнопки для каждой страницы
        firstPage.buttonAction = { [weak self] in
            self?.completeOnboarding()
        }
        
        secondPage.buttonAction = { [weak self] in
            self?.completeOnboarding()
        }
        
        onboardingPages = [firstPage, secondPage]
    }

    private func setupPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.setViewControllers([onboardingPages.first!], direction: .forward, animated: true, completion: nil)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageViewController.view)

        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupPageControl() {
        pageControl.numberOfPages = onboardingPages.count
        pageControl.currentPage = currentPageIndex
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        pageControl.currentPageIndicatorTintColor = UIColor.lbBlack
        
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -168),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func goToNextPage() {
        if currentPageIndex < onboardingPages.count - 1 {
            currentPageIndex += 1
            pageViewController.setViewControllers([onboardingPages[currentPageIndex]], direction: .forward, animated: true, completion: nil)
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
        let mainTabBarController = TabBarController()
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = mainTabBarController
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = onboardingPages.firstIndex(of: viewController as! OnboardingContentViewController) else {
            return nil
        }

        // Если это первая страница, возвращаем последнюю (для цикличности)
        if index == 0 {
            return onboardingPages.last
        } else {
            return onboardingPages[index - 1]
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = onboardingPages.firstIndex(of: viewController as! OnboardingContentViewController) else {
            return nil
        }

        // Если это последняя страница, возвращаем первую (для цикличности)
        if index == onboardingPages.count - 1 {
            return onboardingPages.first
        } else {
            return onboardingPages[index + 1]
        }
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let currentVC = pageViewController.viewControllers?.first as? OnboardingContentViewController, let index = onboardingPages.firstIndex(of: currentVC) {
            currentPageIndex = index
        }
    }
}
