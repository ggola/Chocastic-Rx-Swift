//
// 2019 Giulio Gola
//

import UIKit

// Delegate to handle button pressed on the cell
protocol CartItemCellDelegate: AnyObject {
  func addPressed(cell: CartItemCell)
  func removePressed(cell: CartItemCell)
}

class CartItemCell: UITableViewCell {
  static let Identifier = "CartItemCell"
  
  @IBOutlet private var emojiLabel: UILabel!
  @IBOutlet private var addButton: UIButton!
  @IBOutlet private var removeButton: UIButton!
  
  var delegate: CartItemCellDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    styleButtons()
  }
  
  private func styleButtons() {
    
    addButton = CartItemCellButton.styleButton(for: addButton)
    removeButton = CartItemCellButton.styleButton(for: removeButton)
  }
  
  func configureWith(chocolateItem: String) {
    emojiLabel.text = chocolateItem
  }
  
  @IBAction func addButtonPressed(_ sender: UIButton) {
    animateBackgroundColor(button: sender)
    // Tells the delegate that the add or remove button has been pressed on the current cell.
    sender.tag == 0 ? delegate?.addPressed(cell: self) : delegate?.removePressed(cell: self)
  }
  
  func animateBackgroundColor(button: UIButton) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
      button.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        button.backgroundColor = UIColor.white
      }
    }
  }
  
}
