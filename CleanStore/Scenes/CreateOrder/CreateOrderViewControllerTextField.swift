//
//  CreateOrderViewControllerTextField.swift
//  CleanStore
//
//  Created by Mati on 22/1/16.
//  Copyright © 2016 Raymond Law. All rights reserved.
//

import Foundation
import UIKit


extension CreateOrderViewController: UITextFieldDelegate {
  
  // MARK: Text fields
  
  
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
  
}