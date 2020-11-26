//
//  ComplexWidget.swift
//  CoronaWidgetExtension
//
//  Created by Engin Kurutepe on 26.11.20.
//

import WidgetKit
import SwiftUI
import Intents

struct MultiLocationProvider: IntentTimelineProvider {

    func placeholder(in context: Context) -> ComplexEntry {
        ComplexEntry(date: Date(), configuration: LocationSelectionIntent(), size: context.displaySize, germanyCount: 1234, regionName: "Steglitz", incidence: 234)
    }

    func getSnapshot(for configuration: LocationSelectionIntent, in context: Context, completion: @escaping (ComplexEntry) -> ()) {
        let entry = ComplexEntry(date: Date(), configuration: configuration, size: context.displaySize, germanyCount: 1234, regionName: "Steglitz", incidence: 234)
        completion(entry)
    }

    func getTimeline(for configuration: LocationSelectionIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()

        RKICoronaService.shared.fetchGermany { (result) in
            if case .success(let count) = result {
                let maybeLocation: CLLocation?
                if let location = configuration.placemark?.placemark?.location {
                    maybeLocation = location
                } else {
                    maybeLocation = nil
                }

                if let location = maybeLocation {
                    RKICoronaService.shared.fetchCoordinate(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude) { (result) in
                        switch result {
                        case .success(let incidence):
                            let entry = ComplexEntry(
                                date: currentDate,
                                configuration: configuration,
                                size: context.displaySize,
                                germanyCount: count,
                                regionName: incidence.name,
                                incidence: incidence.incidence)

                            let updateDate = Calendar.current.date(byAdding: .hour, value: 6, to: currentDate)!
                            let timeline = Timeline(entries: [entry], policy: .after(updateDate))
                            completion(timeline)
                        case .failure:
                            let entry = ComplexEntry(
                                date: currentDate,
                                configuration: configuration,
                                size: context.displaySize,
                                germanyCount: count,
                                regionName: "error",
                                incidence: 0)

                            let updateDate = Calendar.current.date(byAdding: .hour, value: 6, to: currentDate)!
                            let timeline = Timeline(entries: [entry], policy: .after(updateDate))
                            completion(timeline)

                        }
                    }

                } else {
                    let entry = ComplexEntry(
                        date: currentDate,
                        configuration: configuration,
                        size: context.displaySize,
                        germanyCount: count,
                        regionName: "no location",
                        incidence: 0)

                    let updateDate = Calendar.current.date(byAdding: .hour, value: 6, to: currentDate)!
                    let timeline = Timeline(entries: [entry], policy: .after(updateDate))
                    completion(timeline)

                }

            }
            else {
                let updateDate = Calendar.current.date(byAdding: .minute, value: 10, to: currentDate)!
                completion(Timeline(entries: [], policy: .after(updateDate)))
            }
        }
    }
}

struct ComplexEntry: TimelineEntry {
    let date: Date
    let configuration: LocationSelectionIntent
    let size: CGSize
    let germanyCount: Int
    let regionName: String
    let incidence: Double
}

struct ComplexWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: MultiLocationProvider.Entry

    var body: some View {
        Text("hello")
    }
}

struct ComplexWidget: Widget {
    let kind: String = "ComplexWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: LocationSelectionIntent.self, provider: MultiLocationProvider()) { entry in
            ComplexWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Complex Widget")
        .supportedFamilies([.systemLarge])
        .description("This is a widget with multiple locations and pre-filled locations")
    }
}

struct ComplexWidget_Previews: PreviewProvider {
    static var previews: some View {
        ComplexWidgetEntryView(entry: ComplexEntry(date: Date(), configuration: LocationSelectionIntent(), size: CGSize(width: 360, height: 360), germanyCount: 1234, regionName: "Steglitz", incidence: 234))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

