//
//  TokenView.swift
//  X-Squad
//
//  Created by Avario on 13/02/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This view displays a token which can be flipped by tapping on it.

import Foundation
import UIKit

class TokenView: UIButton {
	
	enum TokenType {
		case hull
		case shield
		case charge
		case force
		
		var characterCode: String {
			switch self {
			case .hull:
				return "&"
			case .shield:
				return "*"
			case .charge:
				return "g"
			case .force:
				return "h"
			}
		}
		
		var color: UIColor {
			switch self {
			case .hull:
				return UIColor(red: 0.95, green: 0.8, blue: 0.25, alpha: 1.0)
			case .shield:
				return UIColor(red: 0.40, green: 0.77, blue: 0.87, alpha: 1.0)
			case .charge:
				return UIColor(red: 0.87, green: 0.68, blue: 0.11, alpha: 1.0)
			case .force:
				return UIColor(red: 0.61 * 1.2, green: 0.40 * 1.2, blue: 0.66 * 1.2, alpha: 1.0)
			}
		}
		
		var iconSize: CGFloat {
			switch self {
			case .hull:
				return 20
			case .shield:
				return 25
			case .charge:
				return 24
			case .force:
				return 20
			}
		}
	}
	
	// The red color of the icon when it's flipped.
	static let inactiveColor = UIColor(red: 0.91, green: 0.00, blue: 0.12, alpha: 1.0)
	
	let token: Game.Token
	
	// The token is flipped between these two views to change it's state.
	let activeView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
	let inactiveView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
	
	init(token: Game.Token, type: TokenType) {
		self.token = token
		
		super.init(frame: .zero)
		translatesAutoresizingMaskIntoConstraints = false
		
		heightAnchor.constraint(equalToConstant: 44).isActive = true
		widthAnchor.constraint(equalToConstant: 44).isActive = true
		
		addSubview(activeView)
		activeView.isUserInteractionEnabled = false
		
		// The background shape of the token.
		let shapeImageView = UIImageView(image: UIImage(named: "Token Shape")!)
		shapeImageView.tintColor = UIColor(white: 0.15, alpha: 1.0)
		activeView.addSubview(shapeImageView)
		
		// The decorative lines shown on the active side of the token.
		let linesImageView = UIImageView(image: UIImage(named: "Token Lines")!)
		linesImageView.tintColor = type.color
		linesImageView.alpha = 0.7
		activeView.addSubview(linesImageView)
		
		let icon = UILabel(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
		icon.textAlignment = .center
		icon.font = UIFont.xWingIcon(type.iconSize)
		icon.textColor = type.color
		icon.text = type.characterCode
		activeView.addSubview(icon)
		
		addSubview(inactiveView)
		inactiveView.isUserInteractionEnabled = false
		
		let inactiveShapeImageView = UIImageView(image: UIImage(named: "Token Shape")!)
		inactiveShapeImageView.tintColor = UIColor(white: 0.15, alpha: 1.0)
		inactiveView.addSubview(inactiveShapeImageView)
		
		let inactiveIcon = UILabel(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
		inactiveIcon.textAlignment = .center
		inactiveIcon.font = UIFont.xWingIcon(type.iconSize)
		inactiveIcon.textColor = TokenView.inactiveColor
		inactiveIcon.text = type.characterCode
		inactiveView.addSubview(inactiveIcon)
		
		activeView.isHidden = !token.isActive
		inactiveView.isHidden = token.isActive
		
		addTarget(self, action: #selector(flip), for: .touchUpInside)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	@objc func flip() {
		token.isActive.toggle()
		
		let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
		
		UIView.transition(with: self, duration: 0.4, options: transitionOptions, animations: {
			self.activeView.isHidden = !self.token.isActive
			self.inactiveView.isHidden = self.token.isActive
		})
	}
	
}
