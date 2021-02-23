//
//  ProductListTVC.swift
//  TBux
//
//  Created by Pavle Mijatovic on 16/02/2021.
//

import UIKit

class ProductListTVC: UITableViewController {

    // MARK: - Properties
    // MARK: Var
    private var products = [ProductVM]() {
        didSet {
            DispatchQueue.main.async {
                self.refreshUI()
            }
        }
    }

    private var filteredProducts = [ProductVM]() {
        didSet {
            DispatchQueue.main.async {
                self.refreshUI()
            }
        }
    }

    private var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }

    private var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    private let searchController = UISearchController(searchResultsController: nil)
    private let searchPlaceholder = ProductVM.searchForProducts
    private var dataTask: URLSessionDataTask?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        setSearchController()
        fetchProducts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (!(self.isMovingToParent || self.isBeingPresented)) {
            self.navigationItem.title = ProductVM.productsTitle
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        dataTask?.cancel()
    }

    // MARK: - Helper
    private func refreshUI() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.navigationItem.title = ProductVM.productsTitle
        }
    }

    private func setUI() {
        navigationItem.title = ProductVM.productsFetching
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.tableFooterView!.isHidden = true
        navigationController?.isNavigationBarHidden = false
    }

    private func fetchProducts() {

        dataTask = ProductService.shared.fetchProducts { [weak self] (result) in
            guard let `self` = self else { return }
            
            switch result {
            case .success(let products):
                var productsLo = products.map { ProductVM(productResponse: $0) }
                productsLo.sort(by: {$0.name < $1.name})
                self.products = productsLo
            case .failure(let err):
                DispatchQueue.main.async {
                    AlertHelper.simpleAlert(message: err.errorDescription)
                }
            }
        }
    }

    private func setSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = searchPlaceholder

        definesPresentationContext = true
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }

    private func filter(searchText: String) {
        filteredProducts = products.filter { (productVM: ProductVM) -> Bool in
            return productVM.name.lowercased().contains(searchText.lowercased())
        }
    }
}

// MARK: - UISearchResultsUpdating
extension ProductListTVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filter(searchText: searchController.searchBar.text!)
    }
}

// MARK: - Table view data source
extension ProductListTVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if isFiltering {
            return filteredProducts.count
        } else {
            return products.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductListCell.cellIdentifier, for: indexPath) as! ProductListCell

        var vm: ProductVM

        if isFiltering {
            vm = filteredProducts[indexPath.row]
        } else {
            vm = products[indexPath.row]
        }

        cell.productVM = vm

        return cell
    }
}

// MARK: - Table view delegate
extension ProductListTVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard ReachabilityHelper.isThereInternetConnection else {
            AlertHelper.simpleAlert(message: ReachabilityHelper.noInternetMessage)
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }

        var vm: ProductVM

        if isFiltering {
            vm = filteredProducts[indexPath.row]
        } else {
            vm = products[indexPath.row]
        }

        let vc = UIStoryboard.productDetailsVC
        vc.prodDetailsVM = ProductDetailsVM(productVM: vm)
        navigationController?.customPush(vc)
    }
}
