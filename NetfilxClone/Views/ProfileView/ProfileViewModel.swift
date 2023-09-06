//
//  ProfileViewModel.swift
//  NetfilxClone
//
//  Created by tungdd on 05/09/2023.
//

import FirebaseAuth
import FirebaseStorage
import Combine
import UIKit

class ProfileViewModel {
    let storage = Storage.storage().reference()
    var cancellables = Set<AnyCancellable>()
    var output = PassthroughSubject<Output, Never>()
    
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { event in
            switch event {
            case .logOut:
                self.logOut()
            case .changeUsername(let username):
                self.changeUsername(username)
            case .changeAvatar(let avatar):
                self.changeAvatar(avatar)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
            output.send(.logOutDidSuccess)
        } catch let error {
            output.send(.logOutDidFail(error: error))
        }
    }
    
    func changeUsername(_ username: String){
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = username
        changeRequest?.commitChanges() { error in
            if let error {
                self.output.send(.changeUsernameDidFail(error: error))
            }
        }
        output.send(.changeUsernameDidSuccess)
    }
    
    func changeAvatar(_ avatar: UIImage) {
        let directory = "images/\(Auth.auth().currentUser?.uid ?? "a")_avatar_\(Date().timeIntervalSince1970).png"
        storage.child(directory).putData(avatar.pngData()!) {
            (_,error) in
            if let error {
                self.output.send(.changeAvatarDidFail(error: error as! Error))
            }
            else {
                self.storage.child(directory).downloadURL { url, error in
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.photoURL = url
                    changeRequest?.commitChanges() {
                        error in
                        if let error {
                            self.output.send(.changeAvatarDidFail(error: error))
                        }
                    }
                    NotificationCenter.default.post(name: Notification.Name("changeAvatar"), object: avatar)
                }
            }
            
        }
        
    }
    enum Input {
        case changeUsername(username: String)
        case changeAvatar(avatar: UIImage)
        case logOut
    }
    enum Output {
        case changePasswordDidSuccess
        case logOutDidSuccess
        case logOutDidFail(error: Error)
        case changeUsernameDidSuccess
        case changeUsernameDidFail(error: Error)
        case changeAvatarDidSuccess
        case changeAvatarDidFail(error: Error)
    }
}
