//
//  AlbumViewController.swift
//  PDPhotoPicker
//
//  Created by deng on 2021/5/26.
//

import UIKit
import Photos

class AlbumViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var closure: ((PHAssetCollection) -> Void)?
    var albums: [PHAssetCollection] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        updateUI()
    }

    deinit {
        print("# \(self) deinit__")
    }
}

// MARK: - Make UI

extension AlbumViewController {
    func makeUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(Cell.self, forCellReuseIdentifier: Cell.reuseId)
    }

    func updateUI() {
        getAlbums()
        tableView.reloadData()
    }
}

// MARK: - Photos

extension AlbumViewController {
    func getAlbums() {
        let result = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                subtype: .albumRegular,
                                                options: nil)
        result.enumerateObjects { collection, _, _ in
            self.albums.append(collection)
        }
    }
}

// MARK: - Table View Delegate

extension AlbumViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        albums.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.reuseId, for: indexPath) as! Cell
        cell.textLabel?.text = albums[indexPath.row].localizedTitle
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        closure?(albums[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Custom Style

extension AlbumViewController {
    class Cell: UITableViewCell {
        static var reuseId: String { String(describing: Self.self) }
    }
}
