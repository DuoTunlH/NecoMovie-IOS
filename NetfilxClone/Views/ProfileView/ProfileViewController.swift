//
//  ProfileViewController.swift
//  NetfilxClone
//
//  Created by tungdd on 11/07/2023.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import Combine

class ProfileViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var editProfileView: UIView!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var helpView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var addAvatarBtn: UIButton!
    @IBOutlet weak var navBar: NavigationBarView!
    @IBOutlet var editUsenameBtn: UIButton!
    var cancellables = Set<AnyCancellable>()
    var input = PassthroughSubject<ProfileViewModel.Input,Never>()
    var viewModel = ProfileViewModel()
    var tempAvt = UIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
    }
    func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output.sink { event in
            switch event {
            case .logOutDidSuccess:
                self.tabBarController?.navigationController?.popToRootViewController(animated: true)
            case .logOutDidFail(let error):
                print("Error signing out: \(error.localizedDescription)")
            case .changeUsernameDidSuccess:
                self.usernameLabel.text = self.usernameTextField.text
                self.usernameTextField.isHidden = true
                self.usernameLabel.isHidden = false
                self.navBar.rightBtn1.isHidden = true
            case .changeUsernameDidFail(let error):
                print("Error while changing username: \(error.localizedDescription)")
            case .changeAvatarDidFail(let error):
                print("Error while changing avatar: \(error.localizedDescription)")
            default:
                break
            }
        }.store(in: &cancellables)
        
        let changeAvatar = Notification.Name("changeAvatar")
        
        NotificationCenter.default
            .publisher(for: changeAvatar, object: nil)
            .receive(on: DispatchQueue.main)
            .sink {[weak self] notification in
                self?.avatarImage.image = notification.object as? UIImage
            }.store(in: &cancellables)
    }
    func setupUI() {
        navBar.delegate = self
        navBar.leftBtn.setTitle(" Profile", for: .normal)
        navBar.leftBtn.titleLabel?.font = .boldSystemFont(ofSize: 28)
        self.tabBarController?.tabBar.isHidden = true
        usernameLabel.text = Auth.auth().currentUser?.displayName ?? "Username"
        editProfileView.layer.cornerRadius = 8
        notificationView.layer.cornerRadius = 8
        settingsView.layer.cornerRadius = 8
        helpView.layer.cornerRadius = 8
        avatarImage.layer.borderColor = UIColor.white.cgColor
        avatarImage.layer.borderWidth = 1
        avatarImage.layer.masksToBounds = true
        avatarImage.layer.cornerRadius = self.avatarImage.layer.frame.width/2
        addAvatarBtn.layer.masksToBounds = true
        addAvatarBtn.layer.cornerRadius = self.addAvatarBtn.layer.frame.width/2
        if let url = Auth.auth().currentUser?.photoURL{
            avatarImage.sd_setImage(with: url)
        }
        navBar.rightBtn1.isHidden = true
        navBar.rightBtn2.isHidden = true
        navBar.leftBtn.isUserInteractionEnabled = true
        navBar.leftBtn.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func logoutBtnDidTap(_ sender: Any) {
        input.send(.logOut)
    }
    @IBAction func changePasswordBtnDidTap(_ sender: Any) {
        let vc = ChangePasswordViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func editUsernameDidTap(_ sender: Any) {
        usernameLabel.isHidden = true
        usernameTextField.text = usernameLabel.text
        usernameTextField.isHidden = false
        usernameTextField.becomeFirstResponder()
        usernameTextField.selectedTextRange = usernameTextField.textRange(from: usernameTextField.endOfDocument, to: usernameTextField.endOfDocument)
        navBar.rightBtn1.isHidden = false
        navBar.rightBtn1.layer.borderWidth = 0
        navBar.rightBtn1.setBackgroundImage(UIImage(), for: .normal)
        navBar.rightBtn1.setTitle("Save", for: .normal)
        navBar.rightBtn1.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
    }
    @IBAction func addAvatar(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        tempAvt = image
        self.input.send(.changeAvatar(avatar: image))
        dismiss(animated: true)
    }
    
}

extension ProfileViewController: NavigationBarDelegate {
    func leftBtnDidTap() {
        navigationController?.popViewController(animated: true)
    }
    func rightBtn1DidTap() {
        view.endEditing(true)
        input.send(.changeUsername(username: usernameTextField.text ?? "Username"))
    }
}

