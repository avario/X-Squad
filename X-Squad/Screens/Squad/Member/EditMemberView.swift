//
//  ScrollableSquadPilotView.swift
//  X-Squad
//
//  Created by Avario on 16/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class EditMemberView: UIScrollView {
	
	let member: Squad.Member
	let memberView: MemberView
	let costView = CostView()

	init(member: Squad.Member) {
		self.member = member
		self.memberView = MemberView(member: member, height: UIScreen.main.bounds.width * 0.75, mode: .edit)
		
		super.init(frame: .zero)
		translatesAutoresizingMaskIntoConstraints = false
		clipsToBounds = false
		alwaysBounceHorizontal = true
		alwaysBounceVertical = false
		showsHorizontalScrollIndicator = false
		
		addSubview(memberView)
		memberView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor).isActive = true
		memberView.rightAnchor.constraint(equalTo: contentLayoutGuide.rightAnchor, constant: -16).isActive = true
		memberView.leftAnchor.constraint(equalTo: contentLayoutGuide.leftAnchor, constant: 16).isActive = true
		frameLayoutGuide.heightAnchor.constraint(equalTo: memberView.heightAnchor).isActive = true
		
		addSubview(costView)
		costView.translatesAutoresizingMaskIntoConstraints = false
		costView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		costView.rightAnchor.constraint(equalTo: leftAnchor, constant: -16).isActive = true
		
		updateCost()
		
		NotificationCenter.default.addObserver(self, selector: #selector(updateCost), name: .squadStoreDidAddUpgradeToMember, object: member)
		NotificationCenter.default.addObserver(self, selector: #selector(updateCost), name: .squadStoreDidRemoveUpgradeFromMember, object: member)
	}
	
	@objc func updateCost() {
		costView.cost = member.pointCost
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
