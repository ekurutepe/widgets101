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
        ComplexEntry(date: Date(), configuration: LocationSelectionIntent(), size: context.displaySize, germanyCount: 1234, incidences: [
                        LocalIncidence(name: "Berlin", incidence: 250),
                        LocalIncidence(name: "Hamburg", incidence: 123),
                        LocalIncidence(name: "Stuttgart", incidence: 234),
        ] )
    }

    func getSnapshot(for configuration: LocationSelectionIntent, in context: Context, completion: @escaping (ComplexEntry) -> ()) {
        let entry = ComplexEntry(date: Date(), configuration: configuration, size: context.displaySize, germanyCount: 1234, incidences: [
            LocalIncidence(name: "Berlin", incidence: 250),
            LocalIncidence(name: "Hamburg", incidence: 123),
        ] )
        completion(entry)
    }

    func getTimeline(for configuration: LocationSelectionIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()

        var germanyCount = 0
        var incidences: [Int: LocalIncidence] = [:]

        let group = DispatchGroup()
        group.enter()
        RKICoronaService.shared.fetchGermany { (result) in
            defer { group.leave() }
            switch (result) {
            case .success(let count):
                germanyCount = count
            case .failure(let error):
                print(error)
                let updateDate = Calendar.current.date(byAdding: .minute, value: 10, to: currentDate)!
                completion(Timeline(entries: [], policy: .after(updateDate)))
            }
        }

        let locations = [configuration.placemark1, configuration.placemark2,configuration.placemark3]
            .compactMap { $0?.placemark?.location }

        for (idx,loc) in locations.enumerated() {
            group.enter()
            RKICoronaService.shared.fetchCoordinate(
                latitude: loc.coordinate.latitude,
                longitude: loc.coordinate.longitude) { (result) in
                defer { group.leave() }
                switch result {
                case .success(let incidence):
                    incidences[idx] = incidence
                case .failure(let error):
                    print(error)
                }
            }
        }

        let _ = group.wait(timeout: .now() + .seconds(5))

        let sortedIncidences = incidences.sorted { (lhs, rhs) -> Bool in
            lhs.key < rhs.key
        }.map(\.value)

        let updateDate = Calendar.current.date(byAdding: .hour, value: 6, to: currentDate)!

        let entry = ComplexEntry(
            date: currentDate,
            configuration: configuration,
            size: context.displaySize,
            germanyCount: germanyCount,
            incidences: sortedIncidences)

        let timeline = Timeline(entries: [entry], policy: .after(updateDate))

        completion(timeline)
    }
}

struct ComplexEntry: TimelineEntry {
    let date: Date
    let configuration: LocationSelectionIntent
    let size: CGSize
    let germanyCount: Int
    let incidences: [LocalIncidence]
}

struct ComplexWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: MultiLocationProvider.Entry

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(minimum: 100, maximum: 200), spacing: 5, alignment: .center),
                            GridItem(.flexible(minimum: 100, maximum: 200), spacing: 5, alignment: .center)]) {
            GermanyCountBox(count: entry.germanyCount)
            ForEach(entry.incidences, id: \.name) {
                IncidenceBox(name: $0.name, incidence: $0.incidence)
            }
        }
        .padding()
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
        ComplexWidgetEntryView(
            entry: ComplexEntry(
                date: Date(),
                configuration: LocationSelectionIntent(),
                size: CGSize(width: 360, height: 360),
                germanyCount: 1234,
                incidences: [
                    LocalIncidence(name: "Berlin", incidence: 250),
                    LocalIncidence(name: "Hamburg", incidence: 120),
                    LocalIncidence(name: "Stuttgart", incidence: 234)
                ]))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

