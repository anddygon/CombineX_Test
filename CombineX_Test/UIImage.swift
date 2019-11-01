//
//  UIImage.swift
//  CombineX_Test
//
//  Created by anddy on 2019/11/1.
//  Copyright © 2019 anddy. All rights reserved.
//

import UIKit
import CombineX
import Kingfisher

extension UIImageView {
    func setImage(url: URL) -> AnyPublisher<UIImage, Error> {
        var task: DownloadTask?
        return Future.init { (promise) in
            let iv = UIImageView.init(frame: .zero)
            task = iv.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (result) in
                switch result {
                case .success(let result):
                    promise(.success(result.image))
                case .failure(let error):
                    promise(.failure(error))
                }
            })
        }
        .handleEvents(receiveCancel: {
            task?.cancel()
        })
        .eraseToAnyPublisher()
    }
}
