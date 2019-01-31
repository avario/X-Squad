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
	
	var memberViews: [SquadMemberView] = []
	let scrollView = UIScrollView()
	let stackView = UIStackView()
	
	var pullToDismissController: PullToDismissController!
	
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
		stackView.alignment = .center
		
		stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
		stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
		stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
		stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
		stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
		
		let header = SquadHeaderView(squad: squad)
		header.infoButton.addTarget(self, action: #selector(showSquadInfo), for: .touchUpInside)
		header.closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
		stackView.addArrangedSubview(header)
		header.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
		
		let addPilotButton = SquadButton()
		addPilotButton.action = .add("Add Pilot")
		addPilotButton.addTarget(self, action: #selector(addPilot), for: .touchUpInside)
		
		stackView.addArrangedSubview(addPilotButton)
		
		pullToDismissController = PullToDismissController(viewController: self, scrollView: scrollView)
		
		updateMemberViews()
		
		NotificationCenter.default.addObserver(self, selector: #selector(updateMemberViews), name: .squadStoreDidAddMemberToSquad, object: squad)
		NotificationCenter.default.addObserver(self, selector: #selector(updateMemberViews), name: .squadStoreDidRemoveMemberFromSquad, object: squad)
	}
	
	var emptyView: SquadEmptyView?
	
	func updateEmptyView() {
		if squad.members.isEmpty, emptyView == nil {
			emptyView = SquadEmptyView(faction: squad.faction)
			stackView.insertArrangedSubview(emptyView!, at: 1)
			emptyView?.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
			
		} else if let emptyView = emptyView {
			emptyView.removeFromSuperview()
			self.emptyView = nil
		}
	}
	
	@objc func close() {
		dismiss(animated: true, completion: nil)
	}
	
	@objc func updateMemberViews() {
		updateEmptyView()
		
		func memberView(for member: Squad.Member) -> SquadMemberView {
			if let existingMemberView = memberViews.first(where: { $0.memberView.member.uuid == member.uuid }) {
				return existingMemberView
			} else {
				let squadMemberView = SquadMemberView(member: member)
				squadMemberView.memberView.delegate = self
				memberViews.append(squadMemberView)
				
				return squadMemberView
			}
		}
		
		// Remove any members that are no longer in the squad
		for memberView in memberViews {
			if !squad.members.contains(where: { $0.uuid == memberView.memberView.member.uuid }) {
				memberView.removeFromSuperview()
			}
		}
		memberViews = memberViews.filter({ $0.superview != nil })
		
		for (index, member) in squad.members.enumerated() {
			let squadMemberView = memberView(for: member)
			
			// +1 for header view
			stackView.insertArrangedSubview(squadMemberView, at: index + 1)
			squadMemberView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
		}
	}
	
	@objc func addPilot() {
		let addPilotViewController = AddPilotViewController(squad: squad)
		present(addPilotViewController, animated: true, completion: nil)
	}
	
	@objc func showSquadInfo() {
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Copy XWS to Clipboard", style: .default, handler: { _ in
			self.copyXWS()
		}))
		alert.addAction(UIAlertAction(title: "View XWS QR Code", style: .default, handler: { _ in
			self.showXWSQRCode()
		}))
		alert.addAction(UIAlertAction(title: "Duplicate Squad", style: .default, handler: { _ in
			self.duplicateSquad()
		}))
		alert.addAction(UIAlertAction(title: "Delete Squad", style: .destructive, handler: { _ in
			self.deleteSquad()
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in }))
		alert.view.tintColor = .black
		self.present(alert, animated: true, completion: nil)
	}
	
	func deleteSquad() {
		SquadStore.delete(squad: squad)
		
		for cardView in CardView.all(in: view) {
			cardView.member = nil
		}
		
		dismiss(animated: true, completion: nil)
	}
	
	func copyXWS() {
		let xws = XWS(squad: squad)
		
		let jsonEncoder = JSONEncoder()
		jsonEncoder.outputFormatting = .prettyPrinted
		
		let jsonData = try! JSONEncoder().encode(xws)
		let jsonText = String(data: jsonData, encoding: .utf8)
		
		UIPasteboard.general.string = jsonText
	}
	
	func showXWSQRCode() {
		present(UINavigationController(rootViewController: QRCodeViewController(squad: squad)), animated: true, completion: nil)
	}
	
	func duplicateSquad() {
		let duplicateMembers = squad.members.map({ Squad.Member(ship: $0.ship, pilot: $0.pilot, upgrades: $0.upgrades) })
		let duplicateSquad = Squad(faction: squad.faction, members: duplicateMembers, name: squad.name, description: squad.description, obstacles: squad.obstacles, vendor: squad.vendor)
		
		SquadStore.add(squad: duplicateSquad)
		dismiss(animated: true, completion: nil)
	}
}

extension SquadViewController: MemberViewDelegate {
	func memberView(_ memberView: MemberView, didSelect pilot: Pilot) {
		let cardViewController = CardViewController(card: pilot, member: memberView.member)
		cardViewController.cardView.member = memberView.member
		cardViewController.delegate = self
		present(cardViewController, animated: true, completion: nil)
	}
	
	func memberView(_ memberView: MemberView, didSelect upgrade: Upgrade) {
		let cardViewController = CardViewController(card: upgrade, member: memberView.member)
		cardViewController.cardView.member = memberView.member
		cardViewController.delegate = self
		present(cardViewController, animated: true, completion: nil)
	}
	
	func memberView(_ memberView: MemberView, didPress button: UpgradeButton) {
		let selectUpgradeViewController = SelectUpgradeViewController(squad: squad, member: memberView.member, currentUpgrade: button.associatedUpgrade, upgradeType: button.upgradeType!)
		present(selectUpgradeViewController, animated: true, completion: nil)
	}
}

extension SquadViewController: CardViewControllerDelegate {
	func squadActionForCardViewController(_ cardViewController: CardViewController) -> SquadButton.Action? {
		switch cardViewController.card {
		case _ as Pilot:
			return .remove("Remove from Squad")
		case _ as Upgrade:
			return .remove("Remove from Pilot")
		default:
			fatalError()
		}
	}
	
	func cardViewControllerDidPressSquadButton(_ cardViewController: CardViewController) {
		let member = cardViewController.member!
		
		switch cardViewController.card {
		case _ as Pilot:
			squad.remove(member: member)
		case let upgrade as Upgrade:
			member.remove(upgrade: upgrade)
		default:
			fatalError()
		}
		
		dismiss(animated: true, completion: nil)
	}
}

extension SquadViewController: UIViewControllerTransitioningDelegate {
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		if squad.members.isEmpty {
			return nil
		}
		
		return CardsPresentAnimationController()
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		if squad.members.isEmpty {
			return nil
		}
		
		return CardsDismissAnimationController()
	}
	
	func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return nil
	}
}
