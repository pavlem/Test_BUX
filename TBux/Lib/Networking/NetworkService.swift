//
//  NetworkService.swift
//  TBux
//
//  Created by Pavle Mijatovic on 17/02/2021.
//

import Foundation

public enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

enum NetworkError: Error {
    case badURL
    case requestFailed
    case unknown
    case jsonDecodeErr(description: String)
    case pageNotFound
    case clientRelated
    case serverRelated
    case noResponse
    case error(err: Error)
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .badURL:
            return "Bad URL"
        case .requestFailed:
            return "Request Failed"
        case .unknown:
            return "Unknown"
        case .jsonDecodeErr(description: let err):
            return err
        case .pageNotFound:
            return "Page Not Found"
        case .clientRelated:
            return "Page Not Found"
        case .serverRelated:
            return "Page Not Found"
        case .noResponse:
            return "Page Not Found"
        case .error(err: let err):
            return err.localizedDescription
        }
    }
}

public typealias JSON = [String: Any]
public typealias HTTPHeaders = [String: String]

private var authenticationHeader: HTTPHeaders = ["Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJyZWZyZXNoYWJsZSI6ZmFsc2UsInN1YiI6ImJiMGNkYTJiLWExMGUtNGVkMy1hZDVhLTBmODJiNGMxNTJjNCIsImF1ZCI6ImJldGEuZ2V0YnV4LmNvbSIsInNjcCI6WyJhcHA6bG9naW4iLCJydGY6bG9naW4iXSwiZXhwIjoxODIwODQ5Mjc5LCJpYXQiOjE1MDU0ODkyNzksImp0aSI6ImI3MzlmYjgwLTM1NzUtNGIwMS04NzUxLTMzZDFhNGRjOGY5MiIsImNpZCI6Ijg0NzM2MjI5MzkifQ.M5oANIi2nBtSfIfhyUMqJnex-JYg6Sm92KPYaUL9GKg"]

class NetworkService: NSObject {
    func getResponseError(httpResponse: HTTPURLResponse) -> NetworkError {
        // This is just to ilustrate handling of httpResponse non 200 codes, in this example for 404 I made .pageNotFound, then for 400 to 500 .clientRelated and for 500..<600 .serverRelated
        if httpResponse.statusCode == 404 {
            return .pageNotFound
        } else if (400..<500) ~= httpResponse.statusCode {
            return .clientRelated
        } else if (500..<600) ~= httpResponse.statusCode {
            return .serverRelated
        } else {
            return .unknown
        }
    }
}

// This is just a helper function I made to log response
extension NetworkService {
    func logResponse(data: Data?, httpResponse: URLResponse?, error: Error?) {
        print("⏪⏪⏪⏪⏪⏪⏪")
        print("data: \n\(String(describing: data))\n")
        print("response: \n\(String(describing: httpResponse))\n")
        print("error: \n\(String(describing: error))\n")

        guard let data = data else {
            print("⏪⏪⏪⏪⏪⏪⏪")
            return
        }

        print(data.prettyPrintedJSONString ?? "")
        print("⏪⏪⏪⏪⏪⏪⏪")
    }
}

// This is just a helper function I made to log response
extension URLRequest {
    func log() {
        print("⏩⏩⏩⏩⏩⏩⏩")
        print("METHOD: \(httpMethod ?? "")")
        print("URL: \(self)")
        if let body = httpBody {
            print("BODY: \n \(body.toString() ?? "")")
        } else {
            print("BODY: None")
        }
        print("HEADERS: \n \(allHTTPHeaderFields ?? ["":""])")
        print("⏩⏩⏩⏩⏩⏩⏩")
    }
}

// Some other helper extensions meant for NETWORKING layer
extension Data {
    func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }
}

extension Data {
    var prettyPrintedJSONString: NSString? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}

extension URLRequest {
    init(baseUrl: String, path: String, method: RequestMethod, params: JSON?, headers: HTTPHeaders? = nil) {
        let url = URL(baseUrl: baseUrl, path: path, params: params, method: method)
        self.init(url: url)
        httpMethod = method.rawValue

        setValue("application/json", forHTTPHeaderField: "Accept")
        setValue("application/json", forHTTPHeaderField: "Content-Type")

        if headers != nil {
            for (key, value) in headers! {
                setValue(value, forHTTPHeaderField: key)
            }
        }

        switch method {
        case .post, .put, .patch:
            guard let params = params else { break }
            let dataForBody = try! JSONSerialization.data(withJSONObject: params, options: [])
            httpBody = dataForBody
        default:
            break
        }
    }
}

extension URL {
    init(baseUrl: String, path: String, params: JSON?, method: RequestMethod) {
        var components = URLComponents(string: baseUrl)!
        components.path += path

        switch method {
        case .get, .delete:
            guard let params = params else { break }
            components.queryItems = params.map {
                URLQueryItem(name: $0.key, value: String(describing: $0.value))
            }
        default:
            break
        }

        self = components.url!
    }
}
