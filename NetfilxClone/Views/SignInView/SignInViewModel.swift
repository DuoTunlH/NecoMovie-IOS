//
//  SignInViewModel.swift
//  NetfilxClone
//
//  Created by tungdd on 02/08/2023.
//

import Foundation
import Combine
import FirebaseAuth


class SignInViewModel {
    private var cancellables = Set<AnyCancellable>()
    private var output = PassthroughSubject<Output,Never>()
    private var isValid = true
    private var email: String = ""
    private var password: String = ""
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output,Never> {
        
        input.sink { [weak self] event in
            switch event {
            case .signIn(let email, let password):
                self?.email = email
                self?.password = password
                self?.login()
            }
        }.store(in: &cancellables)
        
        output.sink { event in
            switch event {
            case .signInDidFail:
                self.isValid = false
            default:
                break
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    func autoLogin() {
        if let user = Auth.auth().currentUser {
            self.output.send(.signInDidSuccess)
        }
    }
    
    private func login() {
        checkValid()
        if !isValid {
            isValid = true
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error as? NSError {
                switch error.code {
                case AuthErrorCode.wrongPassword.rawValue:
                    self.output.send(.signInDidFail(error: .invalidPassword))
                case AuthErrorCode.tooManyRequests.rawValue:
                    self.output.send(.signInDidFail(error: .tooManyRequests))
                case AuthErrorCode.networkError.rawValue:
                    self.output.send(.signInDidFail(error: .networkError))
                default:
                    self.output.send(.signInDidFail(error: .unknowError))
                }
            } else {
                UserDefaults.standard.set(self.email, forKey: "email")
                self.output.send(.signInDidSuccess)
            }
        }
    }
    private func checkValid() {
        if email.isEmpty {
            self.output.send(.signInDidFail(error: SignInError.missingEmail))
        }
        if password.isEmpty {
            self.output.send(.signInDidFail(error: SignInError.missingPassword))
        }
    }
    
    enum Input {
        case signIn(email: String, password: String)
    }
    
    enum Output {
        case signInDidFail(error: SignInError)
        case signInDidSuccess
    }
    
    enum SignInError: Error, LocalizedError {
        case missingEmail
        case missingPassword
        case unknowError
        case invalidPassword
        case networkError
        case tooManyRequests
        
        public var errorDescription: String? {
            switch self {
            case .missingEmail:
                return NSLocalizedString("Please enter email", comment: "My error")
            case .missingPassword:
                return NSLocalizedString("Please enter password", comment: "My error")
            case .invalidPassword:
                return NSLocalizedString("Email or password incorrect", comment: "My error")
            case .networkError:
                return NSLocalizedString("Please check your network and try again", comment: "My error")
            case .tooManyRequests:
                return NSLocalizedString("Access to this account has been temporarily disabled due to many failed login attempts, please try again later", comment: "My error")
            case .unknowError:
                return NSLocalizedString("Opps! Some thing went wrong", comment: "My error")
            }
        }
    }
}
