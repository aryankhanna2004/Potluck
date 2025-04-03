//
//  LoadingVIew.swift
//  Potluck
//
//  Created by ET Loaner on 4/3/25.
//

import SwiftUI

struct LoadingView: View {
  var body: some View {
    VStack {
      ProgressView()
        .progressViewStyle(CircularProgressViewStyle())
        .scaleEffect(1.5)
      Text("Checking Authentication...")
        .padding(.top, 10)
    }
  }
}

