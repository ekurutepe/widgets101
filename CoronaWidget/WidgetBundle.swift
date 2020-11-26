//
//  WidgetBundle.swift
//  CoronaWidgetExtension
//
//  Created by Engin Kurutepe on 26.11.20.
//

import SwiftUI
import WidgetKit

@main
struct CoronaWidgets: WidgetBundle {
  @WidgetBundleBuilder
  var body: some Widget {
    CoronaWidget()
    ComplexWidget()
  }
}
