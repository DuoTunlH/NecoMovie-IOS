//
//  SignUpViewController.swift
//  BookTicket
//
//  Created by tungdd on 20/06/2023.
//

import UIKit
import Combine

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var usernameErrorLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var confirmPasswordErrorLabel: UILabel!
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    @IBOutlet weak var usernameTextField: AppTextField!
    @IBOutlet weak var passwordTextField: AppTextField!
    @IBOutlet weak var emailTextField: AppTextField!
    @IBOutlet weak var confirmPasswordTextField: AppTextField!
    @IBOutlet weak var argreeBtn: UIButton!
    @IBOutlet weak var signInLabel: UILabel!
    var viewModel = SignUpViewModel()
    var input = PassthroughSubject<SignUpViewModel.Input,Never>()
    var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.blurEffectView.isHidden = true
                switch event {
                case .signUpDidFail(let error):
                    switch error {
                    case .missingUsername:
                        self?.usernameErrorLabel.isHidden = false
                        self?.usernameErrorLabel.text = error.errorDescription
                    case .missingEmail, .invalidEmail, .emailAlreadyUsed:
                        self?.emailErrorLabel.isHidden = false
                        self?.emailErrorLabel.text = error.errorDescription
                    case .missingPassword, .invalidPassword:
                        self?.passwordErrorLabel.isHidden = false
                        self?.passwordErrorLabel.text = error.errorDescription
                    case .missingConfirmPassword, .incorrectConfirmPassword:
                        self?.confirmPasswordErrorLabel.isHidden = false
                        self?.confirmPasswordErrorLabel.text = error.errorDescription
                    case .unknowError, .networkError:
                        let okAction = UIAlertAction(title: "Close", style: .cancel)
                        self?.showingAlert(title: "Sign up unsuccessfully",message: error.errorDescription!, action: okAction)
                    }
                case .signUpDidSuccess:
                    let okAction = UIAlertAction(title: "Go to login", style: UIAlertAction.Style.default) {
                        action in
                        self?.navigationController?.popViewController(animated: true)
                    }
                    self?.showingAlert(title: "Sign up successfully",message: "", action: okAction)
                }
            }.store(in: &cancellables)
    }
    
    func setupUI() {
        blurEffectView.isHidden = true
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        self.hideKeyboardWhenTappedAround()
        
        usernameTextField.placeholder = "Username"
        
        passwordTextField.placeholder = "Password"
        
        emailTextField.placeholder = "Email"
        
        confirmPasswordTextField.placeholder = "Confirm password"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(signUpDidTap))
        signInLabel.isUserInteractionEnabled = true
        signInLabel.addGestureRecognizer(tap)
    }
    
    func showingAlert(title: String = "Sign in unsuccessfully", message: String = "Something is wrong", action: UIAlertAction) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(action)
        self.present(alertController, animated: true)
    }
    
    @objc func signUpDidTap(sender: UITapGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        self.blurEffectView.isHidden = false
        emailErrorLabel.isHidden = true
        usernameErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        confirmPasswordErrorLabel.isHidden = true
        input.send(.signUp(username: usernameTextField.text ?? "",email: emailTextField.text ?? "", password: passwordTextField.text ?? "", confirmPassword: confirmPasswordTextField.text ?? ""))
    }
    
    @IBAction func argree(_ sender: UIButton) {
        argreeBtn.isSelected.toggle()
        let checkMark = argreeBtn.isSelected ? UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)) : UIImage()
        argreeBtn.setImage(checkMark, for: .normal)
    }
    
    @IBAction func showingPassword(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()
        let icon = !passwordTextField.isSecureTextEntry ?
        UIImage(named: "HidingPassword") :
        UIImage(named: "ShowingPassword")
        sender.setImage(icon, for: .normal)
    }
    
    @IBAction func showingConfirmPassword(_ sender: UIButton) {
        confirmPasswordTextField.isSecureTextEntry.toggle()
        let icon = !confirmPasswordTextField.isSecureTextEntry ?
        UIImage(named: "HidingPassword") :
        UIImage(named: "ShowingPassword")
        sender.setImage(icon, for: .normal)
    }
    
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        case confirmPasswordTextField:
            self.view.endEditing(true)
        default:
            self.view.endEditing(true)
        }
        return true
    }
}

