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
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), size: context.displaySize)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, size: context.displaySize)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration, size: context.displaySize)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let size: CGSize
}

struct CoronaWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image("swift-alps-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                Text("Swift Alps")
                Spacer()
            }
            .padding()
            .font(.headline)
            .foregroundColor(.white)
            .background(Color.red)

            Text("Hello Widgets!")
            Text(entry.date, style: .time)
            Spacer()
        }
        .background(RadialGradient(gradient: Gradient(colors: [Color.white, Color.gray]), center: .center, startRadius: 0.2*entry.size.width, endRadius: 0.8*entry.size.width))
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
        .description("This is an example widget.")
    }
}

struct CoronaWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CoronaWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), size: CGSize(width: 180, height: 180)))
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            CoronaWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), size: CGSize(width: 360, height: 180)))
                .previewContext(WidgetPreviewContext(family: .systemMedium))

            CoronaWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), size: CGSize(width: 360, height: 360)))
                .previewContext(WidgetPreviewContext(family: .systemLarge))

        }
    }
}
