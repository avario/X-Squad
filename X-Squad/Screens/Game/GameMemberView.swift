//
//  GameMemberView.swift
//  X-Squad
//
//  Created by Avario on 13/02/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class GameMemberView: UIScrollView {
	
	let member: Squad.Member
	let memberView: MemberView
	let stateView: GameSquadMemberStateView
	
	init(member: Squad.Member, state: Game.MemberState) {
		self.member = member
		self.memberView = MemberView(member: member, height: UIScreen.main.bounds.width * 0.75, mode: .game)
		self.stateView = GameSquadMemberStateView(member: member, state: state)
		
		super.init(frame: .zero)
		translatesAutoresizingMaskIntoConstraints = false
		clipsToBounds = false
		alwaysBounceHorizontal = true
		alwaysBounceVertical = false
		showsHorizontalScrollIndicator = false
		
		let stackView = UIStackView(arrangedSubviews: [stateView, memberView])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.alignment = .top
		stackView.spacing = 20
		
		stackView.heightAnchor.constraint(equalTo: memberView.heightAnchor).isActive = true
		
		addSubview(stackView)
		stackView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor).isActive = true
		stackView.rightAnchor.constraint(equalTo: contentLayoutGuide.rightAnchor, constant: -16).isActive = true
		stackView.leftAnchor.constraint(equalTo: contentLayoutGuide.leftAnchor, constant: 16).isActive = true
		frameLayoutGuide.heightAnchor.constraint(equalTo: stackView.heightAnchor).isActive = true
		
		if member.upgrades.isEmpty {
			contentInset.right = 200
		}
		
		for cardView in memberView.cardViews {
			guard let upgrade = cardView.card as? Upgrade,
			 	let upgradeState = state.upgradeStates[upgrade.xws],
				upgradeState.chargeTokens.isEmpty == false else {
				continue
			}
			
			let chargesStackView = TokenStackView(tokens: upgradeState.chargeTokens, type: .charge)
			addSubview(chargesStackView)
			chargesStackView.translatesAutoresizingMaskIntoConstraints = false
			chargesStackView.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: cardView.bounds.width * CardView.upgradeHiddenRatio + 10).isActive = true
			chargesStackView.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 10).isActive = true
		}
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
}
