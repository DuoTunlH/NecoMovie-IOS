//
//  SearchViewController.swift
//  NetfilxClone
//
//  Created by tungdd on 26/06/2023.
//

import UIKit
import Combine

class SearchViewController: UIViewController {
    
    @IBOutlet weak var navBar: NavigationBarView!
    @IBOutlet weak var searchCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    var isSearching = false
    var viewModel = SearchViewModel()
    private let input = PassthroughSubject<SearchViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        self.input.send(.viewDidLoad)
    }
    
    func setupUI() {
        navBar.delegate = self
        searchCollectionView.register(UINib(nibName: "SearchCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SearchCollectionViewCell")
        searchCollectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        searchCollectionView.dataSource = self
        searchCollectionView.delegate = self
        searchBar.delegate = self
        navigationController?.isNavigationBarHidden = true
        navigationItem.hidesSearchBarWhenScrolling = false
        searchBar.searchTextField.textColor = .white
        DispatchQueue.main.async {
            self.navigationItem.hidesSearchBarWhenScrolling = true
        }
        self.hideKeyboardWhenTappedAround()
    }
    
    func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] event in
                switch event {
                case .fetchDidSucceed:
                    self?.searchCollectionView.reloadData()
                case .fetchDidFail(let error):
                    print(error.localizedDescription)
                }
            }.store(in: &cancellables)
    }
    
}

extension SearchViewController: NavigationBarDelegate {
    func leftBtnDidTap() {
    }
    func rightBtn1DidTap() {
        let vc = ProfileViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (isSearching) {
            return viewModel.searchingMovies.value.count
        }
        else {
            return viewModel.discoveryMovies.value.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (isSearching) {
            let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
            cell.configure(with: viewModel.searchingMovies.value[indexPath.row].poster_path ?? "")
            return cell
        }
        
        else {
            let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: "SearchCollectionViewCell", for: indexPath) as! SearchCollectionViewCell
            cell.configure(movie: viewModel.discoveryMovies.value[indexPath.row])
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (isSearching) {
            return CGSize(width: (UIScreen.main.bounds.width - 4*6)/3, height: 3*(UIScreen.main.bounds.width - 4*6)/3/2)
        }
        else {
            return CGSize(width: UIScreen.main.bounds.width - 10, height: 200)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = MovieDetailViewController()
        if (isSearching) {
            vc.viewModel.movie = viewModel.searchingMovies.value[indexPath.row]
        }
        else {
            vc.viewModel.movie = viewModel.discoveryMovies.value[indexPath.row]
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if isSearching, indexPath.row == viewModel.searchingMovies.value.count - 6 {
//            input.send(.viewDidLoad)
//        }
//    }
    
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty) {
            self.isSearching = false
            searchCollectionView.reloadData()
        }
        else {
            self.isSearching = true
            input.send(.isSearching(searchText: searchText))
        }
    }
}


