//
// 2019 Giulio Gola
//


import Foundation

extension Date {
  var year: Int {
    return Calendar(identifier: .gregorian).component(.year, from: self)
  }
  
  var month: Int {
    return Calendar(identifier: .gregorian).component(.month, from: self)
  }
}
