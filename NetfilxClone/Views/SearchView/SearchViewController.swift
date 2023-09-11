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
        searchCollectionView.register(UINib(nibName: "MovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MovieCollectionViewCell")
        searchCollectionView.register(UINib(nibName: "PosterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PosterCollectionViewCell")
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
                    self?.searchCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
                case .fetchDidFail(let error):
                    print(error.localizedDescription)
                }
            }.store(in: &cancellables)
    }
    
}

extension SearchViewController: NavigationBarDelegate {
    func leftBtnDidTap() {
    }
    func profileBtnDidTap() {
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
            let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: "PosterCollectionViewCell", for: indexPath) as! PosterCollectionViewCell
            cell.configure(with: viewModel.searchingMovies.value[indexPath.row].poster_path ?? "")
            return cell
        }
        
        else {
            let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell
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
            searchCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
        else {
            self.isSearching = true
            input.send(.isSearching(searchText: searchText))
        }
    }
}



