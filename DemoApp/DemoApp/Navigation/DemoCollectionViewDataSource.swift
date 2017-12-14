//
//  DemoCollectionViewDataSource.swift
//  DemoApp
//
//  Created by Rajul Arora on 10/27/17.
//  Copyright © 2017 Twitter. All rights reserved.
//

import UIKit

protocol DemoCollectionViewDataSourceDelegate {
    func demoCollectionViewDataSource(dataSource: DemoCollectionViewDataSource, didSelectDemo demo: Demo)
}

class DemoCollectionViewDataSource: NSObject {
    fileprivate static let cellIdentifier = "demoCell"

    // MARK: - Private Variables

    fileprivate var demos: [Demo] = []

    // MARK: - Public Variables

    var delegate: DemoCollectionViewDataSourceDelegate?

    weak var collectionView: UICollectionView? {
        didSet {
            collectionView?.delegate = self
            collectionView?.dataSource = self
            collectionView?.register(DemoCollectionViewCell.self, forCellWithReuseIdentifier: DemoCollectionViewDataSource.cellIdentifier)
            collectionView?.reloadData()
        }
    }

    // MARK: - Init

    required init(demos: [Demo]) {
        self.demos = demos
        super.init()
    }
}

// MARK: - UICollectionViewDataSource

extension DemoCollectionViewDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: DemoCollectionViewDataSource.cellIdentifier, for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return demos.count
    }
}

// MARK: - UICollectionViewDelegate

extension DemoCollectionViewDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.demoCollectionViewDataSource(dataSource: self, didSelectDemo: demos[indexPath.row])
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? DemoCollectionViewCell {
            cell.configure(with: demos[indexPath.row])
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension DemoCollectionViewDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let constrainedSize = CGSize(width: collectionView.frame.width - 20.0, height: CGFloat.greatestFiniteMagnitude)
        return DemoCollectionViewCell.sizeThatFits(constrainedSize, for: demos[indexPath.row])
    }
}
