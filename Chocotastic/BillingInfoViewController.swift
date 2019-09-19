//
// 2019 Giulio Gola
//

import UIKit
import RxSwift
import RxCocoa

class BillingInfoViewController: UIViewController {
  @IBOutlet private var creditCardNumberTextField: ValidatingTextField!
  @IBOutlet private var creditCardImageView: UIImageView!
  @IBOutlet private var expirationDateTextField: ValidatingTextField!
  @IBOutlet private var cvvTextField: ValidatingTextField!
  @IBOutlet private var purchaseButton: UIButton!
  
  // Tells that cardType is an observable property
  private let cardType: BehaviorRelay<CardType> = BehaviorRelay(value: .unknown)
  private let disposeBag = DisposeBag()
  
  // Don't validate at every single digit change, as it can lag the UI. Define throttling interval and validate at every throttling interval. Throttling is a specialty of RxSwift since there’s often a fair amount of logic to be run when something changes.
  private let throttleIntervalInMilliseconds = 100

}

// MARK: - View Lifecycle
extension BillingInfoViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "💳 Info"
    
    setupCardImageDisplay()
    setupTextChangeHandling()

  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let identifier = self.identifier(forSegue: segue)
    switch identifier {
    case .purchaseSuccess:
      guard let destination = segue.destination as? ChocolateIsComingViewController else {
        assertionFailure("Couldn't get chocolate is coming VC!")
        return
      }
      destination.cardType = cardType.value
    }
  }
}

//MARK: - RX Setup
private extension BillingInfoViewController {
  
  // Let users see what type of credit card they’re inputting based on known card types.
  func setupCardImageDisplay() {
    cardType
      .asObservable()
      .subscribe(onNext: { [unowned self] cardType in
        // Do something with cardType when it changes
        self.creditCardImageView.image = cardType.image
      })
      .disposed(by: disposeBag)
  }
  
  // Card validation with Rx
  func setupTextChangeHandling() {
    
    // Return the the contents of the text field as an Observable value. text is RxCocoa extension to UITextField.
    let creditCardValid = creditCardNumberTextField
      .rx
      .text
      // The scheduler parameter is tied to a thread. To keep everything on the main thread, use MainScheduler.
      .observeOn(MainScheduler.asyncInstance)
      .distinctUntilChanged()
      .throttle(.milliseconds(throttleIntervalInMilliseconds), scheduler: MainScheduler.instance)
      .map { [unowned self] in
        self.validate(cardText: $0)  // $0 = first closure parameter
      }
    // creditCardValid is Observable<Bool> (true/false based on valudate)
    creditCardValid
      .subscribe(onNext: { [unowned self] isValid in
        self.creditCardNumberTextField.valid = isValid  // can also use $0
      })
      .disposed(by: disposeBag)
    
    // Validate Expiration Date - same procedure
    let expirationValid = expirationDateTextField
      .rx
      .text
      .observeOn(MainScheduler.asyncInstance)
      .distinctUntilChanged()
      .throttle(.milliseconds(throttleIntervalInMilliseconds), scheduler: MainScheduler.instance)
      .map { [unowned self] in
        self.validate(expirationDateText: $0)
    }
    expirationValid
      .subscribe(onNext: { [unowned self] in
        self.expirationDateTextField.valid = $0
      })
      .disposed(by: disposeBag)
    
    // Validate CVV - same procedure
    let cvvValid = cvvTextField
      .rx
      .text
      .observeOn(MainScheduler.asyncInstance)
      .distinctUntilChanged()
      .map { [unowned self] in
        self.validate(cvvText: $0)
    }
    cvvValid
      .subscribe(onNext: { [unowned self] in
        self.cvvTextField.valid = $0
      })
      .disposed(by: disposeBag)
    
    // Check all 3 observalbles are valid
    let everythingValid = Observable
      .combineLatest(creditCardValid, expirationValid, cvvValid) {
        $0 && $1 && $2 //All must be true
    }
    //everythingValid’s value controls the state of the purchase button.
    everythingValid
      .bind(to: purchaseButton.rx.isEnabled)
      .disposed(by: disposeBag)

  }
}

//MARK: - Validation methods
private extension BillingInfoViewController {
  func validate(cardText: String?) -> Bool {
    guard let cardText = cardText else {
      return false
    }
    let noWhitespace = cardText.removingSpaces
    
    updateCardType(using: noWhitespace)
    formatCardNumber(using: noWhitespace)
    advanceIfNecessary(noSpacesCardNumber: noWhitespace)
    
    guard cardType.value != .unknown else {
      //Definitely not valid if the type is unknown.
      return false
    }
    
    guard noWhitespace.isLuhnValid else {
      //Failed luhn validation
      return false
    }
    
    return noWhitespace.count == cardType.value.expectedDigits
  }
  
  func validate(expirationDateText expiration: String?) -> Bool {
    guard let expiration = expiration else {
      return false
    }
    let strippedSlashExpiration = expiration.removingSlash
    
    formatExpirationDate(using: strippedSlashExpiration)
    advanceIfNecessary(expirationNoSpacesOrSlash: strippedSlashExpiration)
    
    return strippedSlashExpiration.isExpirationDateValid
  }
  
  func validate(cvvText cvv: String?) -> Bool {
    guard let cvv = cvv else {
      return false
    }
    guard cvv.areAllCharactersNumbers else {
      //Someone snuck a letter in here.
      return false
    }
    dismissIfNecessary(cvv: cvv)
    return cvv.count == cardType.value.cvvDigits
  }
}

//MARK: Single-serve helper functions
private extension BillingInfoViewController {
  func updateCardType(using noSpacesNumber: String) {
    cardType.accept(CardType.fromString(string: noSpacesNumber))
  }
  
  func formatCardNumber(using noSpacesCardNumber: String) {
    creditCardNumberTextField.text = cardType.value.format(noSpaces: noSpacesCardNumber)
  }
  
  func advanceIfNecessary(noSpacesCardNumber: String) {
    if noSpacesCardNumber.count == cardType.value.expectedDigits {
      expirationDateTextField.becomeFirstResponder()
    }
  }
  
  func formatExpirationDate(using expirationNoSpacesOrSlash: String) {
    expirationDateTextField.text = expirationNoSpacesOrSlash.addingSlash
  }
  
  func advanceIfNecessary(expirationNoSpacesOrSlash: String) {
    if expirationNoSpacesOrSlash.count == 6 { //mmyyyy
      cvvTextField.becomeFirstResponder()
    }
  }
  
  func dismissIfNecessary(cvv: String) {
    if cvv.count == cardType.value.cvvDigits {
      let _ = cvvTextField.resignFirstResponder()
    }
  }
}

// MARK: - SegueHandler
extension BillingInfoViewController: SegueHandler {
  enum SegueIdentifier: String {
    case purchaseSuccess
  }
}

