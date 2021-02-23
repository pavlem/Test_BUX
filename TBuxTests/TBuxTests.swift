//
//  TBuxTests.swift
//  TBuxTests
//
//  Created by Pavle Mijatovic on 09/02/2021.
//

import XCTest
@testable import TBux

class TBuxTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: WebSocketHelper
    func testGetValueFromJsonString() {

        var string = "{\"t\":\"trading.quote\",\"id\":\"707c12b2-72f7-11eb-92d2-5dd1d89adc2c\",\"v\":2,\"body\":{\"securityId\":\"sb37392\",\"currentPrice\":\"56208.75\"}}"

        XCTAssert(WebSocketHelper.getValue(jsonString: string) == "56208.75")

        string = "{\"t\":\"trading.quote\",\"id\":\"707c12b2-72f7-11eb-92d2-5dd1d89adc2c\",\"v\":2,\"body\":{\"securityId\":\"sb37392\",\"currentPrice\":\"1234.75\"}}"
        XCTAssert(WebSocketHelper.getValue(jsonString: string) == "1234.75")

        string = "{\"t\":\"trading.quote\",\"id\":\"707c12b2-72f7-11eb-92d2-5dd1d89adc2c\",\"v\":2,\"body\":{\"securityId\":\"sb37392\",\"currentPrice\":\"1234\"}}"
        XCTAssert(WebSocketHelper.getValue(jsonString: string) == "1234")
    }


    // MARK: extension String
    func testCurrencySymbols() {
        XCTAssert("USD".getSymbolForCurrencyCode() == "US$")
        XCTAssert("usd".getSymbolForCurrencyCode() == "US$")
        XCTAssert("uSD".getSymbolForCurrencyCode() == "US$")
        XCTAssert("EUR".getSymbolForCurrencyCode() == "€")
        XCTAssert("JPY".getSymbolForCurrencyCode() == "JP¥")
        XCTAssert("GBP".getSymbolForCurrencyCode() == "£")
        XCTAssert("RSD".getSymbolForCurrencyCode() == "RSD")
    }

    // MARK: Network Tests
    func testGetProductsFromJSONResponse() {
        let asyncExpectation = expectation(description: "Async block executed")

        TBuxTests.fetchMOCProducts { (products) in
            XCTAssert(products.count == 43)
            asyncExpectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testGetProductFromJSONResponse() {
        let asyncExpectation = expectation(description: "Async block executed")

        TBuxTests.fetchMOCProduct { (product) in
            XCTAssert(product.symbol == "China A50")
            XCTAssert(product.displayName == "China A50")
            XCTAssert(product.quoteCurrency == "USD")
            XCTAssert(product.category == "INDICES")
            XCTAssert(product.description == "Van de meeste bedrijven in deze index heb je misschien nog nooit gehoord, maar toch hebben zij de wind mee in de tweede economie van de wereld: China. Enorme staatsbedrijven zoals China Railway Construction, het oliebedrijf PetroChina en de \'4 grote Chinese banken\'.")

            print("")

            asyncExpectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    static func fetchMOCProduct(delay: Int = 0, completion: @escaping (ProductResponse) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) {
            let filePath = "productDetailsMOC"
            TBuxTests.loadJsonDataFromFile(filePath, completion: { data in
                if let json = data {
                    do {
                        let product = try JSONDecoder().decode(ProductResponse.self, from: json)
                        completion(product)
                    } catch _ as NSError {
                        fatalError("Couldn't load data from \(filePath)")
                    }
                }
            })
        }
    }

    static func fetchMOCProducts(delay: Int = 0, completion: @escaping ([ProductResponse]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) {
            let filePath = "productsMOC"
            TBuxTests.loadJsonDataFromFile(filePath, completion: { data in
                if let json = data {
                    do {
                        let products = try JSONDecoder().decode([ProductResponse].self, from: json)
                        completion(products)
                    } catch _ as NSError {
                        fatalError("Couldn't load data from \(filePath)")
                    }
                }
            })
        }
    }

    static func loadJsonDataFromFile(_ path: String, completion: (Data?) -> Void) {
        if let fileUrl = Bundle.main.url(forResource: path, withExtension: "json") {
            do {
                let data = try Data(contentsOf: fileUrl, options: [])
                completion(data as Data)
            } catch let error {
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }

    // MARK: ProductVM
    func testProductVM() {

        let asyncExpectation = expectation(description: "Async block executed")

        TBuxTests.fetchMOCProduct { (prodResponse) in
            let productVM = ProductVM(productResponse: prodResponse)

            XCTAssert(productVM.name == "China A50")
            XCTAssert(productVM.currency == "USD")
            XCTAssert(productVM.category == "INDICES")
            XCTAssert(productVM.currentPrice == "19959")
            XCTAssert(productVM.closingPrice == "19986")

            XCTAssert(productVM.currencySymbol == "US$")
            XCTAssert(productVM.formatedPrice == "▼ 19.959 US$")
            XCTAssert(productVM.formatedName == "China A50 (USD)")
            XCTAssert(productVM.priceColor.description == "UIExtendedSRGBColorSpace 0.560784 0.203922 0.184314 1")

            asyncExpectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testIsClosingPriceLarger() {
        var isClosingPriceLarger = ProductVM.isClosingPriceLarger(current: "1234", closing: "1235")
        XCTAssert(isClosingPriceLarger == true)
        isClosingPriceLarger = ProductVM.isClosingPriceLarger(current: "1234", closing: "123")
        XCTAssert(isClosingPriceLarger == false)
        isClosingPriceLarger = ProductVM.isClosingPriceLarger(current: "1234", closing: "1234")
        XCTAssert(isClosingPriceLarger == false)
        isClosingPriceLarger = ProductVM.isClosingPriceLarger(current: "1222.00", closing: "1232.13")
        XCTAssert(isClosingPriceLarger == true)
    }

    func testGrowthSymbolForPrice() {
        var growthSymbol = ProductVM.growthSymbolForPrice(current: "123", closing: "124")
        XCTAssert(growthSymbol == "▼")
        growthSymbol = ProductVM.growthSymbolForPrice(current: "123", closing: "122")
        XCTAssert(growthSymbol == "▲")
        growthSymbol = ProductVM.growthSymbolForPrice(current: "123", closing: "123")
        XCTAssert(growthSymbol == "◼︎")
    }

    func testPriceColor() {
        var priceColor = ProductVM.priceColor(current: "123", closing: "124")
        XCTAssert(priceColor.debugDescription == "UIExtendedSRGBColorSpace 0.560784 0.203922 0.184314 1")
        priceColor = ProductVM.priceColor(current: "125", closing: "124")
        XCTAssert(priceColor.debugDescription == "UIExtendedSRGBColorSpace 0.247059 0.560784 0.231373 1")
        priceColor = ProductVM.priceColor(current: "124", closing: "124")
        XCTAssert(priceColor.debugDescription == "UIExtendedGrayColorSpace 0.333333 1")
    }

    // MARK: ProductDetailsVM
    func testProductDetailsVM() {

        let asyncExpectation = expectation(description: "Async block executed")

        TBuxTests.fetchMOCProduct { (prodResponse) in
            let vm = ProductDetailsVM(productResponse: prodResponse)

            XCTAssert(vm.isFetching == false)
            XCTAssert(vm.name == "China A50")
            XCTAssert(vm.currency == "USD")
            XCTAssert(vm.category == "INDICES")
            XCTAssert(vm.currentPrice == "19959")
            XCTAssert(vm.closingPrice == "19986")
            XCTAssert(vm.timeZone == "Asia/Singapore")
            XCTAssert(vm.isWebSocketConnected == false)
            XCTAssert(vm.isChannelMonitored == false)
            XCTAssert(vm.description == "Van de meeste bedrijven in deze index heb je misschien nog nooit gehoord, maar toch hebben zij de wind mee in de tweede economie van de wereld: China. Enorme staatsbedrijven zoals China Railway Construction, het oliebedrijf PetroChina en de \'4 grote Chinese banken\'.")
            XCTAssert(vm.deltaInPriceVal == "▼ -0.135 %")
            XCTAssert(ProductDetailsVM.getDelta(currentPrice: "100", closingPrice: "200") == "-50.0 %")
            XCTAssert(ProductDetailsVM.getDelta(currentPrice: "111", closingPrice: "211") == "-47.393 %")
            XCTAssert(ProductDetailsVM.getDelta(currentPrice: "100", closingPrice: "30") == "233.333 %")
            XCTAssert(vm.previousDayPriceVal == "19.986 US$")
            XCTAssert(vm.deltaInPriceVal == "▼ -0.135 %")
            XCTAssert(vm.currencySymbol == "US$")
            XCTAssert(vm.nameFetching == "Fetching for: China A50")

            asyncExpectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
}
