//
// 2019 Giulio Gola
//


import Foundation

//MARK: - Mmmm...chocolate...
struct Chocolate: Equatable, Hashable {
  let priceInDollars: Float
  let countryName: String
  let countryFlagEmoji: String
  
  static let belgian = Chocolate(priceInDollars: 8,
                          countryName: "Belgium",
                          countryFlagEmoji: "🇧🇪")
  
  static let british = Chocolate(priceInDollars: 7,
                          countryName: "Great Britain",
                          countryFlagEmoji: "🇬🇧")
  
  static let dutch = Chocolate(priceInDollars: 8,
                        countryName: "The Netherlands",
                        countryFlagEmoji: "🇳🇱")
  
  static let german = Chocolate(priceInDollars: 7,
                         countryName: "Germany",
                         countryFlagEmoji: "🇩🇪")
  
  static let swiss = Chocolate(priceInDollars: 10,
                        countryName: "Switzerland",
                        countryFlagEmoji: "🇨🇭")
  
  // An array of chocolate from europe
  static let ofEurope: [Chocolate] = [belgian, german, british, swiss, dutch]
}
