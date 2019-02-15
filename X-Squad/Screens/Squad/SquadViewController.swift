//
//  SquadViewController.swift
//  X-Squad
//
//  Created by Avario on 10/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class SquadViewController: UIViewController, CardViewControllerDelegate {
	
	let squad: Squad
	
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
		
		view.backgroundColor = UIColor(named: "XBackground")
		
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
		
		pullToDismissController = PullToDismissController(viewController: self, scrollView: scrollView)
		
		updateMemberViews()
	}
	
	@objc func updateMemberViews() {
		updateEmptyView()
		
		for (index, member) in squad.members.enumerated() {
			let squadMemberView = memberView(for: member)
			
			// +1 for header view
			stackView.insertArrangedSubview(squadMemberView, at: index + 1)
			squadMemberView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
		}
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
	
	func memberView(for member: Squad.Member) -> UIView {
		fatalError()
	}
	
	@objc func showSquadInfo() {
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		addActions(to: alert)
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in }))
		alert.view.tintColor = .black
		self.present(alert, animated: true, completion: nil)
	}
	
	func addActions(to alert: UIAlertController) {
		alert.addAction(UIAlertAction(title: "Copy XWS to Clipboard", style: .default, handler: { _ in
			self.copyXWS()
		}))
		alert.addAction(UIAlertAction(title: "View XWS QR Code", style: .default, handler: { _ in
			self.showXWSQRCode()
		}))
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
	
	func squadActionForCardViewController(_ cardViewController: CardViewController) -> SquadButton.Action? {
		return nil
	}
	
	func cardViewControllerDidPressSquadButton(_ cardViewController: CardViewController) {
		
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
