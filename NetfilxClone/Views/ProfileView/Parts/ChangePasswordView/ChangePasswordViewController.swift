//
//  ChangePasswordViewController.swift
//  NetfilxClone
//
//  Created by tungdd on 31/08/2023.
//

import UIKit
import Combine
import FirebaseAuth

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var navBar: NavigationBarView!
    @IBOutlet weak var newPasswordTextField: AppTextField!
    @IBOutlet weak var newPasswordErrorLabel: UILabel!
    @IBOutlet weak var currentPasswordErrorLabel: UILabel!
    @IBOutlet weak var currentPasswordTextField: AppTextField!
    @IBOutlet weak var confirmNewPasswordTextField: AppTextField!
    @IBOutlet weak var confirmNewPasswordErrorLabel: UILabel!
    
    var viewModel = ChangePasswordViewModel()
    var input = PassthroughSubject<ChangePasswordViewModel.Input,Never>()
    var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
    }
    
    func setupUI(){
        navBar.delegate = self
        currentPasswordTextField.placeholder = "Current password"
        newPasswordTextField.placeholder = "New password"
        confirmNewPasswordTextField.placeholder = "Confirm new password"
        hideKeyboardWhenTappedAround()
        navBar.leftBtn.setTitle(" Change password", for: .normal)
        navBar.leftBtn.titleLabel?.font = .boldSystemFont(ofSize: 24)
        navBar.profileBtn.isHidden = true
        navBar.notiBtn.isHidden = true
        navBar.leftBtn.isUserInteractionEnabled = true
        navBar.leftBtn.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .collect(.byTimeOrCount(DispatchQueue.main, .seconds(3.0), 3))
            .sink { [weak self] events in
                self?.indicatorView.stopAnimating()
                self?.view.isUserInteractionEnabled = true
                for event in events {
                    switch event {
                    case .changePasswordDidFail(let error):
                        switch error {
                        case .missingCurrentPassword, .incorrectCurrentPassword:
                            self?.currentPasswordErrorLabel.isHidden = false
                            self?.currentPasswordErrorLabel.text = error.errorDescription
                        case .missingNewPassword, .invalidNewPassword:
                            self?.newPasswordErrorLabel.isHidden = false
                            self?.newPasswordErrorLabel.text = error.errorDescription
                        case .missingConfirmNewPassword, .incorrectConfirmNewPassword:
                            self?.confirmNewPasswordErrorLabel.isHidden = false
                            self?.confirmNewPasswordErrorLabel.text = error.errorDescription
                        case .networkError, .unknownError:
                            self?.showingAlert(message: error.localizedDescription)
                        }
                    case .changePasswordDidSuccess:
                        let okAction = UIAlertAction(title: "Go to login", style: UIAlertAction.Style.default)
                        self?.showingAlert(title: "Your password has been changed successfully",message: "", action: okAction)
                    }
                }
            }
            .store(in: &cancellables)
    }
    func showingAlert(message: String) {
        let alertController = UIAlertController(title: "Password changed unsuccessfully", message: "Something is wrong", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler: nil))
        alertController.message = message
        self.present(alertController, animated: true)
    }
    func showingAlert(title: String = "Password changed unsuccessfully", message: String = "Something is wrong", action: UIAlertAction) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(action)
        self.present(alertController, animated: true)
    }
    @IBAction func showCurrentPasswordBtnDidTap(_ sender: UIButton) {
        currentPasswordTextField.isSecureTextEntry.toggle()
        let icon = !currentPasswordTextField.isSecureTextEntry ?
        UIImage(named: "HidingPassword") :
        UIImage(named: "ShowingPassword")
        sender.setImage(icon, for: .normal)
    }
    @IBAction func showNewPasswordBtnDidTap(_ sender: UIButton) {
        newPasswordTextField.isSecureTextEntry.toggle()
        let icon = !newPasswordTextField.isSecureTextEntry ?
        UIImage(named: "HidingPassword") :
        UIImage(named: "ShowingPassword")
        sender.setImage(icon, for: .normal)
    }
    @IBAction func showConfirmNewPasswordBtnDidTap(_ sender: UIButton) {
        confirmNewPasswordTextField.isSecureTextEntry.toggle()
        let icon = !confirmNewPasswordTextField.isSecureTextEntry ?
        UIImage(named: "HidingPassword") :
        UIImage(named: "ShowingPassword")
        sender.setImage(icon, for: .normal)
    }
    @IBAction func saveBtnDidTap(_ sender: UIButton) {
        self.indicatorView.startAnimating()
        self.view.isUserInteractionEnabled = false
        currentPasswordErrorLabel.isHidden = true
        newPasswordErrorLabel.isHidden = true
        confirmNewPasswordErrorLabel.isHidden = true
        input.send(.changePassword(currentPassword: currentPasswordTextField.text!, newPassword: newPasswordTextField.text!, confirmNewPassword: confirmNewPasswordTextField.text!))
        
    }
}

extension ChangePasswordViewController: NavigationBarDelegate {
    func leftBtnDidTap() {
        navigationController?.popViewController(animated: true)
    }
    
    func profileBtnDidTap() {
    }
}
