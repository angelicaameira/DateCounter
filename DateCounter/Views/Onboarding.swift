//
//  Onboarding.swift
//  DateCounter
//
//  Created by Angélica Andrade de Meira on 06/12/22.
//

import SwiftUI

struct Onboarding: View {
    @State private var showContenteView = false
    
    var body: some View {
        NavigationView {
            List{
                
                //.navigationTitle("Welcome!")
                
                Text("""
             Stack Exchange has automatic filters in place to ban answers from accounts that have posted numerous low-quality answers in the past. These filters help keep the quality of our sites high.
             
             Users who are banned from answering see the following error message when trying to post a new answer:
            """)
                .padding()
                
                Button {
                    showContenteView.toggle()
                } label: {
                    Label("Continue", systemImage: "plus")
                }
                .sheet(isPresented: $showContenteView) {
                    ContentView()
                }
            }
        }
    }
}

struct Onboarding_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding()
    }
}
