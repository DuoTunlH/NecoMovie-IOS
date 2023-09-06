//
//  CategoryViewController.swift
//  NetfilxClone
//
//  Created by tungdd on 09/08/2023.
//

import UIKit
import Combine

class CategoryViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navBar: NavigationBarView!
    var section: Sections?
    var cancellables = Set<AnyCancellable>()
    var input = PassthroughSubject<CategoryViewModel.Input,Never>()
    lazy var viewModel = CategoryViewModel(section: section!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        input.send(.viewDidLoad)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navBar.leftBtn.setTitle(" \(section?.title ?? "")", for: .normal)
        navBar.leftBtn.titleLabel?.font = .boldSystemFont(ofSize: 28)
        navBar.leftBtn.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
        navBar.leftBtn.isUserInteractionEnabled = true
    }
    
    func setupUI() {
        navBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
    }

    func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .fetchDidSucceed:
                    self?.collectionView.reloadData()
                case .fetchDidFail(let error):
                    print(error.localizedDescription)
                }
            }.store(in: &cancellables)
    }
}

extension CategoryViewController: NavigationBarDelegate {
    func leftBtnDidTap() {
        navigationController?.popViewController(animated: true)
    }
    func rightBtn1DidTap() {
        let vc = ProfileViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension CategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.configure(with: viewModel.movies[indexPath.row].poster_path ?? "")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: (UIScreen.main.bounds.width - 4*6)/3, height: 3*(UIScreen.main.bounds.width - 4*6)/3/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = MovieDetailViewController()
        vc.viewModel.movie = viewModel.movies[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == viewModel.movies.count - 6 {
            input.send(.viewDidLoad)
        }
    }
}