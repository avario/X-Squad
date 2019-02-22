//
//  SquadViewController.swift
//  X-Squad
//
//  Created by Avario on 10/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This is an abstract screen that display a squad (with the pilots stacked vertically). The pilots are displayed in a scrollable stack view.

import Foundation
import UIKit

class SquadViewController: UIViewController {
	
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
		
		// The header displays the Close button, the point cost, and the info button
		let header = SquadHeaderView(squad: squad)
		header.infoButton.addTarget(self, action: #selector(showSquadInfo), for: .touchUpInside)
		header.closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
		stackView.addArrangedSubview(header)
		header.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
		
		pullToDismissController = PullToDismissController(scrollView: scrollView)
		pullToDismissController.viewController = self
		
		updateMemberViews()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		// Spacing on the top looks a bit better on devices without a notch
		if view.safeAreaInsets.top <= 30 {
			scrollView.contentInset.top = 10
		}
	}
	
	@objc func updateMemberViews() {
		updateEmptyView()
		
		for (index, member) in squad.members.enumerated() {
			// Member views are only removed in the EditSquadViewController subclass.
			let squadMemberView = memberView(for: member)
			
			// +1 for header view
			stackView.insertArrangedSubview(squadMemberView, at: index + 1)
			squadMemberView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
		}
	}
	
	// The empty view is shown when there are no pilots in the squad.
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
		// This method will be overriden by subclasses.
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
		alert.addAction(UIAlertAction(title: "Export Image", style: .default, handler: { _ in
			self.exportImage()
		}))
	}
	
	func exportImage() {
		let membersStackView = UIStackView()
		membersStackView.axis = .vertical
		membersStackView.spacing = 10
		membersStackView.layoutMargins = UIEdgeInsets(top: 30, left: 40, bottom: 30, right: 40)
		membersStackView.insetsLayoutMarginsFromSafeArea = false
		membersStackView.isLayoutMarginsRelativeArrangement = true
		membersStackView.translatesAutoresizingMaskIntoConstraints = false
		membersStackView.alignment = .leading
		
		var previousMember: Squad.Member?
		var previousMemberRow: UIStackView?
		for member in squad.members {
			let memberView = MemberView(member: member, height: 300, mode: .display)
			
			if let previousMember = previousMember,
				previousMember.upgrades.isEmpty,
				member.upgrades.isEmpty,
				let previousMemberRow = previousMemberRow {
				
				previousMemberRow.addArrangedSubview(memberView)
				
			} else {
				let memberRow = UIStackView(arrangedSubviews: [memberView])
				memberRow.axis = .horizontal
				memberRow.spacing = 30
				
				membersStackView.addArrangedSubview(memberRow)
				
				previousMemberRow = memberRow
			}
			
			previousMember = member
		}
		
		UIApplication.shared.keyWindow!.insertSubview(membersStackView, at: 0)
		
		membersStackView.setNeedsLayout()
		membersStackView.layoutSubviews()
		membersStackView.layoutIfNeeded()
		
		// Just to make sure the images have loaded
		DispatchQueue.main.async {
			let size = membersStackView.bounds.size
			
			UIGraphicsBeginImageContextWithOptions(size, true, 2.0)
			let context = UIGraphicsGetCurrentContext()!
			
			UIColor.black.setFill()
			context.fill(CGRect(origin: .zero, size: size))
			
			membersStackView.layer.render(in: context)
			let image = UIGraphicsGetImageFromCurrentImageContext()
			
			UIGraphicsEndImageContext()
			
			membersStackView.removeFromSuperview()
			
			let imageToShare = [image!]
			let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
			activityViewController.popoverPresentationController?.sourceView = self.view
			
			self.present(activityViewController, animated: true, completion: nil)
		}
	}
	
	// Copy XWS text for the squad to the user's clipboard.
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
	
}

extension SquadViewController: MemberViewDelegate {
	func memberView(_ memberView: MemberView, didSelect pilot: Pilot) {
		let cardDetailsCollectionViewController = CardDetailsCollectionViewController(initialCard: pilot)
		cardDetailsCollectionViewController.dataSource = memberView
		cardDetailsCollectionViewController.delegate = memberView
		
		present(cardDetailsCollectionViewController, animated: true, completion: nil)
	}
	
	func memberView(_ memberView: MemberView, didSelect upgrade: Upgrade) {
		let cardDetailsCollectionViewController = CardDetailsCollectionViewController(initialCard: upgrade)
		cardDetailsCollectionViewController.dataSource = memberView
		cardDetailsCollectionViewController.delegate = memberView
		
		present(cardDetailsCollectionViewController, animated: true, completion: nil)
	}
	
	func memberView(_ memberView: MemberView, didPress button: UpgradeButton) {
		let selectUpgradeViewController = SelectUpgradeViewController(squad: squad, member: memberView.member, currentUpgrade: button.associatedUpgrade, upgradeType: button.upgradeType!)
		present(selectUpgradeViewController, animated: true, completion: nil)
	}
}

extension SquadViewController: UIViewControllerTransitioningDelegate {
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		// Don't do a fancy transition if the squad is empty.
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
