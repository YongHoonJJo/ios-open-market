//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © Jost, 잼킹. All rights reserved.
// 

import UIKit

class ItemListViewController: UIViewController {
    private let apiClient = ApiClient()
    private var itemList: [MarketPageItem] = []
    private var nextPage = 1
    
    var list: [ThumbnailManger] = []
    var downloadTasks: [URLSessionTask] = []
    
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
//                    for item in marketPageItem.items {
//                        ImageManager.shared.performBatchUpdate(urls: item.thumbnails)
//                    }
                    
                    self.list = marketPageItem.items.map { ThumbnailManger(urlString: $0.thumbnails[0]) }
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
        
        if let image = list[indexPath.row].image { // image: UIImage // kind of Cache
            cell.updateThumbnailImage(to: image)
        } else {
            cell.updateThumbnailImage(to: nil)
            downloadImage(at: indexPath.row)
        }
        
        return cell
    }
}

extension ItemListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ItemCollectionViewCell {
            if let image = list[indexPath.row].image { // image: UIImage // kind of Cache
                cell.updateThumbnailImage(to: image)
            } else {
                cell.updateThumbnailImage(to: nil)
                downloadImage(at: indexPath.row)
            }
        }
    }
}

extension ItemListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            downloadImage(at: indexPath.item)
        }
    }
}

extension ItemListViewController {
    func downloadImage(at index: Int) {
        guard list[index].image == nil else {
            return
        }
        
        let targetUrl = list[index].url
        guard !downloadTasks.contains(where: { $0.originalRequest?.url == targetUrl }) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: targetUrl) { (data, response, error) in
            if let _ = error {
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                self.list[index].image = image // 캐싱.
                let reloadTargetIndexPath = IndexPath(row: index, section: 0)
                DispatchQueue.main.async {
                    if self.marketItemListCollectionView.indexPathsForVisibleItems.contains(reloadTargetIndexPath) == .some(true) {
                        self.marketItemListCollectionView.reloadItems(at: [reloadTargetIndexPath])
                    }
                }
                
                self.completeTask()
            }
        }
        task.resume()
        downloadTasks.append(task)
    }
    
    
    func completeTask() {
        downloadTasks = downloadTasks.filter { $0.state != .completed }
    }
}
