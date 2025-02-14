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
            .padding(.horizontal, 120)
            .padding(.top, 40)
        
    }
    
    /// Styles the lists that contain shows/movies.
    func styleList() -> some View {
        self
            .shadow(radius: 3)
            .scrollContentBackground(.hidden)
            .frame(maxHeight: 450)
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
            .foregroundStyle(colorScheme == .dark ? Color.white : AppColors.mainColor)
    }
    
    /// Styles a button to be blue and have correct padding.
    func styleButton(buttonState: ButtonState, colorScheme: ColorScheme) -> some View {
        self
            .padding()
            .padding(.trailing, 30)
            .background(colorScheme == .dark ? Color.white : AppColors.mainColor)
            .cornerRadius(50)
            .scaleEffect(buttonState == .pressed ? 0.9 : 1)
            .opacity(buttonState == .pressed ? 0.95 : 1)
            .foregroundColor(colorScheme == .dark ? AppColors.mainColor : Color.white)
            .animation(.easeInOut(duration: 0.2), value: buttonState)
            .edgesIgnoringSafeArea(.all)
    }
    
    /// Styles the text fields when a user is searching for new media.
    func styleAddNewMediaTextField(
            isTextFieldFocused: FocusState<Bool>.Binding,
            isSearching: FocusState<Bool>.Binding,
            newShow: String,
            fetchData: ()
        ) -> some View {
        self
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .focused(isTextFieldFocused)
            .focused(isSearching)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.words)
            .onAppear {
                isTextFieldFocused.wrappedValue = true
                isSearching.wrappedValue = true
            }
            .onChange(of: newShow) {
                fetchData
            }
    }
}

#Preview {
    ContentView()
}
