//
//  DemoCollectionViewController.swift
//  DemoApp
//
//  Created by Rajul Arora on 10/27/17.
//  Copyright © 2017 Twitter. All rights reserved.
//

import UIKit

class DemoCollectionViewController: UIViewController {

    // MARK: - Private Variables

    private var dataSource: DemoCollectionViewDataSource

    fileprivate lazy var collectionView: UICollectionView = { [unowned self] in
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .groupTableViewBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInset = UIEdgeInsets(top: 10.0, left: 0.0, bottom:10.0, right: 0.0)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()

    // MARK: - Init

    init(demos: [Demo]) {
        self.dataSource = DemoCollectionViewDataSource(demos: demos)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        dataSource.delegate = self
    }

    // MARK: - Private Methods

    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        dataSource.collectionView = collectionView
    }
}

extension DemoCollectionViewController: DemoCollectionViewDataSourceDelegate {
    func demoCollectionViewDataSource(dataSource: DemoCollectionViewDataSource, didSelectDemo demo: Demo) {
        switch demo.presentationStyle {
        case .push: navigationController?.pushViewController(demo.viewController, animated: true)
        case .modal: present(demo.viewController, animated: true, completion: nil)
        }

    }
}
