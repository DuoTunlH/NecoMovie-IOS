//
//  ChangePasswordViewModel.swift
//  NetfilxClone
//
//  Created by tungdd on 05/09/2023.
//

import Foundation
import Combine
import FirebaseAuth

class ChangePasswordViewModel {
   
    var cancellables = Set<AnyCancellable>()
    var output = PassthroughSubject<Output, Never>()
    private var currentPassword = ""
    private var newPassword = ""
    private var confirmNewPassword = ""
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .changePassword(let currentPassword, let newPassword, let confirmNewPassword):
                self?.currentPassword = currentPassword
                self?.newPassword = newPassword
                self?.confirmNewPassword = confirmNewPassword
                self?.changePassword()
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    func changePassword() {
        let user = Auth.auth().currentUser
        let credential: AuthCredential = EmailAuthProvider.credential(withEmail: user?.email ?? "", password: currentPassword )
        if !checkValid() {
            return
        }
        user?.reauthenticate(with: credential) {result,error in
            if let error = error as? NSError {
                switch error.code {
                case AuthErrorCode.wrongPassword.rawValue:
                    self.output.send(.changePasswordDidFail(error: .incorrectCurrentPassword))
                case AuthErrorCode.networkError.rawValue:
                    self.output.send(.changePasswordDidFail(error: .networkError))
                default:
                    self.output.send(.changePasswordDidFail(error: .unknownError))
                }
            }
            if !(self.newPassword == self.confirmNewPassword) {
                self.output.send(.changePasswordDidFail(error: ChangePasswordError.incorrectConfirmNewPassword))
            }
            else {
                user?.updatePassword(to: self.confirmNewPassword)
                self.output.send(.changePasswordDidSuccess)
            }
        }
    }
    func checkValid() -> Bool {
        var hasCurrentPassword = true
        let passwordRegex = "^.{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        if currentPassword.isEmpty {
            self.output.send(.changePasswordDidFail(error: ChangePasswordError.missingCurrentPassword))
            hasCurrentPassword = false
        }
        if newPassword.isEmpty {
            self.output.send(.changePasswordDidFail(error: ChangePasswordError.missingNewPassword))
        }else if !passwordPredicate.evaluate(with: newPassword) {
            self.output.send(.changePasswordDidFail(error: ChangePasswordError.invalidNewPassword))
        }
        if confirmNewPassword.isEmpty {
            self.output.send(.changePasswordDidFail(error: ChangePasswordError.missingConfirmNewPassword))
        }
        return hasCurrentPassword
    }
    
    enum Input {
        case changePassword(currentPassword: String, newPassword: String, confirmNewPassword: String)
    }
    
    enum Output {
        case changePasswordDidFail(error: ChangePasswordError)
        case changePasswordDidSuccess
    }
    
    
    enum ChangePasswordError: Error, LocalizedError {
        case missingCurrentPassword
        case missingNewPassword
        case missingConfirmNewPassword
        case incorrectCurrentPassword
        case incorrectConfirmNewPassword
        case networkError
        case invalidNewPassword
        case unknownError
        
        public var errorDescription: String? {
            switch self {
            case .missingCurrentPassword:
                return NSLocalizedString("Please enter current password", comment: "My error")
            case .missingNewPassword:
                return NSLocalizedString("Please enter new password", comment: "My error")
            case .missingConfirmNewPassword:
                return NSLocalizedString("Please enter confirm new password", comment: "My error")
            case .incorrectCurrentPassword:
                return NSLocalizedString("Incorrect current password", comment: "My error")
            case .incorrectConfirmNewPassword:
                return NSLocalizedString("Incorrect confirm new password", comment: "My error")
            case .networkError:
                return NSLocalizedString("Please check your network and try again", comment: "My error")
            case .invalidNewPassword:
                return NSLocalizedString("Password at least 8 character", comment: "My error")
            case .unknownError:
                return NSLocalizedString("Opps! Some thing went wrong", comment: "My error")
            }
            
        }
    }

}
