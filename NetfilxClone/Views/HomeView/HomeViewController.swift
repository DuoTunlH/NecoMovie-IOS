//
//  HomeViewController.swift
//  NetfilxClone
//
//  Created by tungdd on 26/06/2023.
//

import UIKit
import Combine
import SDWebImage

class HomeViewController: UIViewController {
    
    //@IBOutlet weak var tableViewHeaderImageView: UIImageView!
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            pagerView.layer.cornerRadius = 8.0
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBar: NavigationBarView!
    @IBOutlet weak var pageControl: FSPageControl!
    var viewModel = HomeViewModel()
    var cancellables = Set<AnyCancellable>()
    let input = PassthroughSubject<HomeViewModel.Input, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        input.send(.viewDidLoad)
    }
    
    func setupUI() {
        navBar.delegate = self
        tableView.register(UINib(nibName: "CollectionViewTableViewCell", bundle: nil), forCellReuseIdentifier: "CollectionViewTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        pagerView.delegate = self
        pagerView.dataSource = self
        pagerView.isInfinite = true
        pagerView.automaticSlidingInterval = 4.0
        let height = pagerView.bounds.height
        let width = (height * 2) / 3
        pagerView.itemSize = CGSize(width: width, height: height)
        pagerView.transformer = FSPagerViewTransformer(type: .linear)
        self.pageControl.numberOfPages = 6
        self.pageControl.contentHorizontalAlignment = .center
        self.pageControl.setStrokeColor(.white, for: .normal)
        self.pageControl.setFillColor(.white, for: .selected)
        self.pageControl.itemSpacing = 8.0
        tableView.tableFooterView?.frame = CGRect(x: 0, y: 0, width: width, height: tabBarController?.tabBar.frame.size.height ?? 0.0)
        navigationController?.isNavigationBarHidden = true
    }
    
    func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .fetchDidSucceed:
                    self?.tableView.reloadData()
                    self?.pagerView.reloadData()
                case .fetchDidFail(let error):
                    print(error.localizedDescription)
                }
            }.store(in: &cancellables)
    }
    
}

extension HomeViewController: NavigationBarDelegate {
    func leftBtnDidTap() {
    }
    func profileBtnDidTap() {
        let vc = ProfileViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension HomeViewController: FSPagerViewDelegate, FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return 6
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.layer.cornerRadius = 15.0
        cell.imageView?.layer.masksToBounds = true
        let movie = self.viewModel.moviesForSections.first {
            $0.0 == Sections.Trending
        }?.1[index]
        let newUrl = "https://image.tmdb.org/t/p/w500/\(movie?.poster_path ?? "")"
        if let url = URL(string: newUrl) {
            cell.imageView?.sd_setImage(with: url)
        }
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        let vc = MovieDetailViewController()
        vc.viewModel.movie = self.viewModel.moviesForSections.first {
            $0.0 == Sections.Trending
        }?.1[index]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.pageControl.currentPage = targetIndex
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        self.pageControl.currentPage = pagerView.currentIndex
    }
    
}
extension HomeViewController: SectionHeaderTableViewDelegate {
    func didTap(section: Sections) {
        let vc = CategoryViewController()
        vc.section = section
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionViewTableViewCell", for: indexPath) as! CollectionViewTableViewCell
        let movies = self.viewModel.moviesForSections.first {
            $0.0.index == indexPath.section
        }?.1
        cell.configure(with: movies ?? [])
        cell.controller = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SectionHeaderTableView()
        view.delegate = self
        view.section = viewModel.sections[section]
        view.config()
        return view
    }
}
