//
//  RoundedButton.swift
//  RoomPlan 2D
//
//  Created by Takashi Murata on 2024/05/22.
//

import SwiftUI

struct RoundedButton: View {
    // 各パラメータ
    var text: String
    var textColor: Color
    var backgroundColor: Color
    var fontWeight: Font.Weight
    var cornerRadius: CGFloat
    var width: CGFloat
    var height: CGFloat
    var action: () -> Void
    
    var body: some View {
        Button(action: { action() }, label: {
            ZStack(content: {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .frame(width: width, height: height)
                
                Text(text)
                    .foregroundColor(textColor)
                    .fontWeight(fontWeight)
            })
        })
    }
}
