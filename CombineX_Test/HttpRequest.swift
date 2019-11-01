//
//  HttpRequest.swift
//  CombineX_Test
//
//  Created by anddy on 2019/11/1.
//  Copyright © 2019 anddy. All rights reserved.
//

import Moya
import CombineX
import Foundation

enum Api {
    case productIndex(start: Int, limit: Int)
}

extension Api: TargetType {
    var baseURL: URL {
        return URL.init(string: "https://www.stylewe.com/rest")!
    }
    
    var path: String {
        return "/productindex"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return .init()
    }
    
    var task: Task {
        switch self {
        case let .productIndex(start, limit):
            return .requestParameters(parameters: ["start": start, "limit": limit], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}

enum RequestError: LocalizedError {
    case noResponse
    case invalidStatusCode
    case other(MoyaError)
    case apiError(data: Data)
}

func request(api: Api) -> AnyPublisher<Response, RequestError> {
    var cancelable: Moya.Cancellable?
    return Future<Response, RequestError>.init { (promise) in
        cancelable = MoyaProvider.init().request(api) { (result) in
            switch result {
            case .success(let response):
                guard response.response != nil else { return promise(.failure(.noResponse)) }
                guard response.statusCode == 200 else { return promise(.failure(.apiError(data: response.data))) }
                promise(.success(response))
            case .failure(let error):
                promise(.failure(.other(error)))
            }
        }
    }
    .handleEvents(receiveCancel: {
        cancelable?.cancel()
    })
    .eraseToAnyPublisher()
}
