//
//  UIImageView+setImage.swift
//  CoinsExchange
//
//  Created by LMC60018 on 2024/1/23.
//

import Kingfisher
import UIKit

extension UIImageView {
    func prepareForReuse() {
        kf.cancelDownloadTask()
        image = nil
    }

    func setImage(_ url: URL?, downloadFinished: ((Result<Void, Error>) -> Void)? = nil) {
        guard let url = url else {
            kf.cancelDownloadTask()
            return
        }
        kf.indicatorType = .activity
        kf.setImage(with: url, completionHandler:  { result in
            switch result {
            case .success: downloadFinished?(.success(()))
            case let .failure(error): downloadFinished?(.failure(error))
            }
        })
    }
}
