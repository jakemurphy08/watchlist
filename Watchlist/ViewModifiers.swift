//
//  ViewModifiers.swift
//  Watchlist
//
//  Created by Jake Murphy on 2/4/25.
//

import SwiftUI

extension View {
    
    /// Styles a picker to be segmented.
    func styleSegmentedPicker() -> some View {
        self
            .pickerStyle(.segmented)
            .padding(.top, 40)
            .padding(.bottom, 10)
            .frame(width: 200)
        
    }
    
    /// Styles the lists that contain shows/movies.
    func styleList() -> some View {
        self
//            .shadow(radius: 3)
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .frame(maxHeight: 600)
    }
    
    /// Styles the header of a list. For instance, the `SHOWS` and `EDIT` buttons above each list.
    func styleListHeaderText(_ colorScheme: ColorScheme, position: Edge.Set) -> some View {
        self
            .changeAppearance(colorScheme: colorScheme)
            .padding(position, 25)
            .fontWeight(.light)
            .font(.system(size: 13))
    }
    
    /// Changes the appearance of it's caller depending on dark/light mode.
    func changeAppearance(colorScheme: ColorScheme) -> some View {
        self
            .foregroundStyle(colorScheme == .dark ? AppColors.mainColorInverted : AppColors.mainColor)
    }
    
    /// Styles a button to be blue and have correct padding.
    func styleButton(buttonState: ButtonState, colorScheme: ColorScheme) -> some View {
        self
            .padding()
            .padding(.horizontal, 10)
            .background(colorScheme == .dark ? AppColors.mainColorInverted : AppColors.mainColor)
            .cornerRadius(buttonState == .pressed ? 50 : 20)
            .scaleEffect(buttonState == .pressed ? 0.9 : 1)
            .opacity(buttonState == .pressed ? 0.95 : 1)
            .foregroundColor(colorScheme == .dark ? AppColors.mainColor : AppColors.mainColorInverted)
            .animation(.easeInOut(duration: 0.2), value: buttonState)
            .edgesIgnoringSafeArea(.all)
    }
    
    /// Styles the text fields when a user is searching for new media.
    func styleAddNewMediaTextField(
            isSearching: FocusState<Bool>.Binding,
            newMedia: String,
            fetchData: ()
        ) -> some View {
        self
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .focused(isSearching)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.words)
            .onAppear {
                isSearching.wrappedValue = true
            }
            .onChange(of: newMedia) {
                fetchData
            }
    }
}

#Preview {
    ContentView()
}
