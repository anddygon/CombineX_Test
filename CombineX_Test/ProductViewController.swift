//
//  ProductViewController.swift
//  CombineX_Test
//
//  Created by anddy on 2019/11/1.
//  Copyright © 2019 anddy. All rights reserved.
//

import UIKit
import CombineX

class ProductViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let products = CurrentValueSubject<[Product], Never>([])
    private let requestPublisher = PassthroughSubject<Void, Never>()
    private var cancelableSet = Set<AnyCancellable>()
    
    private let aiv: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView.init(style: .gray)
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        bind()
    }
    
    private func config() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib.init(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        navigationItem.titleView = aiv
    }
    
    private func bind() {
        requestPublisher
            .map({ (_) in
                request(api: .productIndex(start: .random(in: 0...100), limit: 10))
                .tryMap(type: [Product].self, keyPath: "list")
                .print()
                .handleEvents(receiveSubscription: { (_) in
                    self.aiv.startAnimating()
                },receiveCompletion: { (_) in
                    self.aiv.stopAnimating()
                }, receiveCancel: {
                    self.aiv.stopAnimating()
                })
                .catch { (error) in
                    return Empty<[Product], Never>.init()
                }
                .eraseToAnyPublisher()
            })
            .switchToLatest()
            .sink { [weak self] (products) in
                guard let self = self else { return }
                self.products.send(products)
            }
            .store(in: &cancelableSet)
        
        products
            .removeDuplicates()
            .sink { [weak self] (_) in
                guard let self = self else { return }
                self.tableView.reloadData()
            }
            .store(in: &cancelableSet)
    }
    
    @IBAction func onRefreshTapped(_ sender: Any) {
        requestPublisher.send()
    }
}

extension ProductViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        let product = products.value[indexPath.row]
        cell.fill(data: product)
        return cell
    }
}

extension ProductViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

