//
//  ViewController.swift
//  PDPhotoPicker
//
//  Created by deng on 2021/5/26.
//

import UIKit
import Photos

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    // 所有照片数据
    var assets: [PHAsset] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        getAccess()
    }
}

// MARK: Make UI

extension ViewController {
    func makeUI() {
        collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseId)
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = layout
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = .init(top: 10, left: 10, bottom: 10, right: 10)
    }

    func updateUI() {
        getAssets()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

// MARK: Collection Delegate

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        assets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseId, for: indexPath) as! Cell
        let asset = assets[indexPath.row] // (row: 0, section: 0) 被拍照占用
        // 1. 归一化使其不拉伸
        let options = PHImageRequestOptions()
        options.resizeMode = .exact
        let width = CGFloat(asset.pixelWidth)
        let height = CGFloat(asset.pixelHeight)
        let length = min(width, height)
        let square = CGRect(x: 0, y: 0, width: length, height: length)
        options.normalizedCropRect = square.applying(.init(scaleX: 1 / width, y: 1 / height))
        PHImageManager.default().requestImage(for: assets[indexPath.row],
                                              targetSize: .init(width: 150, height: 150),
                                              contentMode: .aspectFill,
                                              options: options) { image, _ in
            cell.imageView.image = image
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 150, height: 150)
    }
}

// MARK: - Photos

extension ViewController {
    func getAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                self.updateUI()
            }
        }
    }

    func getAssets() {
        let options = PHFetchOptions()
        // https://developer.apple.com/documentation/photokit/phfetchoptions#1965657
        options.sortDescriptors = [.init(key: "creationDate", ascending: false)]
        let result = PHAsset.fetchAssets(with: .image, options: options)
        result.enumerateObjects { asset, _, _ in
            self.assets.append(asset)
        }
    }
}

// MARK: - Custom Type

extension ViewController {
    class Cell: UICollectionViewCell {
        static var reuseId: String { String(describing: Self.self) }
        let imageView = UIImageView()

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            configure()
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            configure()
        }

        func configure() {
            contentView.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
            ])
        }
    }
}

// MARK: - Navigation

extension ViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as? AlbumViewController
        destination?.closure = {
            self.updateUI()
        }
    }
}
