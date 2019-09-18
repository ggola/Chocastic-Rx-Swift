/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import RxSwift
import RxCocoa

class ChocolatesOfTheWorldViewController: UIViewController {
  @IBOutlet private var cartButton: UIBarButtonItem!
  @IBOutlet private var tableView: UITableView!
  
  // update the europeanChocolates property to be an Observable. just(_:) indicates that there won’t be any changes to the underlying value of the Observable, but that you still want to access it as an Observable value.
  // Note: Sometimes, calling just(_:) is an indication that using reactive programming might be overkill. After all, if a value never changes, why use a programming technique designed to react to changes? In this example, you’re using it to set up reactions of table view cells that will change.
  //let europeanChocolates = Chocolate.ofEurope
  let europeanChocolates = Observable.just(Chocolate.ofEurope)
  
  private let disposeBag = DisposeBag()
}

//MARK: View Lifecycle
extension ChocolatesOfTheWorldViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Chocolate!!!"
    
//    tableView.dataSource = self
//    tableView.delegate = self
    
    setupCartObserver()
    setupCellConfiguration()
    setupCellTapHandling()
  }
  
//  override func viewWillAppear(_ animated: Bool) {
//    super.viewWillAppear(animated)
//    //updateCartButton()
//  }
}

//MARK: - Rx Setup
private extension ChocolatesOfTheWorldViewController {
  
  // Add observable to the cart
  func setupCartObserver() {
    // Grab the shopping cart as an observable
    ShoppingCart.sharedCart.chocolates.asObservable()
      .subscribe(onNext: {
        // Observe changes in chocolates array
        [unowned self] chocolates in
        // Closure: do the following when you see a change
        // chocolates is the new value of the observable.
        // NOTE: You’ll keep getting these notifications until you either unsubscribe or dispose of your subscription. What you get back from this method is an Observer conforming to Disposable.
        self.cartButton.title = "\(chocolates.count) 🍫"
      })
      // Add the Observer from the previous step to your disposeBag. This disposes of your subscription upon deallocating the subscribing object.
      .disposed(by: disposeBag)
  }
  
  // Table view data source
  func setupCellConfiguration() {
    // Call bind(to:) to associate the europeanChocolates observable with the code that executes each row in the table view.
    europeanChocolates.bind(to: tableView
      // By calling rx, you access the RxCocoa extensions for the relevant class. In this case, it’s a UITableView.
      .rx
      // Call the Rx method items(cellIdentifier:cellType:), passing in the cell identifier and the class of the cell type you want to use. The Rx framework calls the dequeuing methods as though your table view had its original data source.
      .items(
        cellIdentifier: ChocolateCell.Identifier,
        cellType: ChocolateCell.self)) {
          // Pass in a block for each new item. Information about the row, the chocolate at that row and the cell will return.
          // NOTE: This closure effectively replaces tableView(_:cellForRowAt:).
          row, chocolate, cell in
          cell.configureWithChocolate(chocolate: chocolate)
      }
      // Take the Disposable returned by bind(to:) and add it to the disposeBag.
      .disposed(by: disposeBag)
  }
  
  // Table view delegate
  func setupCellTapHandling() {
    // Call the table view’s reactive extension’s modelSelected(_:), passing in the Chocolate model type to get the proper type of item back in the following closure. This returns an Observable.
    tableView
      .rx
      .modelSelected(Chocolate.self)
      // Taking that Observable, call subscribe(onNext:), passing in a closure of what should be done any time a model (chocolate: Chocolate) is selected (i.e., a cell is tapped).
      .subscribe(onNext: { [unowned self] chocolate in
        // Add chocolate to the cart
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

//MARK: - Imperative methods
//private extension ChocolatesOfTheWorldViewController {
//  func updateCartButton() {
//    cartButton.title = "\(ShoppingCart.sharedCart.chocolates.value.count) 🍫"
//  }
//}


// NOTE: RxCocoa has reactive APIs for several different types of UI elements. These allow you to create table views without overriding delegate or data source methods.
// MARK: - Table view data source
//extension ChocolatesOfTheWorldViewController: UITableViewDataSource {
//  func numberOfSections(in tableView: UITableView) -> Int {
//    return 1
//  }
//
//  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    return europeanChocolates.count
//  }
//
//  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    guard let cell = tableView.dequeueReusableCell(withIdentifier: ChocolateCell.Identifier, for: indexPath) as? ChocolateCell else {
//      //Something went wrong with the identifier.
//      return UITableViewCell()
//    }
//
//    let chocolate = europeanChocolates[indexPath.row]
//    cell.configureWithChocolate(chocolate: chocolate)
//
//    return cell
//  }
//}

// MARK: - Table view delegate
//extension ChocolatesOfTheWorldViewController: UITableViewDelegate {
//  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    tableView.deselectRow(at: indexPath, animated: true)
//
//    let chocolate = europeanChocolates[indexPath.row]
//    //ShoppingCart.sharedCart.chocolates.append(chocolate)
//    let newValue =  ShoppingCart.sharedCart.chocolates.value + [chocolate]
//    ShoppingCart.sharedCart.chocolates.accept(newValue)
//    //updateCartButton()
//  }
//}

// MARK: - SegueHandler
extension ChocolatesOfTheWorldViewController: SegueHandler {
  enum SegueIdentifier: String {
    case goToCart
  }
}
