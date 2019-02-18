//
//  DialView.swift
//  X-Squad
//
//  Created by Avario on 31/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This view displays the dial of maneuvers for a ship.

import Foundation
import UIKit

class DialView: UIStackView {
	
	init(ship: Ship) {
		super.init(frame: .zero)
		
		translatesAutoresizingMaskIntoConstraints = false
		axis = .vertical
		
		// These are all of the forward direction maneuvers (which define the columns for the maneuver table from left to right).
		let forwardBearings: [Ship.Maneuver.Bearing] = [
			.tallonRollLeft,
			.segnorsLoopLeft,
			.turnLeft,
			.bankLeft,
			.straight,
			.bankRight,
			.turnRight,
			.segnorsLoopRight,
			.tallonRollRight,
			.koiogranTurn]
		
		let cellSize: CGFloat = 24
		
		// The speed of the maneuvers define the rows of the maneuver table.
		for speed in -2...5 {
			guard ship.dial.contains(where: { $0.realSpeed == speed }) else {
				// Don't do anything for rows (speeds) that the ship has no maneuvers for.
				continue
			}
			
			let row = UIStackView()
			row.axis = .horizontal
			
			let speedLabel = UILabel()
			speedLabel.textColor = UIColor.white.withAlphaComponent(0.5)
			speedLabel.font = .kimberley(16)
			speedLabel.text = String(speed)
			speedLabel.textAlignment = .center
			speedLabel.translatesAutoresizingMaskIntoConstraints = false
			speedLabel.heightAnchor.constraint(equalToConstant: cellSize).isActive = true
			speedLabel.widthAnchor.constraint(equalToConstant: cellSize).isActive = true
			
			row.addArrangedSubview(speedLabel)
			
			for bearing in forwardBearings {
				var cellManeuver: Ship.Maneuver? = nil
				
				// Check if the ship has the maneuver for the current speed/bearing (row/column).
				switch speed {
				case -2, -1:
					var reverseBearing: Ship.Maneuver.Bearing? = nil
					switch bearing {
					case .bankLeft:
						reverseBearing = .reverseBankLeft
					case .straight:
						reverseBearing = .reverse
					case .bankRight:
						reverseBearing = .reverseBankRight
					default:
						break
					}
					
					if let reverseBearing = reverseBearing, let maneuver = ship.dial.first(where: { $0.bearing == reverseBearing && $0.realSpeed == speed }) {
						cellManeuver = maneuver
					}
				case 0:
					if bearing == .straight, let stationary = ship.dial.first(where: { $0.bearing == .stationary }) {
						cellManeuver = stationary
					}
				default:
					if let maneuver = ship.dial.first(where: { $0.bearing == bearing && $0.speed == speed }) {
						cellManeuver = maneuver
					}
				}
				
				if let maneuver = cellManeuver {
					// If the ship has the maneuver of the current speed/bearing (row/column) add an icon to the table for it.
					let maneuverLabel = UILabel()
					maneuverLabel.textAlignment = .center
					maneuverLabel.text = maneuver.bearing.characterCode
					maneuverLabel.translatesAutoresizingMaskIntoConstraints = false
					maneuverLabel.heightAnchor.constraint(equalToConstant: cellSize).isActive = true
					maneuverLabel.widthAnchor.constraint(equalToConstant: cellSize).isActive = true
					maneuverLabel.font = UIFont.xWingIcon(20)
					
					switch maneuver.difficulty {
					case .blue:
						maneuverLabel.textColor = UIColor(named: "XBlue")
					case .red:
						maneuverLabel.textColor = UIColor(named: "XRed")
					case .white:
						maneuverLabel.textColor = .white
					}
					
					row.addArrangedSubview(maneuverLabel)
					
				} else if ship.dial.contains(where: { $0.bearing == bearing }) {
					// Even if the ship does not have the exact maneuver, insert an empty view if it has any maneuver for the bearing (column) so that the maneuvers will be spaced poroperly.
					let emptyView = UIView()
					emptyView.translatesAutoresizingMaskIntoConstraints = false
					emptyView.heightAnchor.constraint(equalToConstant: cellSize).isActive = true
					emptyView.widthAnchor.constraint(equalToConstant: cellSize).isActive = true
					
					row.addArrangedSubview(emptyView)
				}
			}
			
			insertArrangedSubview(row, at: 0)
		}
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

extension Ship.Maneuver {
	// Speeds for reverse maneuvers are recorded as positive so they need to be converted to get their "real" speed.
	var realSpeed: Int {
		if bearing.isReverse {
			return speed * -1
		} else {
			return speed
		}
	}
}

extension Ship.Maneuver.Bearing {
	var isReverse: Bool {
		switch self {
		case .reverse, .reverseBankLeft, .reverseBankRight:
			return true
		default:
			return false
		}
	}
}
