//
//  ContentView.swift
//  Memories
//
//  Created by Paul Nicolet on 05/05/2023.
//

import SwiftUI


struct StravaLoginView: View {
    
    @StateObject var viewModel = StravaLoginViewModel()
    
    var body: some View {
        VStack {
            Button {
                viewModel.signIn()
            } label: {
                Text("Login with Strava")
                    .padding()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .onOpenURL { url in
            viewModel.handleSignedIn(url: url)
        }
    }
}


struct StravaLoginView_Previews: PreviewProvider {
    static var previews: some View {
        StravaLoginView()
    }
}
