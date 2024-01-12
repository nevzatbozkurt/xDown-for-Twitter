//
//  HelpView.swift
//  xDown
//
//  Created by Nevzat BOZKURT on 12.01.2024.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var selectedTab: Int = 1
    var data: [HelpModel] = [
        HelpModel(id: 1, image: Image("help1"), title: "Step One", subTitle: "Open \"Twitter\" and find post."),
        
        HelpModel(id: 2, image: Image("help2"), title: "Step Two", subTitle: "Click the Share Button. (icon at the bottom right)"),
        
        HelpModel(id: 3, image: Image("help3"), title: "Step Three", subTitle: "Tap \"Share via...\" Button."),
        
        HelpModel(id: 4, image: Image("help4"), title: "Step Four", subTitle: "Tap \(Bundle.main.infoDictionary!["CFBundleName"] as! String) app."),
        
        HelpModel(id: 5, image: Image("help5"), title: "The Last Step", subTitle: "Tap the \"Download to Galary\" button.")
    ]
    
    var body: some View {
        VStack {
            Text("How to make a download?")
                .font(.title.bold())
                .padding(.vertical)
        
            TabView(selection: $selectedTab) {
                ForEach(data) { datum in
                    VStack(alignment: .leading) {
                        //MARK: Image
                        datum.image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(10)
                            .padding(.bottom, 12)
                        
                        //MARK: Text Title
                        Text(datum.title)
                            .font(.title2.bold())
                            .padding(.bottom, 4)
                            .foregroundColor(.primary)

                        //MARK: Text Subtitle
                        Text(datum.subTitle)
                            .bold()
                            .foregroundColor(.secondary)
                            .padding(.bottom)
                        
                        Spacer()
                        
                    }
                    .padding()
                }
            }
            .tabViewStyle(.page)
            
            Spacer()
            
            //MARK: Button Next Step
            Button {
                if (data.count == selectedTab) {
                    presentationMode.wrappedValue.dismiss()
                } else {
                    withAnimation {
                        selectedTab += 1
                    }
                }
            } label: {
                Text(data.count == selectedTab ? "Finish" : "Next Step")
                    .roundedStyle(backgroundColor: Color.secondary.opacity(0.3))
                    .padding(.horizontal)
            }
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
