//
//  SquadCell.swift
//  X-Squad
//
//  Created by Avario on 10/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// Displays a squad in a cell (with pilots stacked horizontally).

import Foundation
import UIKit

class SquadCell: UITableViewCell {
	
	static let reuseIdentifier = "SquadCell"
	static let rowHeight: CGFloat = 80
	
	var squad: Squad? {
		didSet {
			NotificationCenter.default.removeObserver(self)
			
			guard let squad = squad else {
				return
			}
			
			factionIconLabel.text = squad.faction.characterCode
			updateMemberViews()
			updateCost()
			
			NotificationCenter.default.addObserver(self, selector: #selector(updateMemberViews), name: .squadStoreDidAddMemberToSquad, object: squad)
			NotificationCenter.default.addObserver(self, selector: #selector(updateMemberViews), name: .squadStoreDidRemoveMemberFromSquad, object: squad)
			NotificationCenter.default.addObserver(self, selector: #selector(updateCost), name: .squadStoreDidUpdateSquad, object: squad)
		}
	}
	
	let factionIconLabel = UILabel()
	let scrollView = UIScrollView()
	let stackView = UIStackView()
	
	// Shown when the squad is empty
	var emptyLabel: UILabel?
	
	let costView = CostView()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		
		let backgroundView = UIView()
		backgroundView.backgroundColor = UIColor.init(white: 0.20, alpha: 1.0)
		selectedBackgroundView = backgroundView
		
		contentView.addSubview(scrollView)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.alwaysBounceHorizontal = true
		scrollView.isUserInteractionEnabled = false
		contentView.addGestureRecognizer(scrollView.panGestureRecognizer)
		
		scrollView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
		scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
		scrollView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
		scrollView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
		
		scrollView.addSubview(factionIconLabel)
		factionIconLabel.textAlignment = .center
		factionIconLabel.translatesAutoresizingMaskIntoConstraints = false
		factionIconLabel.textColor = UIColor.white.withAlphaComponent(0.5)
		factionIconLabel.font = UIFont.xWingIcon(32)
		
		factionIconLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
		factionIconLabel.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).isActive = true
		factionIconLabel.widthAnchor.constraint(equalToConstant: 44).isActive = true
		factionIconLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
		
		scrollView.addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .horizontal
		stackView.spacing = 10
		
		stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
		stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -16).isActive = true
		stackView.leftAnchor.constraint(equalTo: factionIconLabel.rightAnchor).isActive = true
		
		scrollView.addSubview(costView)
		costView.translatesAutoresizingMaskIntoConstraints = false
		costView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).isActive = true
		costView.rightAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 0).isActive = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	@objc func updateCost() {
		costView.cost = squad?.pointCost ?? 0
	}
	
	func updateEmptyLabel() {
		if let emptyLabel = emptyLabel {
			emptyLabel.removeFromSuperview()
			self.emptyLabel = nil
		}
		
		// Shown the empty label if the squad is empty.
		if let squad = squad, squad.members.isEmpty {
			emptyLabel = UILabel()
			emptyLabel?.translatesAutoresizingMaskIntoConstraints = false
			emptyLabel?.textAlignment = .center
			emptyLabel?.textColor = UIColor.white.withAlphaComponent(0.5)
			emptyLabel?.font = UIFont.systemFont(ofSize: 14)
			emptyLabel?.numberOfLines = 0
			emptyLabel?.text = "This squad is empty.\nTap here to edit."
			
			contentView.addSubview(emptyLabel!)
			emptyLabel?.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
			emptyLabel?.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
			emptyLabel?.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -44).isActive = true
			emptyLabel?.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 44).isActive = true
		}
	}
	
	var memberViews: [MemberView] = []
	
	// Update the squad's members whenever a member is added/removed (upgrades are managed within the member views themselves).
	@objc func updateMemberViews() {
		guard let squad = squad else {
			return
		}
		
		updateEmptyLabel()
		
		func memberView(for member: Squad.Member) -> MemberView {
			if let existingMemberView = memberViews.first(where: { $0.member.uuid == member.uuid }) {
				return existingMemberView
			} else {
				// A member view for any member added to the squad.
				let squadMemberView = MemberView(member: member, height: SquadCell.rowHeight, mode: .display)
				memberViews.append(squadMemberView)
				
				return squadMemberView
			}
		}
		
		// Remove any members that are no longer in the squad.
		for memberView in memberViews {
			if !squad.members.contains(where: { $0.uuid == memberView.member.uuid }) {
				memberView.removeFromSuperview()
			}
		}
		memberViews = memberViews.filter({ $0.superview != nil })
		
		// Make sure the member views are arranged in the right order
		for (index, member) in squad.members.enumerated() {
			let squadMemberView = memberView(for: member)
			stackView.insertArrangedSubview(squadMemberView, at: index)
		}
	}
	
}
