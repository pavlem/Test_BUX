//
//  WebSocketHelper.swift
//  TBux
//
//  Created by Pavle Mijatovic on 19/02/2021.
//

import Foundation
import Starscream

class WebSocketHelper {

    // MARK: - API
    var isConnected = false

    func subscribe(channelId: String, success: @escaping (String) -> Void) {
        self.newStockValue = success
        let str = "{\"subscribeTo\":[\"trading.product.\(channelId)\"]}"
        socket.write(string: str)
    }

    func unsubscribe(channelId: String, success: () -> Void) {
        let str = "{\"unsubscribeFrom\":[\"trading.product.\(channelId)\"]}"
        socket.write(string: str)
    }

    func disconnect(success: @escaping (String) -> Void) {
        connectionMessage = success

        guard self.isConnected else {
            success("Already disconnected from websocket")
            return
        }
        
        socket.disconnect()
        success("Disconnected from websocket")
    }

    func connect(success: @escaping (String) -> Void, fail: @escaping (String) -> Void) {
        connectionMessage = success

        guard self.isConnected == false else {
            success("Already connected to websocket")
            return
        }

        socket = WebSocket(request: self.request)
        socket.delegate = self
        socket.connect()
        failMessage = fail
    }

    // MARK: - Inits
    init(jwtToken: String, urlString: String) {
        self.jwtToken = jwtToken
        self.urlString = urlString
    }

    // MARK: - Properties
    private var jwtToken: String
    private var urlString: String
    private var connectionMessage: ((String) -> Void)?
    private var failMessage: ((String) -> Void)?
    private var newStockValue: ((String) -> Void)?

    private var socket: WebSocket!

    private var webSocketHeaders: [String: String] {
        [
            "Authorization": self.jwtToken,
            "Accept-Language": "nl-NL,en;q=0.8"
        ]
    }

    private var request: URLRequest {
        var request = URLRequest(url: URL(string: urlString)!)
        request.timeoutInterval = 5
        request.allHTTPHeaderFields = webSocketHeaders
        return request
    }
}

extension WebSocketHelper: WebSocketDelegate {

    static func getValue(jsonString: String) -> String? {
        let decoder = JSONDecoder()
        let jsonData = Data(jsonString.utf8)
        let ws = try? decoder.decode(WebSocketResponse.self, from: jsonData)
        return ws?.body?.currentPrice ?? nil
    }

    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
            if string.isBUXConneted {
                connectionMessage?("Connected to BUX")
                connectionMessage = nil
            } else if string.isBUXFailedToConnect {
                connectionMessage?("Connect to BUX Failed")
                connectionMessage = nil
            } else if let newValue = WebSocketHelper.getValue(jsonString: string) {
                self.newStockValue?(newValue)
            }
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            handleError(error)
        }
    }

    private func handleError(_ error: Error?) {
        var msg = ""
        if let err = error as? WSError {
            msg = "websocket encountered an error: \(err.message)"
        } else if let err = error {
            msg = "websocket encountered an error: \(err.localizedDescription)"
        } else {
            msg = "websocket encountered an error"
        }
        failMessage?(msg)
        failMessage = nil
    }
}

// MARK: - WebSocketHelper extensions
private extension String {
    var isBUXConneted: Bool {
        return self.contains("connect.connected")
    }

    var isBUXFailedToConnect: Bool {
        return self.contains("connect.failed")
    }
}

// MARK: - WebSocketResponse
extension WebSocketHelper {
    struct WebSocketResponse: Codable {
        let t, id: String?
        let v: Int?
        let body: WebSocketBodyResponse?
    }

    struct WebSocketBodyResponse: Codable {
        let securityId, currentPrice: String?
    }
}
