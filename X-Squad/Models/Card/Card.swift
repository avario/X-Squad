//
//  Card.swift
//  X-Squad
//
//  Created by Avario on 22/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

protocol Card {
	var xws: XWSID { get }
	var name: String { get }
	var limited: Int { get }
	var frontImage: URL? { get }
	var backImage: URL? { get }
	var hyperspace: Bool? { get }
	var orientation: CardOrientation { get }
}

enum CardOrientation {
	case portrait
	case landscape
}

extension Card {
	func pointCost(for member: Squad.Member? = nil) -> Int {
		switch self {
		case let pilot as Pilot:
			return pilot.cost ?? 0
		case let upgrade as Upgrade:
			guard let cost = upgrade.cost else {
				return 0
			}
			
			switch cost {
			case .constant(let cost):
				return cost
			case .variable(let variable):
				guard let member = member else {
					return 0
				}
				
				switch variable {
				case .size(let sizeValues):
					return sizeValues[member.pilot.ship!.size]!
				
				case .agility(let agilityValues):
					let agility = member.pilot.ship!.stats.first(where: { $0.type == .agility })!
					return agilityValues[Upgrade.Cost.Variable.Agility(rawValue: String(agility.value))!]!
					
				case .initiative(let initiativeValues):
					let initiative = member.pilot.initiative
					return initiativeValues[Upgrade.Cost.Variable.Initiative(rawValue: String(initiative))!]!
				}
			}
		default:
			fatalError()
		}
	}
	
	var isReleased: Bool {
		switch self {
		case let pilot as Pilot:
			return pilot.cost != nil
		case let upgrade as Upgrade:
			return upgrade.cost != nil
		default:
			fatalError()
		}
	}
	
	func matches(_ card: Card) -> Bool {
		if let upgrade = self as? Upgrade,
			let upgradeToMatch = card as? Upgrade,
			upgrade == upgradeToMatch  {
			return true
			
		} else if let pilot = self as? Pilot,
			let pilotToMatch = card as? Pilot,
			pilot == pilotToMatch {
			return true
		}
		return false
	}
	
	var placeholderImage: UIImage {
		let cardLength: CGFloat = 500
		
		let size: CGSize
		switch orientation {
		case .landscape:
			size = CGSize(width: CardView.sizeRatio * cardLength, height: cardLength)
		case .portrait:
			size = CGSize(width: cardLength, height: CardView.sizeRatio * cardLength)
		}
		
		UIGraphicsBeginImageContextWithOptions(size, true, 2.0)
		let context = UIGraphicsGetCurrentContext()!
		
		UIColor.init(white: 0.1, alpha: 1.0).setFill()
		context.fill(CGRect(origin: .zero, size: size))
		
		let padding: CGFloat = 30
		let contentInsets: UIEdgeInsets
		let text: String
		
		switch self {
		case let pilot as Pilot:
			contentInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
			text = pilot.ability ?? pilot.text ?? ""
			
		case let upgrade as Upgrade:
			switch upgrade.frontSide.type {
			case .configuration:
				contentInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: size.width * CardView.upgradeHiddenRatio + padding)
			default:
				contentInsets = UIEdgeInsets(top: padding, left: size.width * CardView.upgradeHiddenRatio + padding, bottom: 30, right: padding)
			}
			
			text = upgrade.frontSide.ability ?? upgrade.frontSide.text ?? ""
		default:
			fatalError()
		}
		
		let title = NSAttributedString(
			string: name,
			attributes: [
				.foregroundColor: UIColor.white,
				.font: UIFont.boldSystemFont(ofSize: 32)])
		
		let titleHeight: CGFloat = 50
		title.draw(in: CGRect(
			x: contentInsets.left,
			y: contentInsets.top,
			width: size.width - contentInsets.left - contentInsets.right,
			height: titleHeight))
		
		let description = NSMutableAttributedString(
			string: text,
			attributes: [
				.foregroundColor: UIColor.white,
				.font: UIFont.systemFont(ofSize: 32)])
		
		// Replace symbol keywords with actual symbols
		let symbols: [String: String] = [
			"Boost": "b",
			"Critical Hit": "c",
			"Hit": "d",
			"Evade": "e",
			"Focus": "f",
			"Reinforce": "i",
			"Cloak": "k",
			"Lock": "l",
			"Coordinate": "o",
			"Barrel Roll": "r",
			"Slam": "s",
			"Jam": "j",
			"Calculate": "a",
			"Reload": "=",
			
			"Force": "h",
			"Charge": "g",
			
			"Segnor's Loop Left": "1",
			"Koiogran Turn": "2",
			"Segnor's Loop Right": "3",
			"Turn Left": "4",
			"Stop": "5",
			"Turn Right": "6",
			"Bank Left": "7",
			"Straight": "8",
			"Bank Right": "9",
			"Tallon Roll Left": ":",
			"Tallon Roll Right": ";",
			
			"Talent": "E",
			"Astromech" : "A",
			"Torpedo": "P",
			"Missile": "M",
			"Cannon": "C",
			"Turret": "U",
			"Device": "B",
			"Crew": "W",
			"Sensor": "S",
			"Modification": "m",
			"Illicit": "I",
			"Title": "t",
			"Tech": "X",
			"Gunner": "Y",
			"Force Power": "F",
			"Configuration": "n",
			"Tactical Relay": "Z"
		]
		
		// Set symbol font
		for key in symbols.keys {
			var searchStartIndex = text.startIndex
			
			while searchStartIndex < text.endIndex,
				let range = text.range(of: "[\(key)]", range: searchStartIndex..<text.endIndex),
				range.isEmpty == false {
					description.addAttribute(.font, value: UIFont.xWingIcon(30), range: NSRange(range, in: text))
					searchStartIndex = range.upperBound
			}
		}
		
		// Replace keyword with character
		for (key, character) in symbols {
			description.mutableString.replaceOccurrences(of: "[\(key)]", with: character, range: NSRange(location: 0, length: description.mutableString.length))
		}
		
		description.draw(in: CGRect(
			x: contentInsets.left,
			y: contentInsets.top + titleHeight + padding,
			width: size.width - contentInsets.left - contentInsets.right,
			height: size.height - titleHeight - padding - contentInsets.top - contentInsets.bottom))
		
		let image = UIGraphicsGetImageFromCurrentImageContext()!
		
		UIGraphicsEndImageContext()
		
		return image
	}
}

extension Pilot: Card {
	var frontImage: URL? {
		return image
	}
	
	var backImage: URL? {
		return nil
	}
	
	var orientation: CardOrientation { return .portrait }
}

extension Upgrade: Card {
	var frontImage: URL? {
		return frontSide.image
	}
	
	var backImage: URL? {
		return backSide?.image
	}
	
	var orientation: CardOrientation { return .landscape }
}
