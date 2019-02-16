//
//  TokenStackView.swift
//  X-Squad
//
//  Created by Avario on 13/02/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This displays a set of tokens of the same type in a horizontal row.

import Foundation
import UIKit

class TokenStackView: UIStackView {
	
	init(tokens: [Game.Token], type: TokenView.TokenType) {
		super.init(frame: .zero)
		spacing = 10
		axis = .horizontal
		
		for token in tokens {
			let tokenView = TokenView(token: token, type: type)
			addArrangedSubview(tokenView)
		}
	}
	
	required init(coder: NSCoder) {
		fatalError()
	}
	
}
