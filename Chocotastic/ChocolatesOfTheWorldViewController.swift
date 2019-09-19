//
// 2019 Giulio Gola
//

import UIKit
import RxSwift
import RxCocoa

class ChocolatesOfTheWorldViewController: UIViewController {
  @IBOutlet private var cartButton: UIBarButtonItem!
  @IBOutlet private var tableView: UITableView!
  
  // europeanChocolates is observable. just(_:) indicates that there won’t be any changes to the underlying value of the Observable, but that you still want to access it as an Observable value.
  let europeanChocolates = Observable.just(Chocolate.ofEurope)
  
  private let disposeBag = DisposeBag()
}

//MARK: View Lifecycle
extension ChocolatesOfTheWorldViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Chocolate!!!"
    
    setupCartObserver()
    setupCellConfiguration()
    setupCellTapHandling()
  }
}

//MARK: - Rx Setup
private extension ChocolatesOfTheWorldViewController {
  
  // Let cart button bar label react to changes in chocolates
  func setupCartObserver() {
    ShoppingCart.sharedCart.chocolates.asObservable()
      .subscribe(onNext: {
        [unowned self] chocolates in
        self.cartButton.title = "\(chocolates.count) 🍫"
      })
      .disposed(by: disposeBag)
  }
  
  // Table view data source
  func setupCellConfiguration() {
    europeanChocolates.bind(to: tableView
      .rx
      .items(
        cellIdentifier: ChocolateCell.Identifier,
        cellType: ChocolateCell.self)) {
          row, chocolate, cell in
          cell.configureWithChocolate(chocolate: chocolate)
      }
      .disposed(by: disposeBag)
  }
  
  // Table view delegate
  func setupCellTapHandling() {
    tableView
      .rx
      .modelSelected(Chocolate.self)
      .subscribe(onNext: { [unowned self] chocolate in
        // Do something with the chocolate object returned by the tapped cell
        let newValue = ShoppingCart.sharedCart.chocolates.value + [chocolate]
        ShoppingCart.sharedCart.chocolates.accept(newValue)
        // Deselect the row
        if let selectedRowIndexPath = self.tableView.indexPathForSelectedRow {
          self.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
        }
      })
      .disposed(by: disposeBag)
  }

}

// MARK: - SegueHandler
extension ChocolatesOfTheWorldViewController: SegueHandler {
  enum SegueIdentifier: String {
    case goToCart
  }
}
