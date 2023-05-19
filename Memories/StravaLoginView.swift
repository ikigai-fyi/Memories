//
//  ContentView.swift
//  Memories
//
//  Created by Paul Nicolet on 05/05/2023.
//

import SwiftUI

struct StravaLoginView: View {
    @EnvironmentObject var viewModel: StravaLoginViewModel
    
    var body: some View {
        VStack {
            Spacer()
                .frame(minHeight: 10, idealHeight: 100, maxHeight: 600)
                .fixedSize()
            
            Image("ikigaiIcon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 164, height: 164)
            .cornerRadius(41)
            
            Text("Memories")
                .font(.title).bold()
            Text("Widgets for Strava")
                .font(.headline)
            
          
            Spacer()
            
            Button {
                amplitude.track(eventType: AnalyticsEvents.connectStrava)
                viewModel.launchOauthFlow()
            } label: {
                Text("Connect with Strava")
                    .bold()
                    .padding()
            }
            .frame(maxWidth: .infinity)
            .background(Color(Constants.MainColor))
            .foregroundColor(.white)
            .cornerRadius(35)

        }
        .frame(maxWidth: .infinity)
        .padding(32.0)
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
