//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © Jost, 잼킹. All rights reserved.
// 

import UIKit

class ItemListViewController: UIViewController {
    private let apiClient = ApiClient()
    private var imageDownloadManger = ImageDownloadManager()
    
    private var nextPage = 1
    private let preloadCount = 8
    private var itemList: [MarketPageItem] = []
    
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var marketItemListCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        marketItemListCollectionView.prefetchDataSource = self
        designLayout()
        fetchItemList()
    }
    
    private func fetchItemList() {
        apiClient.getMarketPageItems(for: nextPage) { result in
            switch result {
            case .success(let marketPageItem):
                if marketPageItem.items.count > 0 {
                    self.itemList += marketPageItem.items
                    self.nextPage = marketPageItem.page + 1
                    
                    DispatchQueue.main.async {
                        self.loadingIndicator.stopAnimating()
                        self.marketItemListCollectionView.reloadData()
                    }
                }
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    private func reloadCollectionView(with indexPath: IndexPath) {
//        print(#function, indexPath.item, nextPage)
        DispatchQueue.main.async {
            if self.marketItemListCollectionView.indexPathsForVisibleItems.contains(indexPath) == .some(true) {
                self.marketItemListCollectionView.reloadItems(at: [indexPath])
            }
        }
        
        if itemList.count - indexPath.item == self.preloadCount {
//            print("self.fetchItemList()")
            self.fetchItemList()
        }
    }
    
    private func handleError(_ error: Error) {
        if let apiError = error as? ApiError {
            print(apiError)
        }
        if let parsingError = error as? ParsingError {
            print(parsingError)
        }
    }
    
    private func getItemCardHeight(with width: CGFloat) -> CGFloat {
        return (width / 3) * 5
    }
    
    private func designLayout() {
        let minimumInteritemSpacing = CGFloat(10)
        let minimumLineSpacing = CGFloat(10)
        let commonSectionInset = CGFloat(10)
        let numberOfCardPerRow = CGFloat(2)
        
        let itemCardWidth = (view.frame.width - (commonSectionInset * 2 + minimumInteritemSpacing)) / numberOfCardPerRow
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemCardWidth, height: getItemCardHeight(with: itemCardWidth))
        layout.minimumInteritemSpacing = minimumInteritemSpacing
        layout.minimumLineSpacing = minimumLineSpacing
        layout.sectionInset = UIEdgeInsets(top: commonSectionInset,
                                           left: commonSectionInset,
                                           bottom: commonSectionInset,
                                           right: commonSectionInset)
        
        marketItemListCollectionView.collectionViewLayout = layout
    }
}

extension ItemListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "cardItemCell"
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? ItemCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let marketItem = itemList[indexPath.item]
        cell.configure(with: marketItem)
        
        if let cachedImage = ImageCacheManager.shared.loadCachedData(key: marketItem.thumbnails[0]) {
            cell.updateThumbnailImage(to: cachedImage)
        } else {
            cell.updateThumbnailImage(to: nil)
            imageDownloadManger.downloadImage(at: indexPath.item, with: marketItem.thumbnails[0], completion: reloadCollectionView(with:))
        }
        
        return cell
    }
}

extension ItemListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ItemCollectionViewCell {
            let marketItem = itemList[indexPath.item]
            if let cachedImage = ImageCacheManager.shared.loadCachedData(key: marketItem.thumbnails[0]) {
                cell.updateThumbnailImage(to: cachedImage)
            } else {
                cell.updateThumbnailImage(to: nil)
                imageDownloadManger.downloadImage(at: indexPath.item, with: marketItem.thumbnails[0], completion: reloadCollectionView(with:))
            }
        }
    }
}

extension ItemListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let marketItem = itemList[indexPath.item]
            imageDownloadManger.downloadImage(at: indexPath.item, with: marketItem.thumbnails[0], completion: reloadCollectionView(with:))
        }
    }
}
