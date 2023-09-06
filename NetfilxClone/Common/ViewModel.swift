//
//  ViewModel.swift
//  NetfilxClone
//
//  Created by tungdd on 26/07/2023.
//

import Foundation
import UIKit
import Combine

//enum Input {
//    case viewDidLoad
//    case isSearching(searchText: String)
//    case delete(id: Int)
//    case addToFavourite
//    case removeFromFavourite
//    case signIn(email: String, password: String)
//    case signUp(username: String, email: String, password: String, confirmPassword: String)
//    case changePassword(currentPassword: String, newPassword: String, confirmNewPassword: String)
//    case changeUsername(username: String)
//    case changeAvatar(avatar: UIImage)
//    case logOut
//}
//
//enum Output {
//    case fetchDidFail(error: Error)
//    case fetchDidSucceed
//    case signInDidFail(error: SignInError)
//    case signInDidSuccess
//    case signUpDidFail(error: SignUpError)
//    case signUpDidSuccess
//    case isFavourite(result: Bool)
//    case changePasswordDidFail(error: ChangePasswordError)
//    case changePasswordDidSuccess
//    case logOutDidSuccess
//    case logOutDidFail(error: Error)
//    case changeUsernameDidSuccess
//    case changeUsernameDidFail(error: Error)
//    case changeAvatarDidSuccess
//    case changeAvatarDidFail(error: Error)
//}

//enum SignInError: Error, LocalizedError {
//    case missingEmail
//    case missingPassword
//    case unknowError
//    case invalidPassword
//    case networkError
//    case tooManyRequests
//
//    public var errorDescription: String? {
//        switch self {
//        case .missingEmail:
//            return NSLocalizedString("Please enter email", comment: "My error")
//        case .missingPassword:
//            return NSLocalizedString("Please enter password", comment: "My error")
//        case .invalidPassword:
//            return NSLocalizedString("Email or password incorrect", comment: "My error")
//        case .networkError:
//            return NSLocalizedString("Please check your network and try again", comment: "My error")
//        case .tooManyRequests:
//            return NSLocalizedString("Access to this account has been temporarily disabled due to many failed login attempts, please try again later", comment: "My error")
//        case .unknowError:
//            return NSLocalizedString("Opps! Some thing went wrong", comment: "My error")
//        }
//    }
//}

//enum SignUpError: Error, LocalizedError {
//    case missingUsername
//    case missingEmail
//    case missingPassword
//    case missingConfirmPassword
//    case incorrectConfirmPassword
//    case invalidPassword
//    case invalidEmail
//    case networkError
//    case unknowError
//    case emailAlreadyUsed
//    
//    public var errorDescription: String? {
//        switch self {
//        case .missingUsername:
//            return NSLocalizedString("Please enter username", comment: "My error")
//        case .missingEmail:
//            return NSLocalizedString("Please enter email", comment: "My error")
//        case .missingPassword:
//            return NSLocalizedString("Please enter password", comment: "My error")
//        case .missingConfirmPassword:
//            return NSLocalizedString("Please enter confirm password", comment: "My error")
//        case .incorrectConfirmPassword:
//            return NSLocalizedString("Confirm password incorrect", comment: "My error")
//        case .invalidPassword:
//            return NSLocalizedString("Password at least 8 character", comment: "My error")
//        case .invalidEmail:
//            return NSLocalizedString("Please enter valid email address", comment: "My error")
//        case .networkError:
//            return NSLocalizedString("Please check your network and try again", comment: "My error")
//        case .emailAlreadyUsed:
//            return NSLocalizedString("This email already used!", comment: "My error")
//        case .unknowError:
//            return NSLocalizedString("Opps! Some thing went wrong", comment: "My error")
//        
//        }
//    }
//}

//enum ChangePasswordError: Error, LocalizedError {
//    case missingCurrentPassword
//    case missingNewPassword
//    case missingConfirmNewPassword
//    case incorrectCurrentPassword
//    case incorrectConfirmNewPassword
//    case networkError
//    case invalidNewPassword
//    
//    public var errorDescription: String? {
//        switch self {
//        case .missingCurrentPassword:
//            return NSLocalizedString("Please enter current password", comment: "My error")
//        case .missingNewPassword:
//            return NSLocalizedString("Please enter new password", comment: "My error")
//        case .missingConfirmNewPassword:
//            return NSLocalizedString("Please enter confirm new password", comment: "My error")
//        case .incorrectCurrentPassword:
//            return NSLocalizedString("Incorrect current password", comment: "My error")
//        case .incorrectConfirmNewPassword:
//            return NSLocalizedString("Incorrect confirm new password", comment: "My error")
//        case .networkError:
//            return NSLocalizedString("Please check your network and try again", comment: "My error")
//        case .invalidNewPassword:
//            return NSLocalizedString("Password at least 8 character", comment: "My error")
//        }
//        
//    }
//}


//protocol ViewModel {
//    func transform(input: AnyPublisher<Input,Never>) -> AnyPublisher<Output, Never>
//}

