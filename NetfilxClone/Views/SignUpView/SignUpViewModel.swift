//
//  SignUpViewModel.swift
//  NetfilxClone
//
//  Created by tungdd on 02/08/2023.
//

import Foundation
import Combine
import FirebaseAuth

class SignUpViewModel {
    private var cancellables = Set<AnyCancellable>()
    private var output = PassthroughSubject<Output,Never>()
    private var username: String = ""
    private var email: String = ""
    private var password: String = ""
    private var confirmPassword: String = ""
    private var isValid: Bool = true
    
    func transform(input: AnyPublisher<Input,Never>) -> AnyPublisher<Output,Never> {
        input.sink { [weak self] event in
            switch event {
            case .signUp(let username, let email, let password, let confirmPassword):
                self?.username = username
                self?.email = email
                self?.password = password
                self?.confirmPassword = confirmPassword
                self?.signUp()

            }
        }.store(in: &cancellables)
        
        output.sink {  [weak self] event in
            switch event {
            case .signUpDidFail:
                self?.isValid = false
            default:
                break
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    func signUp() {
        checkValid()
        if !isValid {
            isValid = true
            return
        }
        if(password != confirmPassword) {
            self.output.send(.signUpDidFail(error: SignUpError.incorrectConfirmPassword))
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            self.isValid = true
            if let error = error as? NSError {
                switch error.code {
                case AuthErrorCode.emailAlreadyInUse.rawValue:
                    self.output.send(.signUpDidFail(error: .emailAlreadyUsed))
                case AuthErrorCode.networkError.rawValue:
                    self.output.send(.signUpDidFail(error: .networkError))
                default:
                    self.output.send(.signUpDidFail(error: .unknowError))
                }
            } else {
                let changeRequest = authResult?.user.createProfileChangeRequest()
                changeRequest?.displayName = self.username
                changeRequest?.commitChanges()
                self.output.send(.signUpDidSuccess)
            }
        }
    }
    
    func checkValid() {
        let passwordRegex = "^.{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        if username.isEmpty {
            self.output.send(.signUpDidFail(error: SignUpError.missingUsername))
        }
        if email.isEmpty {
            self.output.send(.signUpDidFail(error: SignUpError.missingEmail))
        } else if !emailPredicate.evaluate(with: email) {
            self.output.send(.signUpDidFail(error: SignUpError.invalidEmail))
        }
        if password.isEmpty {
            self.output.send(.signUpDidFail(error: SignUpError.missingPassword))
        } else if !passwordPredicate.evaluate(with: password) {
            self.output.send(.signUpDidFail(error: SignUpError.invalidPassword))
        }
        if confirmPassword.isEmpty {
            self.output.send(.signUpDidFail(error: SignUpError.missingConfirmPassword))
        }
    }
    
    enum Input {
        case signUp(username: String, email: String, password: String, confirmPassword: String)
    }
    
    enum Output {
        case signUpDidFail(error: SignUpError)
        case signUpDidSuccess
    }
    
    enum SignUpError: Error, LocalizedError {
        case missingUsername
        case missingEmail
        case missingPassword
        case missingConfirmPassword
        case incorrectConfirmPassword
        case invalidPassword
        case invalidEmail
        case networkError
        case unknowError
        case emailAlreadyUsed
        
        public var errorDescription: String? {
            switch self {
            case .missingUsername:
                return NSLocalizedString("Please enter username", comment: "My error")
            case .missingEmail:
                return NSLocalizedString("Please enter email", comment: "My error")
            case .missingPassword:
                return NSLocalizedString("Please enter password", comment: "My error")
            case .missingConfirmPassword:
                return NSLocalizedString("Please enter confirm password", comment: "My error")
            case .incorrectConfirmPassword:
                return NSLocalizedString("Confirm password incorrect", comment: "My error")
            case .invalidPassword:
                return NSLocalizedString("Password must be at least 8 characters long", comment: "My error")
            case .invalidEmail:
                return NSLocalizedString("Please enter valid email address", comment: "My error")
            case .networkError:
                return NSLocalizedString("Please check your network and try again", comment: "My error")
            case .emailAlreadyUsed:
                return NSLocalizedString("This email already used!", comment: "My error")
            case .unknowError:
                return NSLocalizedString("Opps! Some thing went wrong", comment: "My error")
            
            }
        }
    }
}
