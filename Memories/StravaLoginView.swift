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
            Spacer()
                .frame(minHeight: 10, idealHeight: 100, maxHeight: 600)
                .fixedSize()
            
            Image("ikigaiIcon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 164, height: 164)
            .cornerRadius(82)
            
            Text("Memories")
                .font(.title).bold()
            Text("Widgets for Strava")
                .font(.headline)
            
          
            Spacer()
            
            Button {
                viewModel.launchOauthFlow()
            } label: {
                Text("Connect with Strava")
                    .bold()
                    .padding()
            }
            .frame(maxWidth: .infinity)
            .background(Color(UIColor(red: 0.99, green: 0.30, blue: 0.01, alpha: 1.00)))
            .foregroundColor(.white)
            .cornerRadius(35)
            
            Text(viewModel.firstName)


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
