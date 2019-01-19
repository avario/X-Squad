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
	
	var pilotViews: [SquadPilotView] = []
	
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
		header.infoButton.addTarget(self, action: #selector(showSquadInfo), for: .touchUpInside)
		stackView.addArrangedSubview(header)
		
		let addPilotButton = SquadButton(height: 80)
		addPilotButton.addTarget(self, action: #selector(addPilot), for: .touchUpInside)
		
		stackView.addArrangedSubview(addPilotButton)
		
		pullToDismissController = PullToDismissController(viewController: self, scrollView: scrollView)
		
		updatePilotViews()
		
		NotificationCenter.default.addObserver(self, selector: #selector(updatePilotViews), name: .squadStoreDidAddPilotToSquad, object: squad)
		NotificationCenter.default.addObserver(self, selector: #selector(updatePilotViews), name: .squadStoreDidRemovePilotFromSquad, object: squad)
	}
	
	var emptyLabel: UILabel?
	
	func updateEmptyView() {
		if squad.pilots.isEmpty, emptyLabel == nil {
			emptyLabel = UILabel()
			emptyLabel?.translatesAutoresizingMaskIntoConstraints = false
			emptyLabel?.textAlignment = .center
			emptyLabel?.textColor = UIColor.white.withAlphaComponent(0.5)
			emptyLabel?.font = UIFont.systemFont(ofSize: 16)
			emptyLabel?.numberOfLines = 0
			emptyLabel?.text = "This squad is empty.\nUse this + button to add a pilot to this squad.\n\nSwipe down to dimiss."
			
			stackView.insertArrangedSubview(emptyLabel!, at: 1)
			emptyLabel?.heightAnchor.constraint(equalToConstant: 100).isActive = true
		} else if let emptyLabel = emptyLabel {
			emptyLabel.removeFromSuperview()
			self.emptyLabel = nil
		}
	}
	
	@objc func updatePilotViews() {
		updateEmptyView()
		
		func pilotView(for pilot: Squad.Pilot) -> SquadPilotView {
			if let existingPilotView = pilotViews.first(where: { $0.pilotView.pilot.uuid == pilot.uuid }) {
				return existingPilotView
			} else {
				let squadPilotView = SquadPilotView(pilot: pilot)
				squadPilotView.pilotView.delegate = self
				pilotViews.append(squadPilotView)
				
				return squadPilotView
			}
		}
		
		// Remove any pilots that are no longer in the squad
		for pilotView in pilotViews {
			if !squad.pilots.contains(where: { $0.uuid == pilotView.pilotView.pilot.uuid }) {
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
	
	@objc func showSquadInfo() {
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Delete Squad", style: .destructive, handler: { _ in
			SquadStore.delete(squad: self.squad)
			
			for cardView in CardView.all(in: self.view) {
				cardView.id = cardView.card?.defaultID
			}
			
			self.dismiss(animated: true, completion: nil)
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
			
		}))
		self.present(alert, animated: true, completion: nil)
	}
	
}

extension SquadViewController: PilotViewDelegate {
	func pilotView(_ pilotView: PilotView, didSelect pilot: Squad.Pilot) {
		let cardViewController = CardViewController(card: pilot.card, id: pilot.uuid.uuidString)
		cardViewController.delegate = self
		present(cardViewController, animated: true, completion: nil)
	}
	
	func pilotView(_ pilotView: PilotView, didSelect upgrade: Squad.Pilot.Upgrade) {
		let cardViewController = CardViewController(card: upgrade.card, id: upgrade.uuid.uuidString, pilot: pilotView.pilot)
		cardViewController.delegate = self
		present(cardViewController, animated: true, completion: nil)
	}
	
	func pilotView(_ pilotView: PilotView, didPress button: UpgradeButton) {
		let selectUpgradeViewController = SelectUpgradeViewController(squad: squad, pilot: pilotView.pilot, currentUpgrade: button.associatedUpgrade, upgradeType: button.upgradeType!, upgradeButton: button)
		present(selectUpgradeViewController, animated: true, completion: nil)
	}
}

extension SquadViewController: CardViewControllerDelegate {
	func squadActionForCardViewController(_ cardViewController: CardViewController) -> SquadButton.Action? {
		return .remove
	}
	
	func cardViewControllerDidPressSquadButton(_ cardViewController: CardViewController) {
		switch cardViewController.card.type {
		case .pilot:
			guard let pilot = squad.pilots.first(where: { $0.card == cardViewController.card }) else {
				return
			}
			squad.remove(pilot: pilot)
		case .upgrade:
			guard let pilot = squad.pilots.first(where: { $0.upgrades.contains(where: { $0.card == cardViewController.card }) }),
			 	let upgrade = pilot.upgrades.first(where: { $0.card == cardViewController.card }) else {
				return
			}
			
			pilot.remove(upgrade: upgrade)
		}
		
		dismiss(animated: true, completion: nil)
	}
}

extension SquadViewController: UIViewControllerTransitioningDelegate {
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		if squad.pilots.isEmpty {
			return nil
		}
		
		return CardsPresentAnimationController()
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		if squad.pilots.isEmpty {
			return nil
		}
		
		return CardsDismissAnimationController()
	}
	
	func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return nil
	}
}
