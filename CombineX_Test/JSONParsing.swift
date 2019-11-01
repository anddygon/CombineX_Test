//
//  JSONParsing.swift
//  CombineX_Test
//
//  Created by anddy on 2019/11/1.
//  Copyright © 2019 anddy. All rights reserved.
//

import Moya
import CombineX
import Foundation

enum JSONParsingError: Error, CustomStringConvertible {
    case notIncludeKeyPath(keyPath: String)
    case notDictionary
    case other(Error)
    
    var description: String {
        switch self {
        case .notDictionary:
            return "json不是一个字典，而又指定了keyPath"
        case .notIncludeKeyPath(let path):
            return "json不包含keyPath: \(path)"
        case .other(let error):
            return "json解析错误，由于系统Api失败: \(error)"
        }
    }
}

extension Data {
    func map<T: Decodable>(type: T.Type, keyPath: String? = nil, decoder: JSONDecoder = .init()) throws -> T {
        do {
            if let keyPath = keyPath, !keyPath.isEmpty {
                guard let dict = try JSONSerialization.jsonObject(with: self, options: .allowFragments) as? [String: Any] else { throw JSONParsingError.notDictionary }
                guard let object = dict[keyPath] else { throw JSONParsingError.notIncludeKeyPath(keyPath: keyPath) }
                let data = try JSONSerialization.data(withJSONObject: object, options: .fragmentsAllowed)
                return try decoder.decode(type, from: data)
            } else {
                return try decoder.decode(type, from: self)
            }
        } catch {
            throw JSONParsingError.other(error)
        }
    }
}

extension Publisher where Output == Data {
    func tryMap<T: Decodable>(type: T.Type, keyPath: String? = nil, decoder: JSONDecoder = .init()) -> AnyPublisher<T, JSONParsingError> {
        tryMap { (data) -> T in
                try data.map(type: type, keyPath: keyPath, decoder: decoder)
            }
            .mapError({ $0 as! JSONParsingError })
            .eraseToAnyPublisher()
    }
}

extension Publisher where Output == Response {
    func tryMap<T: Decodable>(type: T.Type, keyPath: String? = nil, decoder: JSONDecoder = .init()) -> AnyPublisher<T, JSONParsingError> {
        map({ $0.data })
            .eraseToAnyPublisher()
            .tryMap(type: type, keyPath: keyPath, decoder: decoder)
    }
}
