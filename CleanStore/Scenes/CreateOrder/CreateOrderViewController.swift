//
//  CreateOrderViewController.swift
//  CleanStore
//
//  Created by Raymond Law on 8/22/15.
//  Copyright (c) 2015 Raymond Law. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so you can apply
//  clean architecture to your iOS and Mac projects, see http://clean-swift.com
//

import UIKit

protocol CreateOrderViewControllerInput {
  func displayExpirationDate(viewModel: CreateOrder_FormatExpirationDate_ViewModel)
}

protocol CreateOrderViewControllerOutput {
  var shippingMethods: [String] { get }
  func formatExpirationDate(request: CreateOrder_FormatExpirationDate_Request)
}

class CreateOrderViewController: UITableViewController, CreateOrderViewControllerInput, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
  var output: CreateOrderViewControllerOutput!
  var router: CreateOrderRouter!
  
  // MARK: Object lifecycle
  
  override func awakeFromNib()
  {
    super.awakeFromNib()
    CreateOrderConfigurator.sharedInstance.configure(self)
  }
  
  // MARK: View lifecycle
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    configurePickers()
  }
  
  // MARK: Text fields
  
  @IBOutlet var textFields: [UITextField]!
  
  func textFieldShouldReturn(textField: UITextField) -> Bool
  {
    textField.resignFirstResponder()
    if let index = textFields.indexOf(textField) {
      if index < textFields.count - 1 {
        let nextTextField = textFields[index + 1]
        nextTextField.becomeFirstResponder()
      }
    }
    return true
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
  {
    if let cell = tableView.cellForRowAtIndexPath(indexPath) {
      for textField in textFields {
        if textField.isDescendantOfView(cell) {
          textField.becomeFirstResponder()
        }
      }
    }
  }
  
  // MARK: Shipping method
  
  @IBOutlet weak var shippingMethodTextField: UITextField!
  @IBOutlet var shippingMethodPicker: UIPickerView!
  
  func configurePickers() {
    shippingMethodTextField.inputView = shippingMethodPicker
    expirationDateTextField.inputView = expirationDatePicker
  }
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return output.shippingMethods.count
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return output.shippingMethods[row]
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    shippingMethodTextField.text = output.shippingMethods[row]
  }
  
  // MARK: Expiration date
  
  @IBOutlet weak var expirationDateTextField: UITextField!
  @IBOutlet var expirationDatePicker: UIDatePicker!
  
  @IBAction func expirationDatePickerValueChanged(sender: AnyObject) {
    let date = expirationDatePicker.date
    let request = CreateOrder_FormatExpirationDate_Request(date: date)
    output.formatExpirationDate(request)
  }
  
  func displayExpirationDate(viewModel: CreateOrder_FormatExpirationDate_ViewModel) {
    let date = viewModel.date
    expirationDateTextField.text = date
  }
}
