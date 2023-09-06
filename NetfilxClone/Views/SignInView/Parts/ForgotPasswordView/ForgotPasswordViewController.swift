//
//  ForgotPasswordViewController.swift
//  NetfilxClone
//
//  Created by tungdd on 05/09/2023.
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var emailTextField: AppTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.placeholder = "Email"
        hideKeyboardWhenTappedAround()
        
    }
    @IBAction func resetBtnDidTap(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: emailTextField.text ?? "") {
            (error) in
            if let error {
                let alert = UIAlertController(title: "Error", message: "Failed to send password reset email. \(error.localizedDescription).", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                self.present(alert, animated: true)
            } else {
                print("Password reset email sent successfully.")
                let alert = UIAlertController(title: "Success", message: "A password reset email has been sent to your email address. Please check your inbox.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
        
    }
    
}
