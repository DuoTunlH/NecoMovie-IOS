//
//  DownloadsViewController.swift
//  NetfilxClone
//
//  Created by tungdd on 26/06/2023.
//

import UIKit
import Combine

class FavouriteViewController: UIViewController {
    
    @IBOutlet weak var navBar: NavigationBarView!
    @IBOutlet var collectionView: UICollectionView!
    var viewModel = FavouriteViewModel()
    let input = PassthroughSubject<FavouriteViewModel.Input,Never>()
    private var isDeleting = CurrentValueSubject<Bool,Never>(false)
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        input.send(.viewDidLoad)
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        self.collectionView?.addGestureRecognizer(lpgr)
    }
    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            navBar.deleteBtn.isHidden = false
            navBar.cancelBtn.isHidden = false
            navBar.profileBtn.isHidden = true
            navBar.notiBtn.isHidden = true
            navBar.leftBtn.isHidden = true
            isDeleting.value = true
        }
    }
    
    func setupUI() {
        navBar.delegate = self
        navigationController?.isNavigationBarHidden = true
        collectionView.register(UINib(nibName: "MovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView.register(UINib(nibName: "HeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output.receive(on: DispatchQueue.main)
            .sink {
                [weak self] event in
                switch event {
                case .fetchDidSucceed:
                    self?.collectionView.reloadData()
                case .fetchDidFail(let error):
                    print(error.localizedDescription)

                }
            }.store(in: &cancellables)
        
        isDeleting
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .removeDuplicates()
            .sink {[weak self] isDeleting in
                    self?.collectionView.reloadData()
            }.store(in: &cancellables)
        
        let addToFavourite = Notification.Name("addToFavourite")
        let removeFromFavourite = Notification.Name("removeFromFavourite")
        
        NotificationCenter.default
            .publisher(for: addToFavourite, object: nil)
            .receive(on: DispatchQueue.main)
            .sink {[weak self] notification in
                self?.viewModel.movies.append(notification.object as! Movie)
                self?.collectionView.reloadData()
                self?.collectionView.scrollToItem(at: IndexPath(row: (self?.viewModel.movies.count ?? 1) - 1, section: 0), at: .bottom, animated: false)
            }.store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: removeFromFavourite, object: nil)
            .receive(on: DispatchQueue.main)
            .sink {[weak self] notification in
                self?.input.send(.delete(id: notification.object as! Int))
            }.store(in: &cancellables)
    }
}


extension FavouriteViewController: NavigationBarDelegate {
    func profileBtnDidTap() {
        let vc = ProfileViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func cancelBtnDidTap() {
        viewModel.deleteList.removeAll()
        navBar.deleteBtn.isHidden = true
        navBar.cancelBtn.isHidden = true
        navBar.profileBtn.isHidden = false
        navBar.notiBtn.isHidden = false
        navBar.leftBtn.isHidden = false
        isDeleting.value = false
    }
    func deleteBtnDidTap() {
        input.send(.remove)
        cancelBtnDidTap()
    }
}
extension FavouriteViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.movies.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MovieCollectionViewCell
        cell.configure(movie: viewModel.movies[indexPath.row])
        if isDeleting.value {
            cell.playBtn.isHidden = true
            cell.selectBtn.isHidden = false
            return cell
        }
        cell.selectBtn.isHidden = true
        cell.playBtn.isHidden = false
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isDeleting.value {
            let cell = collectionView.cellForItem(at: indexPath) as! MovieCollectionViewCell
            cell.selectBtn.isSelected.toggle()
            let checkMark = cell.selectBtn.isSelected ?
            UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(scale: .large)) :
            UIImage()
            cell.selectBtn.setImage(checkMark, for: .normal)
            if cell.selectBtn.isSelected {
                viewModel.deleteList.insert(indexPath.row)
                return
            }
            viewModel.deleteList.remove(indexPath.row)
            return
        }
        let vc = MovieDetailViewController()
        vc.viewModel.movie = viewModel.movies[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! HeaderCollectionReusableView
            header.titleLabel.text = "Favourite"
            return header
        default:
            fatalError()
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 72)
    }
}

extension FavouriteViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 200)
    }
}

