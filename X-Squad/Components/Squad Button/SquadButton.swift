//
//  SquadButton.swift
//  X-Squad
//
//  Created by Avario on 17/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class SquadButton: UIButton {
	
	static let circleSize: CGFloat = 32
	
	enum Action {
		case add(String)
		case remove(String)
	}
	
	var action: Action = .add("") {
		didSet {
			switch action {
			case .add(let text):
				verticalLine.isHidden = false
				label.text = text
			case .remove(let text):
				verticalLine.isHidden = true
				label.text = text
			}
		}
	}
	
	let circleView = UIView()
	let verticalLine = UIView()
	let horizontalLine = UIView()
	let label = UILabel()
	
	private let color = UIColor.white.withAlphaComponent(0.5)
	private let highlightColor = UIColor.white
	
	init() {
		super.init(frame: .zero)
		
		translatesAutoresizingMaskIntoConstraints = false
		
		addSubview(circleView)
		circleView.translatesAutoresizingMaskIntoConstraints = false
		circleView.isUserInteractionEnabled = false
		
		circleView.layer.cornerRadius = SquadButton.circleSize/2
		circleView.layer.borderColor = color.withAlphaComponent(0.2).cgColor
		circleView.layer.borderWidth = 1
		
		circleView.heightAnchor.constraint(equalToConstant: SquadButton.circleSize).isActive = true
		circleView.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
		circleView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
		circleView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
		circleView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
		
		circleView.addSubview(horizontalLine)
		horizontalLine.translatesAutoresizingMaskIntoConstraints = false
		horizontalLine.backgroundColor = color
		
		horizontalLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
		horizontalLine.widthAnchor.constraint(equalToConstant: SquadButton.circleSize * 0.3).isActive = true
		horizontalLine.centerXAnchor.constraint(equalTo: circleView.leftAnchor, constant: SquadButton.circleSize/2).isActive = true
		horizontalLine.centerYAnchor.constraint(equalTo: circleView.centerYAnchor).isActive = true
		
		circleView.addSubview(verticalLine)
		verticalLine.translatesAutoresizingMaskIntoConstraints = false
		verticalLine.backgroundColor = color
		
		verticalLine.widthAnchor.constraint(equalToConstant: 1).isActive = true
		verticalLine.heightAnchor.constraint(equalToConstant: SquadButton.circleSize * 0.3).isActive = true
		verticalLine.centerXAnchor.constraint(equalTo: circleView.leftAnchor, constant: SquadButton.circleSize/2).isActive = true
		verticalLine.centerYAnchor.constraint(equalTo: circleView.centerYAnchor).isActive = true
		
		circleView.addSubview(label)
		label.textColor = color
		label.font = UIFont.systemFont(ofSize: 14)
		
		label.translatesAutoresizingMaskIntoConstraints = false
		label.centerYAnchor.constraint(equalTo: circleView.centerYAnchor).isActive = true
		label.leftAnchor.constraint(equalTo: circleView.leftAnchor, constant: SquadButton.circleSize).isActive = true
		label.rightAnchor.constraint(equalTo: circleView.rightAnchor, constant: -(SquadButton.circleSize/2)).isActive = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	override open var isHighlighted: Bool {
		didSet {
			circleView.layer.borderColor = isHighlighted ? highlightColor.cgColor : color.withAlphaComponent(0.2).cgColor
			horizontalLine.backgroundColor = isHighlighted ? highlightColor : color
			verticalLine.backgroundColor = isHighlighted ? highlightColor : color
			label.textColor = isHighlighted ? highlightColor : color
		}
	}
}
