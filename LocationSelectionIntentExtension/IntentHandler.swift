//
//  IntentHandler.swift
//  LocationSelectionIntentExtension
//
//  Created by Engin Kurutepe on 26.11.20.
//

import CoreLocation
import Contacts
import Intents
import MapKit

class IntentHandler: INExtension, LocationSelectionIntentHandling {
    let favorites: [CLPlacemark] = [
        CLPlacemark(location: CLLocation(latitude: 52.52, longitude: 13.40), name: "Berlin", postalAddress: nil),
        CLPlacemark(location: CLLocation(latitude: 48.13, longitude: 11.58), name: "Munich", postalAddress: nil),
        CLPlacemark(location: CLLocation(latitude: 53.55, longitude: 9.99), name: "Hamburg", postalAddress: nil),
    ]

    func resolvePlacemark(for intent: LocationSelectionIntent, with completion: @escaping (PlacemarkWrapperResolutionResult) -> Void) {
        completion(.success(with: PlacemarkWrapper(placemark: favorites.first!)))
    }

    func providePlacemarkOptionsCollection(for intent: LocationSelectionIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<PlacemarkWrapper>?, Error?) -> Void) {
        guard let query = searchTerm, query.isEmpty == false else {
            let placemarks = favorites.map(PlacemarkWrapper.init)
            let section = INObjectSection<PlacemarkWrapper>(
                title: "Favorites",
                items: placemarks)
            let collection = INObjectCollection(sections: [section])
            completion(collection, nil)
            return
        }

        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query

        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let mapItems = response?.mapItems else {
                completion(nil, nil)
                return
            }
            let placemarks = mapItems.map { PlacemarkWrapper(placemark: $0.placemark) }

            let section = INObjectSection<PlacemarkWrapper>(
                title: NSLocalizedString("widget-city-selection-search-results-header", value: "Search Results", comment: "section header shown when displaying search results"),
                items: placemarks)
            let collection = INObjectCollection(sections: [section])
            completion(collection, nil)
        }
    }

    
    override func handler(for intent: INIntent) -> Any {
        return self
    }

}

private extension PlacemarkWrapper {
    convenience init(placemark: CLPlacemark) {
        self.init(identifier: "\(placemark.hash)", display: placemark.name ?? "")
        self.placemark = placemark
    }
}
