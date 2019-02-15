//
//  GameSquadMemberStateView.swift
//  X-Squad
//
//  Created by Avario on 13/02/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class GameSquadMemberStateView: UIStackView {
	
	let state: Game.MemberState
	
	init(member: Squad.Member, state: Game.MemberState) {
		self.state = state
		
		super.init(frame: .zero)
		translatesAutoresizingMaskIntoConstraints = false
		axis = .vertical
		alignment = .trailing
		spacing = 10
		layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
		isLayoutMarginsRelativeArrangement = true
		
		let numberLabel = NumberLabel(number: state.number)
		let costView = CostView()
		costView.cost = member.pointCost
		
		let numbersStackView = UIStackView(arrangedSubviews: [costView, numberLabel])
		numbersStackView.axis = .horizontal
		numbersStackView.spacing = 10
		numbersStackView.alignment = .center
		
		addArrangedSubview(numbersStackView)
		
		if state.hullTokens.isEmpty == false {
			addArrangedSubview(TokenStackView(tokens: state.hullTokens, type: .hull))
		}
		
		if state.shieldTokens.isEmpty == false {
			addArrangedSubview(TokenStackView(tokens: state.shieldTokens, type: .shield))
		}
		
		if state.chargeTokens.isEmpty == false {
			addArrangedSubview(TokenStackView(tokens: state.chargeTokens, type: .charge))
		}
		
		if state.forceTokens.isEmpty == false {
			addArrangedSubview(TokenStackView(tokens: state.forceTokens, type: .force))
		}
	}
	
	required init(coder: NSCoder) {
		fatalError()
	}
	
	class NumberLabel: UILabel {
		static let size: CGFloat = 44
		
		init(number: Int) {
			super.init(frame: .zero)
			translatesAutoresizingMaskIntoConstraints = false
			textAlignment = .center
			textColor = UIColor.white.withAlphaComponent(0.9)
			font = UIFont.kimberley(18)
			text = String(number)
			
			layer.cornerRadius = NumberLabel.size/2
			layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
			layer.borderWidth = 1
			
			heightAnchor.constraint(equalToConstant: NumberLabel.size).isActive = true
			widthAnchor.constraint(equalToConstant: NumberLabel.size).isActive = true
			
			let innerBorderSize = NumberLabel.size - 6
			
			let innerBorder = UIView()
			innerBorder.translatesAutoresizingMaskIntoConstraints = false
			innerBorder.layer.cornerRadius = innerBorderSize/2
			innerBorder.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
			innerBorder.layer.borderWidth = 1
			
			addSubview(innerBorder)
			innerBorder.heightAnchor.constraint(equalToConstant: innerBorderSize).isActive = true
			innerBorder.widthAnchor.constraint(equalToConstant: innerBorderSize).isActive = true
			innerBorder.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
			innerBorder.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError()
		}
	}
}
