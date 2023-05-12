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
                    Color.purple.opacity(0.1)
                }
                .frame(width: 64, height: 64)
                .cornerRadius(50)
                
                VStack {
                    Text(viewModel.firstName)
                    Text(viewModel.lastName)
                }
            }
            
            Spacer()
            
            VStack {
                MemoriesWidgetView(url: nil)
                    .frame(width: 292, height: 311)
                    .background(.blue)
                    .cornerRadius(12)
                
                Text("Your widget preview").font(.subheadline)
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
            
        }
        .frame(maxWidth: .infinity)
        .padding(32.0)
        
    }
}


struct MemoriesHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MemoriesHomeView()
    }
}
