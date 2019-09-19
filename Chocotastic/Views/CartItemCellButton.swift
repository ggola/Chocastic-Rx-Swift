//
// 2019 Giulio Gola
//

import UIKit

class CartItemCellButton {
  
  static func styleButton(for button: UIButton) -> UIButton {
    button.layer.cornerRadius = button.bounds.height / 2
    button.layer.borderWidth = 1.0
    button.layer.borderColor = UIColor.darkGray.cgColor
    button.isHighlighted = false
    return button
  }
  
}
