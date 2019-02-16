//
//  GameSquadViewController.swift
//  X-Squad
//
//  Created by Avario on 13/02/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This screen displays a user's squad (with pilots stacked vertically) in game mode (showing all of the tokens).

import Foundation
import UIKit

class GameSquadViewControler: SquadViewController {
	
	var memberViews: [GameMemberView] = []
	
	let states: [UUID: Game.MemberState]
	
	init(for squad: Squad, states: [UUID: Game.MemberState]) {
		self.states = states
		
		super.init(for: squad)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	override func memberView(for member: Squad.Member) -> UIView {
		if let existingMemberView = memberViews.first(where: { $0.member.uuid == member.uuid }) {
			return existingMemberView
		} else {
			let state = states[member.uuid]!
			let squadMemberView = GameMemberView(member: member, state: state)
			squadMemberView.memberView.delegate = self
			memberViews.append(squadMemberView)
			
			return squadMemberView
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		// This scrolls all of the members views to a consistent offset (because the scrollview content size depends on the number of tokens show in the state view).
		for memberView in memberViews {
			memberView.contentOffset.x = memberView.stateView.bounds.width - 36
		}
	}
	
}
