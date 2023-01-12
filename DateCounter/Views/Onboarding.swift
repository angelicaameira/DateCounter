//
//  Onboarding.swift
//  DateCounter
//
//  Created by Angélica Andrade de Meira on 06/12/22.
//

import SwiftUI

struct Feature: Identifiable {
  let id = UUID()
  let title: LocalizedStringKey
  let featureDescription: LocalizedStringKey
  let icon: String
}

private let welcomeFeatures = [
  Feature(title: "Track your events", featureDescription: "Find out how much time has passed for old events, or the time remaining until future events.", icon: "calendar"),
  Feature(title: "Home screen widgets", featureDescription: "Never miss an event thanks to home screen and lock screen widgets.", icon: "square.stack"),
  Feature(title: "Use everywhere", featureDescription: "Date Counter is a native app available on the App Store for Mac, iPad, iPhone and Apple Watch.", icon: "laptopcomputer.and.iphone"),
  Feature(title: "iCloud support", featureDescription: "Your events are automatically synchronized to all your devices.", icon: "cloud")
]

struct Onboarding: View {
  @Environment(\.dismiss) var dismiss
  
  var greetingTitle: some View {
    Text("Welcome to\nDate Counter", comment: "Short greeting text before briefing users on how to use the app if they have not created events yet. Below it are instructions on what to do next")
      .font(.largeTitle)
      .fontWeight(.bold)
      .multilineTextAlignment(.center)
#if os(iOS)
      .padding(.top, 40)
#else
      .padding(.top)
#endif
  }
  
  var body: some View {
    ScrollView {
      VStack {
#if !os(watchOS)
        Text("Welcome to\nDate Counter", comment: "Short greeting text before briefing users on how to use the app if they have not created events yet. Below it are instructions on what to do next. Shown on all platforms except for watchOS")
          .font(.largeTitle)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)
#if os(iOS)
          .padding(.top, 40)
#else
          .padding(.top)
#endif
#endif
        VStack(alignment: .leading) {
          ForEach(welcomeFeatures) { feature in
            FeatureRow(feature: feature)
          }
#if os(watchOS)
          continueButton
#endif
        }
      }
      .navigationTitle("Welcome")
      .padding()
    }
#if os(iOS)
    .safeAreaInset(edge: .bottom, spacing: 0) {
      continueButton
    }
#endif
#if os(OSX)
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        continueButton
      }
    }
#endif
  }
  
#if os(OSX)
  var continueButton: some View {
    Button {
      dismiss()
    } label: {
      Spacer()
      Text("Continue", comment: "A button that dismisses the onboarding view. Shown only on macOS")
        .bold()
        .frame(height: 38)
      Spacer()
    }
    .buttonStyle(.borderedProminent)
    .padding()
    .background(.bar)
  }
#endif
  
#if os(iOS)
  var continueButton: some View {
    Button {
      dismiss()
    } label: {
      Spacer()
      Text("Continue", comment: "A button that dismisses the onboarding view. Shown only on iOS")
        .font(.title3)
        .bold()
        .frame(height: 38)
      Spacer()
    }
    .buttonStyle(.borderedProminent)
    .padding()
    .background(.bar)
  }
#endif
  
#if os(watchOS)
  var continueButton: some View {
    Button {
      dismiss()
    } label: {
      Text("Continue", comment: "A button that dismisses the onboarding view. Shown only on watchOS")
        .bold()
    }
    .buttonStyle(.borderedProminent)
    .padding(.top)
  }
#endif
}

struct FeatureRow: View {
  let feature: Feature
  
#if os(watchOS)
  var body: some View {
    VStack(alignment: .leading) {
      VStack(alignment: .leading) {
        HStack {
          Image(systemName: feature.icon)
            .foregroundColor(.orange)
            .font(.headline)
            .frame(width: 25)
          Text(feature.title, comment: "title or name of event")
            .font(.headline)
        }
        Text(feature.featureDescription, comment: "more informations about de event")
          .foregroundColor(.secondary)
      }
    }
    .padding([.top, .trailing])
  }
#else
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Image(systemName: feature.icon)
          .foregroundColor(.orange)
#if os(watchOS)
          .frame(width: 20)
#else
          .font(.title)
          .frame(width: 55)
#endif
        
        VStack(alignment: .leading) {
          Text(feature.title, comment: "title or name of event")
          
          Text(feature.featureDescription, comment: "more information about de event")
            .foregroundColor(.secondary)
        }
      }
    }
    .padding([.top, .trailing])
  }
#endif
}

struct Onboarding_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .ignoresSafeArea()
      .sheet(isPresented: .constant(true)) {
        Onboarding()
      }
  }
}
