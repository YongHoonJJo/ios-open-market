//
//  ItemFormViewController.swift
//  OpenMarket
//
//  Created by 잼킹 on 2021/08/25.
//

import UIKit

class ItemFormViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

extension ItemFormViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "addImageCell", for: indexPath) as? ImagePickerTableViewCell else {
            return UITableViewCell()
        }
        
        return cell
    }
}
