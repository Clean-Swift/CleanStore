//
//  CreateOrderViewControllerPickerView.swift
//  CleanStore
//
//  Created by Mati on 22/1/16.
//  Copyright © 2016 Raymond Law. All rights reserved.
//

import Foundation
import UIKit

extension CreateOrderViewController: UIPickerViewDataSource {
  
  // MARK: - PickerView Data Source
  
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
}

extension CreateOrderViewController: UIPickerViewDelegate {
  
  // MARK: - PickerView Delegate
  
}