//
//  UpComingViewController.swift
//  NetfilxClone
//
//  Created by tungdd on 26/06/2023.
//

import UIKit
import Combine

class UpcomingViewController: UIViewController {
    
    @IBOutlet weak var upcomingTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var navBar: NavigationBarView!
    private var viewModel = UpcomingViewModel()
    private let input = PassthroughSubject<UpcomingViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        input.send(.viewDidLoad)
    }
    
    func setupUI(){
        navBar.delegate = self
        titleLabel.text = "Upcoming"
        navigationController?.isNavigationBarHidden = true
        upcomingTableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        upcomingTableView.dataSource = self
        upcomingTableView.delegate = self
    }
    
    func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] event in
                switch event {
                case .fetchDidSucceed:
                    self?.upcomingTableView.reloadData()
                case .fetchDidFail(let error):
                    print(error.localizedDescription)
                }
            }.store(in: &cancellables)
    }
}

extension UpcomingViewController: NavigationBarDelegate {
    func leftBtnDidTap() {
    }
    func rightBtn1DidTap() {
        let vc = ProfileViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension UpcomingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.movies.value.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = upcomingTableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.configure(movie: viewModel.movies.value[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MovieDetailViewController()
        vc.viewModel.movie = viewModel.movies.value[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
