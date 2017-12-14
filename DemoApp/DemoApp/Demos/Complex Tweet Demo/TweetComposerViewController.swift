//
//  TweetComposerViewController.swift
//  DemoApp
//
//  Created by Rajul Arora on 10/31/17.
//  Copyright © 2017 Twitter. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos

class TweetComposerViewController: UIViewController {

    enum ComposerType {
        case tweetComposer
        case tweetViewController
        case tweetViewControllerWithMedia
        case tweetViewControllerLastPhoto
    }

    enum PhotosError: Error {
        case emptyFetchResult
        case imageNotFound
    }

    // MARK: - Private Variables

    private lazy var composer: TWTRComposer = {
        let composer = TWTRComposer()
        composer.setText("Hello World.")
        return composer
    }()

    private var composerType: ComposerType

    // MARK: - Init

    required init(composerType: ComposerType) {
        self.composerType = composerType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentComposer()
    }

    // MARK: - Private Methods

    private func presentComposer() {
        switch composerType {
        case .tweetComposer: presentTweetComposer()
        case .tweetViewController: presentTweetViewController()
        case .tweetViewControllerWithMedia: presentTweetViewControllerWithMedia()
        case .tweetViewControllerLastPhoto: presentTweetViewControllerLastPhoto()
        }
    }

    private func presentTweetComposer() {
        composer.show(from: self) { [weak self] _ in
            self?.dismiss(animated: false, completion: nil)
        }
    }

    private func presentTweetViewController() {
        let composer = TWTRComposerViewController.emptyComposer()
        composer.delegate = self
        present(composer, animated: true, completion: nil)
    }

    private func presentTweetViewControllerWithMedia() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.mediaTypes = [String(kUTTypeImage), String(kUTTypeMovie)]
        picker.modalPresentationStyle = .overCurrentContext
        present(picker, animated: true, completion: nil)
    }

    private func presentTweetViewControllerLastPhoto() {
        fetchLastPhoto { [weak self] (image, error) in
            if let error = error, let weakSelf = self {
                UIAlertController.showAlert(with: error, on: weakSelf)
            } else if let image = image {
                let composer = TWTRComposerViewController(initialText: "Check out this photo!", image: image, videoData: nil)
                composer.delegate = self
                self?.present(composer, animated: true)
            }
        }
    }

    private func fetchLastPhoto(_ completion: @escaping (UIImage?, Error?) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]

        guard let image = (PHAsset.fetchAssets(with: .image, options: fetchOptions)).lastObject else {
            completion(nil, PhotosError.emptyFetchResult)
            return
        }

        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestAVAsset(forVideo: image, options: options) { (asset, mix, info) in
            DispatchQueue.main.async {
                let size = CGSize(width: 50.0, height: 50.0)
                PHImageManager.default().requestImage(for: image, targetSize: size, contentMode: .aspectFit, options: nil) { (image, info) in
                    if let image = image {
                        completion(image, nil)
                    } else {
                        completion(nil, PhotosError.imageNotFound)
                    }
                }
            }
        }
    }
}

// MARK: - TWTRComposerViewControllerDelegate

extension TweetComposerViewController: TWTRComposerViewControllerDelegate {
    func composerDidCancel(_ controller: TWTRComposerViewController) {
        dismiss(animated: false, completion: nil)
    }

    func composerDidFail(_ controller: TWTRComposerViewController, withError error: Error) {
        dismiss(animated: false, completion: nil)
    }

    func composerDidSucceed(_ controller: TWTRComposerViewController, with tweet: TWTRTweet) {
        dismiss(animated: false, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension TweetComposerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true) {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let composer = TWTRComposerViewController(initialText: "Check out this great image: ", image: image, videoURL: nil)
            composer.delegate = self
            self.present(composer, animated: true)
        }
    }
}
