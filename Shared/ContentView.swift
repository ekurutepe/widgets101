//
//  ContentView.swift
//  Shared
//
//  Created by Engin Kurutepe on 22.11.20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 5) {
                Text("Hello, Swift Alps!")
                Text("Let's start with a demo of the relevant parts of SwiftUI")
                Text("This is a Text block")
                Text("You can add padding")
                    .padding([.top, .bottom], 20)
                Text("or change text attributes with modifiers")
                    .foregroundColor(.blue)
                    .font(.headline)
                    .background(Color.gray)
                    .padding()
                Text("pay attention to the order of modifiers")
                    .foregroundColor(.blue)
                    .font(.headline)
                    .padding()
                    .background(Color.gray)
                Text("there is an Image below")
                Image("swift-alps-logo")
                    .padding()

                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "figure.wave")
                        .foregroundColor(.red)
                    Text("use HStack for horizontal layout")
                }

                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .bottom, spacing: 10) {
                        VStack(spacing: 5) {
                            Image(systemName: "aspectratio")
                                .font(.title)
                            Text("Layout")
                                .font(.caption)
                        }
                        .background(Color.red)
                        VStack(spacing: 5) {
                            Image(systemName: "snow")
                            Text("Snowflake")
                                .font(.caption)
                        }
                        .background(Color.blue)
                    }
                    .padding()
                    .background(Color.yellow)
                    Text("You can nest them too…")
                        .foregroundColor(.purple)
                }
                .foregroundColor(.green)
                .padding()
                .background(Color.secondary)
            }
            .foregroundColor(.black)
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
