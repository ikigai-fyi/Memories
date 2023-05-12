//
//  MemoriesHomeView.swift
//  Memories
//
//  Created by Vincent Ballet on 12/05/2023.
//

import SwiftUI
import WebKit

struct MemoriesHomeView: View {
    
    @StateObject var viewModel = StravaLoginViewModel()
    @State private var isShowingWebView: Bool = false
    
    
    var body: some View {
        ScrollView{
            VStack {
                
                // top spacer
                Spacer()
                    .frame(minHeight: 10, idealHeight: 40, maxHeight: 80)
                    .fixedSize()
                
                // body
                HStack {
                    AsyncImage(url: URL(string: viewModel.pictureUrl)) { image in
                        image
                    } placeholder: {
                        Color.gray.opacity(0.1)
                    }
                    .frame(width: 64, height: 64)
                    .cornerRadius(50)
                    
                    VStack(alignment: .leading) {
                        Text(viewModel.firstName)
                        Text(viewModel.lastName)
                    }
                }
                
                Spacer()
                
                if let activity = viewModel.activity {
                    VStack {
                        Text(activity.getName()).font(.callout)
                        MemoriesWidgetView(url: URL(string: activity.getPictureUrls().first!))
                            .frame(width: 292, height: 311)
                            .background(.gray.opacity(0.1))
                            .cornerRadius(12)
                        
                        Text("Your widget preview").font(.subheadline)
                    }
                } else {
                    ProgressView()
                }
                
                
                Spacer()
                
                Button {
                    isShowingWebView = true
                } label: {
                    Label {
                        Text("Add widget")
                            .bold()
                    } icon: {
                        Image(systemName: "plus.circle.fill")
                    }.padding()
                }
                .frame(maxWidth: .infinity)
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(35)
                .sheet(isPresented: $isShowingWebView) {
                    WebView(url: URL(string: "https://support.apple.com/en-us/HT207122")!)
                }
                
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
                
            }
            .frame(maxWidth: .infinity)
            .padding(32.0)
            .onAppear {
                Task {
                    await viewModel.fetchRandomActivity()
                }
            }
        }.refreshable {
            await viewModel.fetchRandomActivity()
        }
        
    }
}


struct MemoriesHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MemoriesHomeView()
    }
}
