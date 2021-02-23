//
//  ProductService.swift
//  TBux
//
//  Created by Pavle Mijatovic on 17/02/2021.
//

import Foundation

class ProductService: NetworkService {
    
    // MARK: - API
    static let shared = ProductService()
    
    func fetchProductDetail(fromIdentifier identifier: String, completion: @escaping (Result<ProductResponse, NetworkError>) -> ()) -> URLSessionDataTask? {
        
        let path = "\(productsPath)\(identifier)"
        
        return fetch(urlString: baseUrlString, path: path, method: .get, params: nil, headers: authenticationHeader) { (result: Result<ProductResponse, NetworkError>) in
            completion(result)
        }
    }
    
    func fetchProducts(completion: @escaping (Result<[ProductResponse], NetworkError>) -> ()) -> URLSessionDataTask? {
        
        return fetch(urlString: baseUrlString, path: productsPath, method: .get, params: nil, headers: authenticationHeader) { (result: Result<[ProductResponse], NetworkError>) in
            completion(result)
        }
    }

    static let baseWebSocketUrlString = "https://rtf.beta.getbux.com/subscriptions/me"
    static let authenticationToken = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJyZWZyZXNoYWJsZSI6ZmFsc2UsInN1YiI6ImJiMGNkYTJiLWExMGUtNGVkMy1hZDVhLTBmODJiNGMxNTJjNCIsImF1ZCI6ImJldGEuZ2V0YnV4LmNvbSIsInNjcCI6WyJhcHA6bG9naW4iLCJydGY6bG9naW4iXSwiZXhwIjoxODIwODQ5Mjc5LCJpYXQiOjE1MDU0ODkyNzksImp0aSI6ImI3MzlmYjgwLTM1NzUtNGIwMS04NzUxLTMzZDFhNGRjOGY5MiIsImNpZCI6Ijg0NzM2MjI5MzkifQ.M5oANIi2nBtSfIfhyUMqJnex-JYg6Sm92KPYaUL9GKg"
    
    // MARK: - Properties
    private let baseUrlString = "https://api.beta.getbux.com/core/23/"
    private let productsPath = "/products/"
    private var authenticationHeader: HTTPHeaders = ["Authorization": authenticationToken]


    // MARK: - Helper
    private func fetch<M: Decodable>(urlString: String, path: String, method: RequestMethod, params: JSON?, headers: HTTPHeaders?, completion: @escaping (Result<M, NetworkError>) -> ()) -> URLSessionDataTask? {
        
        let request = URLRequest(baseUrl: urlString, path: path, method: method, params: params, headers: headers)

        #if DEBUG
        request.log()
        #endif

        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, resp, err) in
            guard let `self` = self else { return }

            #if DEBUG
            self.logResponse(data: data, httpResponse: resp, error: err)
            #endif

            if let err = err {
                completion(.failure(NetworkError.error(err: err)))
                return
            }

            guard let data = data else {
                completion(.failure(.unknown))
                return
            }


            guard let httpResponse = resp as? HTTPURLResponse, (200..<300) ~= httpResponse.statusCode else {

                let responseErr = self.getResponseError(httpResponse: resp as! HTTPURLResponse)
                completion(.failure(responseErr))

                return
            }

            do {
                let genericObject = try JSONDecoder().decode(M.self, from: data)
                completion(.success(genericObject))
            } catch let jsonErr {
                completion(.failure(.jsonDecodeErr(description: String(describing: jsonErr))))
            }
        }
        
        task.resume()
        return task
    }
}
