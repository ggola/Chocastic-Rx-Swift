//
// 2019 Giulio Gola
//


import UIKit

enum ImageName: String {
  case
  amex,
  discover,
  mastercard,
  visa,
  unknownCard
  
  var image: UIImage? {
    guard let image = UIImage(named: rawValue) else {
      return nil
    }
    
    return image
  }
}
