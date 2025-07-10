//
//  BackspaceDetectingTextField.swift
//  PinView
//
//  Created by Jeet on 10/07/25.
//


import SwiftUI

public class BackspaceDetectingTextField: UITextField {
    var onBackspace: (() -> Void)?

    public override func deleteBackward() {
        onBackspace?()
        super.deleteBackward()
    }
}

public struct SingleCharTextField: UIViewRepresentable {
    public enum Action {
        case entered(Character)
        case deleted
        case committed
        case pasted(String)
    }
    
    private let index: Int
    private let onCreated: (BackspaceDetectingTextField) -> Void
    private let onAction: (Int, Action) -> Void

    public init(
        index: Int,
        onCreated: @escaping (BackspaceDetectingTextField) -> Void,
        onAction: @escaping (Int, Action) -> Void
    ) {
        self.index = index
        self.onCreated = onCreated
        self.onAction = onAction
    }

    public func makeUIView(context: Context) -> BackspaceDetectingTextField {
        let textField = BackspaceDetectingTextField()
        textField.delegate = context.coordinator
        textField.autocorrectionType = .no
        textField.returnKeyType = .default
        textField.autocapitalizationType = .none
        textField.keyboardType = .asciiCapable
        textField.textAlignment = .center
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: textField,
            action: #selector(textField.resignFirstResponder)
        )
        toolbar.tintColor = .link
        toolbar.items = [UIBarButtonItem.flexibleSpace(), done]
        textField.inputAccessoryView = toolbar
        
        textField.onBackspace = { context.coordinator.handleBackspace() }
        DispatchQueue.main.async { onCreated(textField) }
        return textField
    }

    public func updateUIView(_ uiView: BackspaceDetectingTextField, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(index: index, onAction: onAction)
    }

    public class Coordinator: NSObject, UITextFieldDelegate {
        private let index: Int
        private let onAction: (Int, Action) -> Void
        private let allowedSet = CharacterSet.alphanumerics

        init(index: Int, onAction: @escaping (Int, Action) -> Void) {
            self.index = index
            self.onAction = onAction
        }

        public func textField(_ textField: UITextField,
                              shouldChangeCharactersIn range: NSRange,
                              replacementString string: String) -> Bool {
            guard !string.isEmpty else { return true }
            
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.rangeOfCharacter(from: allowedSet.inverted) != nil {
                return false
            }
            
            if trimmed.count > 1 {
                onAction(index, .pasted(trimmed))
                return false
            }
            
            textField.text = ""
            if let char = trimmed.first {
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else {return}
                    strongSelf.onAction(strongSelf.index, .entered(char))
                }
            }
            return true
        }

        func handleBackspace() {
            onAction(index, .deleted)
        }

        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            onAction(index, .committed)
            textField.resignFirstResponder()
            return true
        }
    }
}
