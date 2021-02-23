//
//  ProductDetailsVC.swift
//  TBux
//
//  Created by Pavle Mijatovic on 16/02/2021.
//

import UIKit
import Starscream

class ProductDetailsVC: UIViewController {

    // MARK: - API
    var prodDetailsVM: ProductDetailsVM? {
        willSet {
            DispatchQueue.main.async {
                self.updateUI(vm: newValue)
            }
        }
    }

    // MARK: - Properties
    @IBOutlet weak var currentPriceLbl: UILabel!
    @IBOutlet weak var currentPriceValLbl: UILabel!
    @IBOutlet weak var previousDayPriceLbl: UILabel!
    @IBOutlet weak var previousDayPriceValLbl: UILabel!
    @IBOutlet weak var deltaInPriceLbl: UILabel!
    @IBOutlet weak var deltaInPriceValLbl: UILabel!
    @IBOutlet weak var connectionIndicator: StatusIndicator!
    @IBOutlet weak var liveMonitoringIndicator: StatusIndicator!

    @IBOutlet weak var liveMonitorBtn: BuxBtn!
    @IBOutlet weak var connectToChannelBtn: BuxBtn!
    @IBOutlet weak var detailsTxtView: UITextView!
    private var dataTask: URLSessionDataTask?

    private var webSocketHelper = WebSocketHelper(jwtToken: ProductService.authenticationToken, urlString: ProductService.baseWebSocketUrlString)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setTxt()
        setUI()

        ReachabilityHelper.shared.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchProductDetails(forId: prodDetailsVM?.id ?? "")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        webSocketHelper.disconnect { message in }
    }

    // MARK: - Actions
    @IBAction func connect(_ sender: UIButton) {
        
        guard ReachabilityHelper.isThereInternetConnection else {
            AlertHelper.simpleAlert(message: ReachabilityHelper.noInternetMessage)
            return
        }

        sender.isSelected = !sender.isSelected

        if sender.isSelected {
            var vm = self.prodDetailsVM

            webSocketHelper.connect { _ in
                vm?.isWebSocketConnected = true
                self.prodDetailsVM = vm
            } fail: { (failMsg) in
                AlertHelper.simpleAlert(message: failMsg)
                vm?.isWebSocketConnected = false
                self.prodDetailsVM = vm
            }

        } else {

            webSocketHelper.disconnect { _ in
                var vm = self.prodDetailsVM
                vm?.isWebSocketConnected = false
                vm?.isChannelMonitored = false
                self.prodDetailsVM = vm
            }
        }
    }

    @IBAction func liveMonitor(_ sender: UIButton) {

        guard ReachabilityHelper.isThereInternetConnection else {
            AlertHelper.simpleAlert(message: ReachabilityHelper.noInternetMessage)
            return
        }

        guard let id = prodDetailsVM?.id else {
            AlertHelper.simpleAlert(message: "No Stock ID present")
            return
        }

        guard webSocketHelper.isConnected else {
            AlertHelper.simpleAlert(message: "Please connect to the channel first")
            return
        }

        sender.isSelected = !sender.isSelected

        liveMonitoringIndicator.isConnected = sender.isSelected

        if sender.isSelected {
            webSocketHelper.subscribe(channelId: id) { (newValue) in
                var vm = self.prodDetailsVM
                vm?.isChannelMonitored = true
                vm?.isWebSocketConnected = true
                vm?.currentPrice = newValue
                self.prodDetailsVM = vm
            }
        } else {

            var vm = self.prodDetailsVM
            vm?.isChannelMonitored = false
            self.prodDetailsVM = vm

            webSocketHelper.unsubscribe(channelId: id) {}
        }
    }

    // MARK: - Helper
    private func fetchProductDetails(forId id: String) {

        dataTask = ProductService.shared.fetchProductDetail(fromIdentifier: id, completion: { [weak self] (result) in
            guard let `self` = self else { return }

            sleep(1) // Just for for ilustration purpose (for the slow connection case to show the blocking screen)
            
            switch result {
            case .success(let productResponse):
                self.prodDetailsVM = ProductDetailsVM(productResponse: productResponse)
            case .failure(let err):
                DispatchQueue.main.async {
                    AlertHelper.alert(message: err.errorDescription) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        })
    }

    private func setTxt() {
        currentPriceLbl.text = ""
        currentPriceValLbl.text = ""
        previousDayPriceLbl.text = ""
        previousDayPriceValLbl.text = ""
        deltaInPriceLbl.text = ""
        deltaInPriceValLbl.text = ""
        detailsTxtView.text = ""
    }

    private func updateUI(vm: ProductDetailsVM?) {
        guard let vm = vm else { return }
        guard vm.isFetching == false else { return }

        BlockingScreen.stop()

        title = vm.nameDescription
        currentPriceLbl.text = vm.currentPriceDescription
        currentPriceValLbl.text = vm.currentPriceVal
        previousDayPriceLbl.text = vm.previousDayPrice
        previousDayPriceValLbl.text = vm.previousDayPriceVal
        deltaInPriceLbl.text = vm.deltaInPrice
        deltaInPriceValLbl.text = vm.deltaInPriceVal
        detailsTxtView.attributedText = vm.attributedDetails

        connectionIndicator.isConnected = vm.isWebSocketConnected
        liveMonitoringIndicator.isConnected = vm.isChannelMonitored

        currentPriceValLbl.textColor = vm.priceColor
        deltaInPriceValLbl.textColor = vm.priceColor

        liveMonitorBtn.selectedStateTxt = vm.stopLiveBtnTxt
        liveMonitorBtn.notSelectedStateTxt = vm.startLiveBtnTxt
        connectToChannelBtn.selectedStateTxt = vm.disconnectBtnTxt
        connectToChannelBtn.notSelectedStateTxt = vm.connectBtnTxt

        liveMonitorBtn.isSelected = vm.isChannelMonitored
        connectToChannelBtn.isSelected = vm.isWebSocketConnected
    }

    private func setUI() {
        BlockingScreen.start(vc: self)
        guard let vm = prodDetailsVM else { return }

        title = prodDetailsVM?.nameFetching

        liveMonitorBtn.setTitle(vm.startLiveBtnTxt, for: .normal)
        connectToChannelBtn.setTitle(vm.connectBtnTxt, for: .normal)
        connectionIndicator.isConnected = vm.isWebSocketConnected
        liveMonitoringIndicator.isConnected = vm.isChannelMonitored

        currentPriceLbl.textColor = vm.labelColor
        previousDayPriceLbl.textColor = vm.labelColor
        deltaInPriceLbl.textColor = vm.labelColor
        detailsTxtView.textColor = vm.labelColor
        previousDayPriceValLbl.textColor = vm.labelColor

        currentPriceLbl.font = vm.labelFont
        previousDayPriceLbl.font = vm.labelFont
        deltaInPriceLbl.font = vm.labelFont

        currentPriceValLbl.font = vm.priceFont
        previousDayPriceValLbl.font = vm.priceFont
        deltaInPriceValLbl.font = vm.priceFont
    }
}

extension ProductDetailsVC: ReachabilityHelperProtocol {
    func noInternet() {

        var vm = prodDetailsVM
        vm?.isChannelMonitored = false
        vm?.isWebSocketConnected = false
        prodDetailsVM = vm

        AlertHelper.simpleAlert(message: ReachabilityHelper.noInternetMessage)
    }
}
