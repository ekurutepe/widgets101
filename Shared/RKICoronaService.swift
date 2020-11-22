//
//  RKICoronaService.swift
//  Widgets101
//
//  Created by Engin Kurutepe on 22.11.20.
//

import Foundation

class RKICoronaService {
    enum Error: Swift.Error {
        case noData
        case jsonDecodingError(underlying: Swift.Error?)
        case connectionError(underlying: Swift.Error?)
        case invalidData
    }
    static let shared = RKICoronaService()

    let baseURL = URL(string: "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services")!

    func fetchGermany(completion: @escaping (Result<Int, Error>) -> Void) {
        var url = URL(string: "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/RKI_COVID19/FeatureServer/0/query")!
        let URLParams = [
            "f": "json",
            "where": "NeuerFall IN(1, -1)",
            "returnGeometry": "false",
            "spatialRel": "esriSpatialRelIntersects",
            "outFields": "*",
            "outStatistics": "[{\"statisticType\":\"sum\",\"onStatisticField\":\"AnzahlFall\",\"outStatisticFieldName\":\"value\"}]",
            "resultType": "standard",
            "cacheHint": "true",
        ]
        url = url.appendingQueryParameters(URLParams)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if (error == nil) {
                guard
                    let data = data
                else {
                    completion(.failure(.noData))
                    return
                }

                let resultDict: [String: Any]
                do {
                    guard let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                        completion(.failure(.invalidData))
                        return
                    }
                    resultDict = dict
                } catch {
                    completion(.failure(.jsonDecodingError(underlying: error)))
                    return
                }

                guard
                    let features = resultDict["features"] as? [[String: Any]],
                    let feature = features.first,
                    let attributes = feature["attributes"] as? [String: Any],
                    let value = attributes["value"] as? Int
                else {
                    completion(.failure(.invalidData))
                    return
                }

                completion(.success(value))

            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription);
                completion(.failure(.connectionError(underlying: error)))
            }
        })
        task.resume()
    }

    func fetchCoordinate(latitude: Double, longitude: Double, completion: @escaping (Result<LocalIncidence, Error>) -> Void) {
        var url = URL(string: "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/RKI_Landkreisdaten/FeatureServer/0/query")!
        let URLParams = [
            "where": "1=1",
            "outFields": "GEN,cases7_per_100k",
            "geometry": "\(longitude),\(latitude)",
            "geometryType": "esriGeometryPoint",
            "inSR": "4326",
            "spatialRel": "esriSpatialRelWithin",
            "returnGeometry": "false",
            "outSR": "4326",
            "f": "json",
        ]
        url = url.appendingQueryParameters(URLParams)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if (error == nil) {
                guard
                    let data = data
                else {
                    completion(.failure(.noData))
                    return
                }

                let resultDict: [String: Any]
                do {
                    guard let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                        completion(.failure(.invalidData))
                        return
                    }
                    resultDict = dict
                } catch {
                    completion(.failure(.jsonDecodingError(underlying: error)))
                    return
                }

                guard
                    let features = resultDict["features"] as? [[String: Any]],
                    let feature = features.first,
                    let attributes = feature["attributes"] as? [String: Any],
                    let value = attributes["cases7_per_100k"] as? Double,
                    let name = attributes["GEN"] as? String
                else {
                    completion(.failure(.invalidData))
                    return
                }

                completion(.success(LocalIncidence(name: name, incidence: value)))

            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription);
                completion(.failure(.connectionError(underlying: error)))
            }
        })
        task.resume()
    }

    let session = URLSession.shared
}

struct LocalIncidence {
    let name: String
    let incidence: Double
}


extension URL {
    /**
     Creates a new URL by adding the given query parameters.
     @param parametersDictionary The query parameter dictionary to add.
     @return A new URL.
     */
    func appendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
        let URLString : String = String(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        return URL(string: URLString)!
    }
}

protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {
    /**
     This computed property returns a query parameters string from the given NSDictionary. For
     example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
     string will be @"day=Tuesday&month=January".
     @return The computed parameters string.
     */
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                              String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                              String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }

}
