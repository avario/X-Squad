//
//  SquadViewController.swift
//  X-Squad
//
//  Created by Avario on 10/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class SquadViewController: UIViewController {
	
	let squad: Squad
	
	static let pilotCardWidth = UIScreen.main.bounds.width * 0.5
	
	var pilotViews: [ScrollableSquadPilotView] = []
	
	init(for squad: Squad) {
		self.squad = squad
		super.init(nibName: nil, bundle: nil)
		
		transitioningDelegate = self
		modalPresentationStyle = .overCurrentContext
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	let scrollView = UIScrollView()
	let stackView = UIStackView()
	
	var pullToDismissController: PullToDismissController!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .black
		
		view.addSubview(scrollView)
		scrollView.contentInsetAdjustmentBehavior = .always
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.alwaysBounceVertical = true
		scrollView.showsVerticalScrollIndicator = false
		
		scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		
		scrollView.addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = 10
		stackView.alignment = .fill
		
		stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
		stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
		stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
		stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
		stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
		
		let header = SquadHeaderView(squad: squad)
		stackView.addArrangedSubview(header)
		
		let addPilotButton = UIButton(type: .contactAdd)
		addPilotButton.addTarget(self, action: #selector(addPilot), for: .touchUpInside)
		addPilotButton.translatesAutoresizingMaskIntoConstraints = false
		addPilotButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
		
		stackView.addArrangedSubview(addPilotButton)
		
		pullToDismissController = PullToDismissController(viewController: self, scrollView: scrollView)
		
		updatePilotViews()
		
		NotificationCenter.default.addObserver(self, selector: #selector(updatePilotViews), name: .squadStoreDidAddPilotToSquad, object: squad)
		NotificationCenter.default.addObserver(self, selector: #selector(updatePilotViews), name: .squadStoreDidRemovePilotFromSquad, object: squad)
	}
	
	@objc func updatePilotViews() {
		func pilotView(for pilot: Squad.Pilot) -> ScrollableSquadPilotView {
			if let existingPilotView = pilotViews.first(where: { $0.squadPilotView.pilot.uuid == pilot.uuid }) {
				return existingPilotView
			} else {
				let squadPilotView = ScrollableSquadPilotView(pilot: pilot)
				squadPilotView.squadPilotView.delegate = self
				pilotViews.append(squadPilotView)
				
				return squadPilotView
			}
		}
		
		// Remove any pilots that are no longer in the squad
		for pilotView in pilotViews {
			if !squad.pilots.contains(where: { $0.uuid == pilotView.squadPilotView.pilot.uuid }) {
				pilotView.removeFromSuperview()
			}
		}
		pilotViews = pilotViews.filter({ $0.superview != nil })
		
		for (index, pilot) in squad.pilots.enumerated() {
			let squadPilotView = pilotView(for: pilot)
			
			// +1 for header view
			stackView.insertArrangedSubview(squadPilotView, at: index + 1)
		}
	}
	
	@objc func addPilot() {
		let addPilotViewController = AddPilotViewController(squad: squad)
		present(addPilotViewController, animated: true, completion: nil)
	}
	
}

extension SquadViewController: SquadPilotViewDelegate {
	func squadPilotView(_ squadPilotView: SquadPilotView, didSelect pilot: Squad.Pilot) {
		let cardViewController = CardViewController(card: pilot.card, id: pilot.uuid.uuidString)
		present(cardViewController, animated: true, completion: nil)
	}
	
	func squadPilotView(_ squadPilotView: SquadPilotView, didSelect upgrade: Squad.Pilot.Upgrade) {
		let cardViewController = CardViewController(card: upgrade.card, id: upgrade.uuid.uuidString)
		present(cardViewController, animated: true, completion: nil)
	}
	
	func squadPilotView(_ squadPilotView: SquadPilotView, didPress button: UpgradeButton) {
		let selectUpgradeViewController = SelectUpgradeViewController(squad: squad, pilot: squadPilotView.pilot, currentUpgrade: button.associatedUpgrade, upgradeType: button.upgradeType!, upgradeButton: button)
		present(selectUpgradeViewController, animated: true, completion: nil)
	}
}

extension SquadViewController: UIViewControllerTransitioningDelegate {
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return CardsPresentAnimationController()
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return CardsDismissAnimationController()
	}
	
	func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return nil
	}
}
