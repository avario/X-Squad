//
//  Fonts.swift
//  X-Squad
//
//  Created by Avario on 08/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
	static func xWingIcon(_ size: CGFloat) -> UIFont {
		return UIFont(name: "x-wing-symbols", size: size)!
	}
	
	static func xWingShip(_ size: CGFloat) -> UIFont {
		return UIFont(name: "x-wing-ships", size: size)!
	}
	
	static func kimberley(_ size: CGFloat) -> UIFont {
		return UIFont(name: "Kimberley", size: size)!
	}
	
	static func bankGothic(_ size: CGFloat) -> UIFont {
		return UIFont(name: "BankGothic", size: size)!
	}
	
	static func bankGothicBold(_ size: CGFloat) -> UIFont {
		return UIFont(name: "BankGothic-Bold", size: size)!
	}
	
	static func eurostile(_ size: CGFloat) -> UIFont {
		return UIFont(name: "EurostileLTStd-Cn", size: size)!
	}
	
	static func eurostileBlack(_ size: CGFloat) -> UIFont {
		return UIFont(name: "Eurostile-Black", size: size)!
	}
	
	static func eurostileOblique(_ size: CGFloat) -> UIFont {
		return UIFont(name: "EurostileLTStd-Oblique", size: size)!
	}
}
