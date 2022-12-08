//
//  Onboarding.swift
//  DateCounter
//
//  Created by Angélica Andrade de Meira on 06/12/22.
//

import SwiftUI

struct Onboarding: View {
    struct Feature {
        let title: String
        let featureDescription: String
        let icon: String
    }
    
    @State private var showContentView = false
    let welcomeFeatures = [
        Feature(title: "Track your events", featureDescription: "Find out how much time has passed for old events, or the time remaining to future events.", icon: "calendar"),
        Feature(title: "Home screen widgets", featureDescription: "Never miss an event thanks to home screen and lock screen widgets.", icon: "square.stack"),
        Feature(title: "Use everywhere", featureDescription: "Date Counter is a native app available on the App Store for Mac, iPad, iPhone and Apple Watch.", icon: "laptopcomputer.and.iphone"),
        Feature(title: "iCloud support", featureDescription: "Your events are automatically synchronized to all your devices.", icon: "cloud")
    ]
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Welcome to\nDate Counter")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)
                
                VStack(alignment: .leading) {
                    ForEach(welcomeFeatures, id: \.title) { feature in
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: feature.icon)
                                    .font(.title)
                                    .foregroundColor(.orange)
                                    .frame(width: 55)
                                
                                VStack(alignment: .leading){
                                    Text(feature.title)
                                    
                                    Text(feature.featureDescription)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding([.top, .trailing])
                    }
                }
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack {
                Button {
                    showContentView.toggle()
                } label: {
                    Spacer()
                    Text("Continuar")
                        .font(.title3)
                        .bold()
                        .frame(height: 38)
                    Spacer()
                }
                .buttonStyle(.borderedProminent)
                .cornerRadius(15)
                .padding()
                .background(.bar)
            }
        }
    }
}

struct Onboarding_Previews: PreviewProvider {
    static var previews: some View {
        Color(.black)
        .ignoresSafeArea()
            .sheet(isPresented: .constant(true)) {
                Onboarding()
            }
    }
}
