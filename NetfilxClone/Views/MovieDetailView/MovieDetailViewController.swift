//
//  MovieDetailViewController.swift
//  NetfilxClone
//
//  Created by tungdd on 30/06/2023.
//
import UIKit
import Combine

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var navBar: NavigationBarView!
    @IBOutlet weak var similarCollectionView: UICollectionView!
    var viewModel = MovieDetailViewModel()
    var cancellables = Set<AnyCancellable>()
    let input = PassthroughSubject<MovieDetailViewModel.Input, Never>()
    var isFavourite = CurrentValueSubject<Bool, Never>(false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        input.send(.viewDidLoad)
    }
    func setupUI() {
        navBar.delegate = self
        similarCollectionView.delegate = self
        similarCollectionView.dataSource = self
        similarCollectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        similarCollectionView.register(UINib(nibName: "MovieDetailHeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MovieDetailHeaderCollectionReusableView")
    }
    
    func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .fetchDidSucceed:
                    self?.similarCollectionView.reloadData()
                case .fetchDidFail(let error):
                    print(error.localizedDescription)
                case .isFavourite (let result):
                    self?.isFavourite.value = result
                    self?.similarCollectionView.reloadData()
                }
            }.store(in: &cancellables)
        
//        isFavourite
//            .receive(on: DispatchQueue.main)
//            .dropFirst()
//            .removeDuplicates()
//            .sink { Bool in
//                NotificationCenter.default.post(name: Notification.Name("favouriteChanged"), object: Bool)
//            }.store(in: &cancellables)
        
//        let addToFavourite = Notification.Name("favouriteChanged")
//        
//        NotificationCenter.default
//            .publisher(for: addToFavourite, object: nil)
//            .receive(on: DispatchQueue.main)
//            .sink {[weak self] notification in
//                self?.isFavourite.value = notification.object as! Bool
//                self?.similarCollectionView.reloadData()
//            }.store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navBar.leftBtn.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
        navBar.leftBtn.setTitle("", for: .normal)
        navBar.leftBtn.isUserInteractionEnabled = true
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
}

extension MovieDetailViewController: NavigationBarDelegate {
    func leftBtnDidTap() {
        navigationController?.popViewController(animated: true)
    }
    func profileBtnDidTap() {
        let vc = ProfileViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MovieDetailViewController: MovieDetailHeaderDelagate {
    func favouriteBtnDidTap() {
        input.send(isFavourite.value ? .removeFromFavourite : .addToFavourite)
    }
}

extension MovieDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.similarMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = similarCollectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.configure(with: viewModel.similarMovies[indexPath.row].poster_path ?? "")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width - 3*6)/3, height: 3*(UIScreen.main.bounds.width - 3*5)/3/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MovieDetailHeaderCollectionReusableView", for: indexPath) as! MovieDetailHeaderCollectionReusableView
            header.movieTrailers = viewModel.movieTrailers
            header.movie = viewModel.movie
            header.delegate = self
            header.isFavourite = self.isFavourite.value
            return header
        default:
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = MovieDetailViewController()
        vc.viewModel.movie = viewModel.similarMovies[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let height = (viewModel.movie?.overview?.height(withConstrainedWidth: UIScreen.main.bounds.width, font: .systemFont(ofSize: 17)) ?? 0) + (viewModel.movie?.original_title?.height(withConstrainedWidth: UIScreen.main.bounds.width, font: .boldSystemFont(ofSize: 30)) ?? 0) + 375
        return CGSize(width: UIScreen.main.bounds.width, height: height + 25)
    }
}


