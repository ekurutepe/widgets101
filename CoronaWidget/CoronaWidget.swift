//
//  CoronaWidget.swift
//  CoronaWidget
//
//  Created by Engin Kurutepe on 22.11.20.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), size: context.displaySize, germanyCount: 1234, regionName: "Steglitz", incidence: 234)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, size: context.displaySize, germanyCount: 1234, regionName: "Steglitz", incidence: 234)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()



        RKICoronaService.shared.fetchGermany { (result) in
            if case .success(let count) = result {
                let maybeLocation: CLLocation?
                if let location = configuration.placemark?.location {
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
                            let entry = SimpleEntry(
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
                            let entry = SimpleEntry(
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
                    let entry = SimpleEntry(
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

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let size: CGSize
    let germanyCount: Int
    let regionName: String
    let incidence: Double
}

struct TopBar: View {
    var body: some View {
        HStack {
            Image("swift-alps-logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            Text("Swift Alps")
            Spacer()
        }
        .padding()
        .font(.callout)
        .foregroundColor(.white)
        .background(Color.red)
    }
}

struct CoronaWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry

    var body: some View {
        switch widgetFamily {
        case .systemMedium:
            return AnyView(MediumWidget(entry: entry))
        default:
            return AnyView(SmallWidget(entry: entry))
        }
    }
}

@main
struct CoronaWidget: Widget {
    let kind: String = "CoronaWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            CoronaWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .supportedFamilies([.systemSmall, .systemMedium])
        .description("This is an example widget.")
    }
}

struct CoronaWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CoronaWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), size: CGSize(width: 180, height: 180), germanyCount: 1234, regionName: "Steglitz", incidence: 234))
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            CoronaWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), size: CGSize(width: 360, height: 180), germanyCount: 1234, regionName: "Steglitz", incidence: 234))
                .previewContext(WidgetPreviewContext(family: .systemMedium))

//            CoronaWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), size: CGSize(width: 360, height: 360), germanyCount: 1234, regionName: "Steglitz", incidence: 234))
//                .previewContext(WidgetPreviewContext(family: .systemLarge))

        }
    }
}
