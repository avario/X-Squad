//
//  XButton.swift
//  X-Squad
//
//  Created by Avario on 14/02/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// A simple rounded button with a border.

import Foundation
import UIKit

class XButton: UIButton {
	
	var circleSize: CGFloat = 32
	
	let circleView = UIView()
	
	private let color = UIColor.white.withAlphaComponent(0.5)
	private let highlightColor = UIColor.white
	
	init() {
		super.init(frame: .zero)
		
		translatesAutoresizingMaskIntoConstraints = false
		
		addSubview(circleView)
		circleView.translatesAutoresizingMaskIntoConstraints = false
		circleView.isUserInteractionEnabled = false
		
		circleView.layer.cornerRadius = circleSize/2
		circleView.layer.borderColor = color.withAlphaComponent(0.2).cgColor
		circleView.layer.borderWidth = 1
		
		circleView.heightAnchor.constraint(equalToConstant: circleSize).isActive = true
		circleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		circleView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		circleView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		
		titleLabel?.font = UIFont.systemFont(ofSize: 14)
		setTitleColor(color, for: .normal)
		setTitleColor(highlightColor, for: .highlighted)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	override open var isHighlighted: Bool {
		didSet {
			circleView.layer.borderColor = isHighlighted ? highlightColor.cgColor : color.withAlphaComponent(0.2).cgColor
		}
	}
	
	override var intrinsicContentSize: CGSize {
		return CGSize(width: 58, height: circleSize)
	}
}
