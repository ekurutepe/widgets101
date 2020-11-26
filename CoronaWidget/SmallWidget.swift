//
//  SmallWidget.swift
//  Widgets101 (iOS)
//
//  Created by Engin Kurutepe on 26.11.20.
//

import SwiftUI
import WidgetKit

struct SmallWidget: View {
    var entry: SimpleEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            VStack(alignment: .leading, spacing: 5) {
                Text("🦠 Germany: ")
                HStack{
                    Spacer()
                    Text("\(entry.germanyCount)")
                }
            }
            .font(.callout)
            VStack(alignment: .leading, spacing: 5) {
                Text("🦠 \(entry.regionName)")
                HStack{
                    Spacer()
                    Text("\(entry.incidence, specifier: "%.1f")")
                }
            }
            .font(.callout)
            .foregroundColor(incidenceTextColor)
            Spacer()

            Text(entry.date, style: .date)
                .font(.footnote)
        }
        .padding()
        .background(RadialGradient(gradient: Gradient(colors: [Color.white, Color.gray]), center: .center, startRadius: 0.2*entry.size.width, endRadius: 0.8*entry.size.width))
    }

    var incidenceTextColor: Color {
        switch entry.incidence {
        case 0..<50:
            return .green
        case 50..<100:
            return .yellow
        case 100..<200:
            return .orange
        case 200..<300:
            return .red
        default:
            return .black
        }
    }
}

struct SmallWidget_Previews: PreviewProvider {
    static var previews: some View {
        SmallWidget(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), size: CGSize(width: 360, height: 180), germanyCount: 1234, regionName: "Steglitz", incidence: 234))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
