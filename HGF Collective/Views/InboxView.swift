//
//  InboxView.swift
//  HGF Collective
//
//  Created by William Dolke on 25/09/2022.
//

import SwiftUI

struct InboxView: View {
    @State var shouldShowLogOutOptions = false
    
    var body: some View {
        NavigationView {

            VStack {
                customNavBar
                messagesView
            }
            .navigationBarHidden(true)
        }
    }

    private var customNavBar: some View {
        HStack(spacing: 16) {

            Image(systemName: "person.fill")
                .font(.system(size: 34, weight: .heavy))
                .foregroundColor(Color.theme.accent)

            Text("Admin Account")
                .font(.system(size: 24, weight: .bold))

            Spacer()
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color.theme.accent)
            }
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Sign out?"), buttons: [
                .destructive(Text("Yes"), action: {
                    print("Handle sign out")
                }),
                    .cancel()
            ])
        }
    }

    private var messagesView: some View {
        ScrollView {
            ForEach(0..<10, id: \.self) { num in
                VStack {
                    HStack(spacing: 16) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .padding(8)
                            .overlay(RoundedRectangle(cornerRadius: 44)
                                        .stroke(Color(.label), lineWidth: 1)
                            )


                        VStack(alignment: .leading) {
                            Text("Username")
                                .font(.system(size: 20, weight: .bold))
                            Text("Message preview")
                                .font(.system(size: 16))
                                .foregroundColor(Color(.lightGray))
                        }
                        Spacer()

                        Text("Just now")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Divider()
                        .padding(.vertical, 8)
                }.padding(.horizontal)

            }.padding(.bottom, 50)
        }
    }
}

struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView()
        
        InboxView()
            .preferredColorScheme(.dark)
    }
}
