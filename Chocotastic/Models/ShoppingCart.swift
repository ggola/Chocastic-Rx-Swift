//
// 2019 Giulio Gola
//

import Foundation
import RxSwift
import RxCocoa

class ShoppingCart {
  // Shopping Cart singleton
  static let sharedCart = ShoppingCart()
  //BehaviorRelay is a class, so it uses reference semantics => chocolates refers to an instance of BehaviorRelay.
  let chocolates: BehaviorRelay<[Chocolate]> = BehaviorRelay(value: [])
}

//MARK: Non-Mutating Functions
extension ShoppingCart {
  
  // Calculate total cost based on chocolates
  var totalCost: Float {
    return chocolates.value.reduce(0) {
      runningTotal, chocolate in
      return runningTotal + chocolate.priceInDollars
    }
  }
  
  // Constructs list of items to be displayed in table view in CartVC
  var itemsList: [String] {
    guard chocolates.value.count > 0 else {
      return []
    }
    //This returns itemsList
    return constructSet().map {
      chocolate in
      let count: Int = chocolates.value.reduce(0) {
        runningTotal, reduceChocolate in
        if chocolate == reduceChocolate {
          return runningTotal + 1
        }
        return runningTotal
      }
      // For this chocolate (first closure) store the following string in itemStrings: [String]
      return "\(chocolate.countryFlagEmoji)🍫: \(count)"
    }    
  }
  
  // Get item country names ordered alphabetically after reducing the list.
  var itemsNames: [String] {
    guard chocolates.value.count > 0 else {
      return []
    }
    //This returns itemsNames
    return constructSet().map {
      chocolate in
      return chocolate.countryName
    }
  }
  
  // Build item string label 
  var itemCountString: String {
    guard chocolates.value.count > 0 else {
      return "🚫🍫"
    }
    let itemStrings: [String] = constructSet().map {
      chocolate in
      //Count each type count => returns runningTotal
      let count: Int = chocolates.value.reduce(0) {
        runningTotal, reduceChocolate in
        if chocolate == reduceChocolate {
          return runningTotal + 1
        }
        return runningTotal
      }
      //Create string for each element
      return "\(chocolate.countryFlagEmoji)🍫: \(count)"
    }
    //Construct label
    return itemStrings.joined(separator: "\n")
  }
  
  //Unique the chocolates: creates an unordered collection of unique elements (in case some chocolates have been repeatedly tapped), which is then sorted by country name alphabetically
  private func constructSet() -> [Chocolate] {
    return Set<Chocolate>(chocolates.value).sorted { (c1, c2) -> Bool in
      return c1.countryName < c2.countryName
    }
  }
  
  //MARK: Methods to add and remove items when tapping the table view cell in CartVC
  //Add chocolate item
  func addChocolateItem(from country: String) {
    // Find chocolate to add based on all available ones .ofEurope filtered with the country
    let chocolateToAdd = Chocolate.ofEurope.filter { (chocolate) -> Bool in
      return chocolate.countryName == country
    }[0]
    // Add element (as array)
    let newValue = chocolates.value + [chocolateToAdd]
    chocolates.accept(newValue)
  }
  
  // Remove chocolate item
  func removeChocolateItem(from country: String) {
    // Find chocolate object to rmeove based on country name
    let chocolateToRemove = Chocolate.ofEurope.filter { (chocolate) -> Bool in
      return chocolate.countryName == country
    }[0]
    // remove it
    var chocos = chocolates.value
    var index = 0
    for chocolate in chocos {
      if (chocolate == chocolateToRemove) {
        chocos.remove(at: index)
        break
      }
      index += 1
    }
    // update Relay variable
    chocolates.accept(chocos)
  }
  
}
