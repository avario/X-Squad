//
//  AppDelegate.swift
//  X-Squad
//
//  Created by Avario on 02/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		UIApplication.shared.registerForRemoteNotifications()
		SquadCloudStore.shared.subscribeToChanges()
		
		window = UIWindow(frame: UIScreen.main.bounds)
		window!.tintColor = UIColor(named: "XRed")
		
		UINavigationBar.appearance().titleTextAttributes = [
			.foregroundColor: UIColor.init(white: 0.8, alpha: 1.0)]
		UINavigationBar.appearance().largeTitleTextAttributes = [
			.foregroundColor: UIColor.init(white: 0.8, alpha: 1.0)]
		
		let tabBarController = UITabBarController()
		tabBarController.tabBar.barStyle = .black
		
		tabBarController.viewControllers = [
			UINavigationController(rootViewController: NewGameViewController()),
			EditSquadsViewController(),
			UINavigationController(rootViewController: SearchViewController()),
			UINavigationController(rootViewController: SettingsViewController())]

		tabBarController.delegate = tabBarController
		tabBarController.selectedIndex = tabBarController.viewControllers!
			.firstIndex(where: { $0 is EditSquadsViewController })!
		
		window?.rootViewController = tabBarController
		window?.makeKeyAndVisible()
		
		return true
	}
	
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		SquadCloudStore.shared.handleNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		SquadCloudStore.shared.syncRecordsIfNeeded()
		DataStore.shared.updateIfNeeded()
	}
	
}

extension UITabBarController: UITabBarControllerDelegate {
	public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		// Don't go back to the "New Game" view controller when the tab bar button is pressed (because this would end the current game).
		return (tabBarController.selectedIndex != 0 || viewController != tabBarController.selectedViewController)
	}
}

