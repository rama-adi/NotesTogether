//
//  GetHeightModifier.swift
//  NotesTogether
//
//  Created by Rama Adi Nugraha on 23/05/24.
//

import Foundation
import SwiftUI

struct GetHeightModifier: ViewModifier {
    @Binding var height: CGFloat

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geo -> Color in
                DispatchQueue.main.async {
                    height = geo.size.height
                }
                return Color.clear
            }
        )
    }
}
