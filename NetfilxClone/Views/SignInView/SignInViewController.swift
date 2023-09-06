//
//  ViewController.swift
//  BookTicket
//
//  Created by tungdd on 19/06/2023.
//

import UIKit
import Combine
import FirebaseAuth

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var forgotPasswordBtn: UILabel!
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    @IBOutlet weak var emailTextField: AppTextField!
    @IBOutlet weak var passwordTextField: AppTextField!
    @IBOutlet weak var rememberMeBtn: UIButton!
    @IBOutlet weak var instaIcon: UIImageView!
    @IBOutlet weak var signupLabel: UILabel!
    var viewModel = SignInViewModel()
    var input = PassthroughSubject<SignInViewModel.Input,Never>()
    var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        viewModel.autoLogin()
    }
    func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.blurEffectView.isHidden = true
                switch event {
                case .signInDidFail(let error):
                    switch error {
                    case .missingEmail, .invalidPassword:
                        self?.emailErrorLabel.isHidden = false
                        self?.emailErrorLabel.text = error.errorDescription
                    case .missingPassword:
                        self?.passwordErrorLabel.isHidden = false
                        self?.passwordErrorLabel.text = error.errorDescription
                    case .unknowError, .networkError, .tooManyRequests:
                        self?.showingAlert(message: error.localizedDescription)
                    }
                case .signInDidSuccess:
                    let tabBarVC = MainTabBarViewController()
                    self?.navigationController?.isNavigationBarHidden = true
                    self?.navigationController?.pushViewController(tabBarVC, animated: true)
                }
            }.store(in: &cancellables)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.tintColor = UIColor.white
        emailTextField.text = UserDefaults.standard.string(forKey: "email") ?? ""
    }
    func setupUI() {
        blurEffectView.isHidden = true
        self.hideKeyboardWhenTappedAround()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.placeholder = "Email"
        passwordTextField.placeholder = "Password"
        instaIcon.layer.cornerRadius = 20
        let forgotPasswordDidTap = UITapGestureRecognizer(target: self, action: #selector(forgotPasswordDidTap))
        forgotPasswordBtn.isUserInteractionEnabled = true
        forgotPasswordBtn.addGestureRecognizer(forgotPasswordDidTap)
        let signUpDidTap = UITapGestureRecognizer(target: self, action: #selector(signUpDidTap))
        signupLabel.isUserInteractionEnabled = true
        signupLabel.addGestureRecognizer(signUpDidTap)
    }
    
    func showingAlert(message: String) {
        let alertController = UIAlertController(title: "Sign in unsuccessfully", message: "Something is wrong", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alertController.message = message
        self.present(alertController, animated: true)
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        blurEffectView.isHidden = false
        emailErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        input.send(.signIn(email: emailTextField.text ?? "", password: passwordTextField.text ?? ""))
        
    }
    
    @objc func forgotPasswordDidTap(sender: UITapGestureRecognizer) {
        let vc = ForgotPasswordViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func signUpDidTap(sender: UITapGestureRecognizer) {
        let vc = SignUpViewController(nibName: "SignUpViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func rememberMe(_ sender: UIButton) {
        rememberMeBtn.isSelected.toggle()
        let checkMark = rememberMeBtn.isSelected ?
        UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)) :
        UIImage()
        rememberMeBtn.setImage(checkMark, for: .normal)
    }
    
    @IBAction func showingPassword(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()
        let icon = !passwordTextField.isSecureTextEntry ?
        UIImage(named: "HidingPassword") :
        UIImage(named: "ShowingPassword")
        sender.setImage(icon, for: .normal)
    }
    
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        if textField == passwordTextField {
            self.view.endEditing(true)
        }
        return true
    }
}

