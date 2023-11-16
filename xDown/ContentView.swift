//
//  ContentView.swift
//  xDown
//
//  Created by Nevzat BOZKURT on 16.11.2023.
//

import SwiftUI

struct ContentView: View {
    
    @State var urlText = ""
    
    var body: some View {
        
        VStack(alignment: .leading) {
            //MARK: TOP BUTTONS
            VStack(alignment: .leading) {
                LabeledIconButton(text: "Help", icon: "envelope")
                LabeledIconButton(text: "Remove ADS", icon: "star")
                LabeledIconButton(text: "How to make a use", icon: "arrow.down.circle")
            }
            
            Spacer()
            
            //MARK: ADMOB BANNER
            
            
            Spacer()
            
            //MARK: URL INPUT
            TextField("Twitter Video URL & Photo or GIF URL", text: $urlText)
                .roundedStyle(backgroundColor: .black.opacity(0.1))
                .padding(.top, 20)
            
            
            //MARK: FIND BUTTON
            Button {
                
            } label: {
                Text("Find")
                    .roundedStyle(backgroundColor: Color.black.opacity(0.88))
            }

          
            
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct LabeledIconButton: View {
    var text: String
    var icon: String
    
    var body: some View {
        Label {
            Text(text)
                .bold()
                .offset(x: -15)
            
        } icon: {
            Image(systemName: icon)
                .padding()
                .background(.secondary.opacity(0.2))
                .clipShape(Circle())
                .padding([.horizontal])
                .foregroundColor(.black)
        }.font(.title2)
    }
}
