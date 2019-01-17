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
	
	static let defaultHeight: CGFloat = 44
	static let circleSize: CGFloat = 24
	
	enum Action {
		case add
		case remove
	}
	
	var action: Action = .add {
		didSet {
			verticalLine.isHidden = (action == .remove)
		}
	}
	
	let circleView = UIView(frame: .zero)
	let verticalLine = UIView(frame: .zero)
	let horizontalLine = UIView(frame: .zero)
	
	private let color = UIColor(named: "XYellow")!
	private let highlightColor = UIColor.white
	
	init(height: CGFloat = defaultHeight) {
		super.init(frame: .zero)
		
		translatesAutoresizingMaskIntoConstraints = false
		heightAnchor.constraint(equalToConstant: height).isActive = true
		
		addSubview(circleView)
		circleView.translatesAutoresizingMaskIntoConstraints = false
		circleView.isUserInteractionEnabled = false
		
		circleView.layer.cornerRadius = SquadButton.circleSize/2
		circleView.layer.borderColor = color.cgColor
		circleView.layer.borderWidth = 1
		
		circleView.heightAnchor.constraint(equalToConstant: SquadButton.circleSize).isActive = true
		circleView.widthAnchor.constraint(equalToConstant: SquadButton.circleSize).isActive = true
		circleView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		circleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		
		circleView.addSubview(horizontalLine)
		horizontalLine.translatesAutoresizingMaskIntoConstraints = false
		horizontalLine.backgroundColor = color
		
		horizontalLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
		horizontalLine.widthAnchor.constraint(equalTo: circleView.widthAnchor, multiplier: 0.5).isActive = true
		horizontalLine.centerXAnchor.constraint(equalTo: circleView.centerXAnchor).isActive = true
		horizontalLine.centerYAnchor.constraint(equalTo: circleView.centerYAnchor).isActive = true
		
		circleView.addSubview(verticalLine)
		verticalLine.translatesAutoresizingMaskIntoConstraints = false
		verticalLine.backgroundColor = color
		
		verticalLine.widthAnchor.constraint(equalToConstant: 1).isActive = true
		verticalLine.heightAnchor.constraint(equalTo: circleView.heightAnchor, multiplier: 0.5).isActive = true
		verticalLine.centerXAnchor.constraint(equalTo: circleView.centerXAnchor).isActive = true
		verticalLine.centerYAnchor.constraint(equalTo: circleView.centerYAnchor).isActive = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	override var intrinsicContentSize: CGSize {
		return CGSize(width: SquadButton.defaultHeight, height: SquadButton.defaultHeight)
	}
	
	override open var isHighlighted: Bool {
		didSet {
			circleView.layer.borderColor = isHighlighted ? highlightColor.cgColor : color.cgColor
			horizontalLine.backgroundColor = isHighlighted ? highlightColor : color
			verticalLine.backgroundColor = isHighlighted ? highlightColor : color
		}
	}
}
