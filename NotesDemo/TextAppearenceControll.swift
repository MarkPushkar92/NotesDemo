//
//  mock.swift
//  NotesDemo
//
//  Created by Марк Пушкарь on 17.02.2023.
//

import UIKit
 
class TextAppearenceControll {
 
    var textView: UITextView!
    
    func btnTapp() {
        if let text = textView {
            let range = text.selectedRange
            let string = NSMutableAttributedString(attributedString: textView.attributedText)
            let boldAttribute = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)
            ]
            string.addAttributes(boldAttribute, range: textView.selectedRange)
            textView.attributedText = string
            textView.selectedRange = range
        }
    }
    
    func italicTapp() {
        if let text = textView {
            let range = text.selectedRange
            let string = NSMutableAttributedString(attributedString: textView.attributedText)
            let italicAttribute = [
                NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 18.0)
            ]
            string.addAttributes(italicAttribute, range: textView.selectedRange)
            textView.attributedText = string
            textView.selectedRange = range
        }
    
    }
    
    func underlineTapp() {
        if let text = textView {
            let range = text.selectedRange
            let string = NSMutableAttributedString(attributedString: textView.attributedText)
            let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
            string.addAttributes(underlineAttribute, range: textView.selectedRange)
            textView.attributedText = string
            textView.selectedRange = range
        }
           
    }
    
    func colourTapp() {
   
        if let text = textView {
            let range = text.selectedRange
            let string = NSMutableAttributedString(attributedString: textView.attributedText)
            let colorAttribute = [NSAttributedString.Key.foregroundColor: UIColor.red]
            string.addAttributes(colorAttribute, range: textView.selectedRange)
            textView.attributedText = string
            textView.selectedRange = range
        }
    }
    

}
 
