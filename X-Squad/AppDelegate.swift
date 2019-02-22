//
//  AppDelegate.swift
//  X-Squad
//
//  Created by Avario on 02/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import UIKit
import Kingfisher

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		window = UIWindow(frame: UIScreen.main.bounds)
		window!.tintColor = UIColor(named: "XRed")
		
		UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.init(white: 0.8, alpha: 1.0)]
		UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.init(white: 0.8, alpha: 1.0)]
		UIToolbar.appearance().isTranslucent = false
		
		let tabBarController = UITabBarController()
		tabBarController.tabBar.barStyle = .black
		
		tabBarController.viewControllers = [
			UINavigationController(rootViewController: NewGameViewController()),
			EditSquadsViewController(),
			UINavigationController(rootViewController: SearchViewController()),
			UINavigationController(rootViewController: SettingsViewController())]

		tabBarController.selectedIndex = tabBarController.viewControllers!.firstIndex(where: { $0 is EditSquadsViewController })!
		tabBarController.delegate = tabBarController
		
		window?.rootViewController = tabBarController
		
		window?.makeKeyAndVisible()
		
		return true
	}
	
}

extension UITabBarController: UITabBarControllerDelegate {
	public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		// Don't go back to the "New Game" view controller when the tab bar button is pressed (because this would end the current game).
		return (tabBarController.selectedIndex != 0 || viewController != tabBarController.selectedViewController)
	}
}

