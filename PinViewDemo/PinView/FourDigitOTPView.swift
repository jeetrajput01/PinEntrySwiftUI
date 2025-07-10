//
//  FourDigitOTPView.swift
//  PinView
//
//  Created by Shubham on 10/07/25.
//

import SwiftUI

public struct FourDigitOTPView: View {
    @State private var code: [String] = ["", "", "", ""]
    @State private var textFields: [BackspaceDetectingTextField?] = Array(repeating: nil, count: 4)
    @State private var activeIndex: Int? = nil
    
    public var body: some View {
        VStack(spacing: 0){
            
            Text("PinEntrySwiftUI")
                .font(.largeTitle.bold())
        
            Spacer()
            
            VStack(spacing: 25) {
                HStack(spacing: 10) {
                    ForEach(0..<4, id: \.self) { idx in
                        
                            SingleCharTextField(
                                index: idx,
                                onCreated: { tf in textFields[idx] = tf },
                                onAction: handleAction
                            )
                            
                        
                        .frame(width: 63, height: 92)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    Color.gray.opacity(0.5),
                                    lineWidth: 1.5
                                )
                        )
                        .overlay(content: {
                            RoundedRectangle(cornerRadius: 2).stroke(
                                activeIndex == idx ? Color.green : Color.gray.opacity(0.5)
                            )
                            .frame(width: 32, height: 1)
                            .offset(y: 28)
                            
                        })
                        .onReceive(NotificationCenter.default.publisher(
                            for: UITextField.textDidBeginEditingNotification,
                            object: textFields[idx]
                        )) { _ in activeIndex = idx }
                            .onReceive(NotificationCenter.default.publisher(
                                for: UITextField.textDidEndEditingNotification,
                                object: textFields[idx]
                            )) { _ in if activeIndex == idx { activeIndex = nil } }
                            .contentShape(Rectangle())
                            .ignoresSafeArea(.keyboard)
                    }
                }
                .padding()
                .ignoresSafeArea(.keyboard)
                
                Button{
                    
                    let newCode = code.joined()
                    
                    print(newCode.count)
                    print(newCode)
                    
                    code = ["", "", "", ""]
                    textFields.forEach { textField in
                        textField?.text = ""
                    }
                    
                } label: {
                    Text("Enter")
                        .foregroundStyle(code.joined().count == 4 ? .green : .red)
                }
                .disabled(code.joined().count == 4 ? false : true)
            }
                 
            Spacer()
            
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        
    }

    private func handleAction(_ idx: Int, _ action: SingleCharTextField.Action) {
            switch action {
            case .entered(let char):
                code[idx] = String(char)
                moveFocus(from: idx)
                
            case .deleted:
                code[idx] = ""
                textFields[idx]?.text = ""
                if idx > 0 {
                    textFields[idx-1]?.becomeFirstResponder()
                }
                
            case .committed:
                textFields[idx]?.resignFirstResponder()
                
            case .pasted(let str):
                let digits = str.filter { $0.isASCII }
                let chars = Array(digits.prefix(4))
                
                for i in 0..<4 {
                    if i < chars.count {
                        code[i] = String(chars[i])
                        textFields[i]?.text = String(chars[i])
                    } else {
                        code[i] = ""
                        textFields[i]?.text = ""
                    }
                }
                
                textFields.forEach { textField in
                    textField?.resignFirstResponder()
                }
            }
        }
    
    private func moveFocus(from idx: Int) {
            if idx < 3 {
                textFields[idx+1]?.becomeFirstResponder()
            } else {
                textFields[idx]?.resignFirstResponder()
                activeIndex = nil
            }
        }
}



// MARK: - Preview
struct FourDigitOTPView_Previews: PreviewProvider {
    static var previews: some View {
        FourDigitOTPView()
            .padding()
            
    }
}
