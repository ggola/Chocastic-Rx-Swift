//
// 2019 Giulio Gola
//

import UIKit
import RxSwift
import RxCocoa

class CartViewController: UIViewController {
  @IBOutlet private var checkoutButton: UIButton!
  @IBOutlet private var itemsList: UITableView!
  @IBOutlet private var totalCostLabel: UILabel!
  @IBOutlet private var itemListHeightConstraint: NSLayoutConstraint!
  
  // Make chocolatesInCart and chocolatesInCartCountryNames obserable: they are observed by the table view, and they subscribe as observes of chocolates.
  let chocolatesInCart: BehaviorRelay<[String]> = BehaviorRelay(value: [])
  let chocolatesInCartCountryNames: BehaviorRelay<[String]> = BehaviorRelay(value: [])
  
  let cart = ShoppingCart.sharedCart
  let disposeBag = DisposeBag()
}

//MARK: - View lifecycle
extension CartViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Cart"
    
    itemsList.rowHeight = 60
    itemsList.separatorStyle = .none

    setupCartObserver()
    setupCellConfiguration()
    setupCellTapHandling()
  }
  
}

//MARK: - IBActions
extension CartViewController {
  @IBAction func reset() {
    ShoppingCart.sharedCart.chocolates.accept([])
    let _ = navigationController?.popViewController(animated: true)
  }
}

extension CartViewController: CartItemCellDelegate {
  
  func addPressed(cell: CartItemCell) {
    let indexPath = self.itemsList.indexPath(for: cell)
    cart.addChocolateItem(from: chocolatesInCartCountryNames.value[indexPath!.row])
  }
  
  func removePressed(cell: CartItemCell) {
    let indexPath = self.itemsList.indexPath(for: cell)
    cart.removeChocolateItem(from: chocolatesInCartCountryNames.value[indexPath!.row])
  }
  
}

// Rx Setup
private extension CartViewController {
  
  // Make totalCostLabel, chocolatesInCart and chocolatesInCartCountryNames observers of chocolates
  func setupCartObserver() {
    
    guard checkoutButton != nil else {
      //UI has not been instantiated yet. Bail!
      return
    }
    
    ShoppingCart.sharedCart.chocolates.asObservable().subscribe(onNext: { [unowned self] chocolates in
      
      // totalCostLabel reaction
      let newCost = self.cart.totalCost
      self.totalCostLabel.text = CurrencyFormatter.dollarsFormatter.string(from: newCost)
      //Disable checkout if there's nothing to check out with
      self.checkoutButton.isEnabled = (newCost > 0)
      
      // chocolatesInCart reaction
      let newItemsList = self.cart.itemsList
      self.chocolatesInCart.accept(newItemsList)
      // Set itemList table view height to fit the content
      self.itemListHeightConstraint.constant = self.itemsList.rowHeight * CGFloat(self.chocolatesInCart.value.count)
      
      // chocolatesInCartCountryNames reaction
      let newCountryNames = self.cart.itemsNames
      self.chocolatesInCartCountryNames.accept(newCountryNames)
      
    }).disposed(by: disposeBag)
  }
  
  
  // Make Table view reactive
  // Table view data source
  func setupCellConfiguration() {
    chocolatesInCart.bind(to: itemsList
      .rx
      .items(
        cellIdentifier: CartItemCell.Identifier,
        cellType: CartItemCell.self)) {
          row, item, cell in
          cell.delegate = self
          cell.configureWith(chocolateItem: item)
      }
      .disposed(by: disposeBag)
  }
  
  // Table view delegate
  func setupCellTapHandling() {
    itemsList
      .rx
      .modelSelected(String.self)
      .subscribe(onNext: { [unowned self] item in
        // Deselect the row
        if let selectedRowIndexPath = self.itemsList.indexPathForSelectedRow {
          self.itemsList.deselectRow(at: selectedRowIndexPath, animated: false)
        }
      })
      .disposed(by: disposeBag)
  }

}

//// MARK: - SegueHandler
//extension CartViewController: SegueHandler {
//  enum SegueIdentifier: String {
//    case ToCheckout
//  }
//}
