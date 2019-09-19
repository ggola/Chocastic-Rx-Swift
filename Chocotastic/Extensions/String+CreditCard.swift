//
// 2019 Giulio Gola
//

import Foundation

extension String {
  var areAllCharactersNumbers: Bool {
    let nonNumberCharacterSet = CharacterSet.decimalDigits.inverted
    return (rangeOfCharacter(from: nonNumberCharacterSet) == nil)
  }
  
  // Luhn Test for credit cart number validity https://www.rosettacode.org/wiki/Luhn_test_of_credit_card_numbers
  var isLuhnValid: Bool {
    
    guard areAllCharactersNumbers else {
      //Definitely not valid.
      return false
    }
    
    let reversed = self.reversed().map { String($0) }
    
    var sum = 0
    for (index, element) in reversed.enumerated() {
      guard let digit = Int(element) else {
        //This is not a number.
        return false
      }
      
      // does not distinguish between s1 and s2 but sums them up together in some
      if index % 2 == 1 {
        //Even digit (because index starts from 0...)
        switch digit {
        case 9:
          //Just add nine.
          sum += 9
        default:
          //Multiply by 2, then take the remainder when divided by 9 to get addition of digits.
          sum += ((digit * 2) % 9)
        }
      } else {
        //Odd digit
        sum += digit
      }
    }
    
    //Valid if divisible by 10
    return sum % 10 == 0
  }
  
  var removingSpaces: String {
    return replacingOccurrences(of: " ", with: "")
  }
  
  func integerValue(ofFirstCharacters count: Int) -> Int? {
    guard areAllCharactersNumbers, count <= self.count else {
      return nil
    }
    
    let substring = prefix(count)
    guard let integerValue = Int(substring) else {
      return nil
    }
    
    return integerValue
  }
}
