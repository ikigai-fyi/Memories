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
            Text(viewModel.firstName)
            Text(viewModel.lastName)
            AsyncImage(url: URL(string: viewModel.pictureUrl)) { image in
                image
            } placeholder: {
                Color.purple.opacity(0.1)
            }
            .frame(width: 100, height: 100)
            .cornerRadius(20)
            
            Button {
                viewModel.launchOauthFlow()
            } label: {
                Text("Login with Strava")
                    .padding()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .onOpenURL { url in
            Task {
                await viewModel.handleOauthRedirect(url: url)
            }
        }
    }
}


struct StravaLoginView_Previews: PreviewProvider {
    static var previews: some View {
        StravaLoginView()
    }
}
