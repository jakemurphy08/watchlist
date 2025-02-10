//
//  ViewModifiers.swift
//  Watchlist
//
//  Created by Jake Murphy on 2/4/25.
//

import SwiftUI

extension View {
    func styleSegmentedPicker() -> some View {
        self
            .pickerStyle(.segmented)
            .padding(.horizontal, 120)
            .padding(.top, 40)
        
    }
    
    func styleButton(isButtonPressed: Bool, colorScheme: ColorScheme) -> some View {
        self
            .padding()
            .padding(.trailing, 30)
            .background(colorScheme == .dark ? Color.white : AppColors.mainColor)
            .cornerRadius(50)
            .scaleEffect(isButtonPressed ? 0.9 : 1)
            .opacity(isButtonPressed ? 0.95 : 1)
            .foregroundColor(colorScheme == .dark ? AppColors.mainColor : Color.white)
            .animation(.easeInOut(duration: 0.2), value: isButtonPressed)
    }
    
    func styleTextField(
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
