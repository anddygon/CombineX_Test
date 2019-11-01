//
//  TableViewCell.swift
//  CombineX_Test
//
//  Created by anddy on 2019/11/1.
//  Copyright © 2019 anddy. All rights reserved.
//

import UIKit
import CombineX
import CXUtility
import CXFoundation

class TableViewCell: UITableViewCell {
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    private var cancelableSet = Set<AnyCancellable>()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.layer.cornerRadius = 8
        avatarView.layer.masksToBounds = true
        avatarView.backgroundColor = .groupTableViewBackground
        avatarView.contentMode = .scaleAspectFit
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cancelableSet = []
    }
    
    @available(iOS 13.0, *)
    func fill(data: Product) {
        titleLabel.text = data.name
        priceLabel?.text = data.price.price
        
        let string = ("https://www.stylewe.com" + data.image).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL.init(string: string)!
        
        Future<Data, Error>.init { (promise) in
            DispatchQueue.global().async {
                do {
                    let data = try Data.init(contentsOf: url)
                    promise(.success(data))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .map(UIImage.init(data: ))
        .replaceError(with: nil)
        .prepend(nil)
        .print()
        .sink { [weak self] (image) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.avatarView.image = image
            }
        }
        .store(in: &cancelableSet)
    }
}
