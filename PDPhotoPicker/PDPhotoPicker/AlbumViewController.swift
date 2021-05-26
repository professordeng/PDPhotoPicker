//
//  AlbumViewController.swift
//  PDPhotoPicker
//
//  Created by deng on 2021/5/26.
//

import UIKit

class AlbumViewController: UIViewController {

    var closure: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    deinit {
        print("# \(self) deinit__")
    }
}
