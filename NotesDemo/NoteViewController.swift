//
//  NoteViewController.swift
//  NotesDemo
//
//  Created by Марк Пушкарь on 16.02.2023.
//

import UIKit

class NoteViewController: UIViewController {
    
    let coreDataStack: CoreDataStack

    private let titleTextView: UITextView = {
        let textView = UITextView()
        textView.text = "Type the title"
        textView.textColor = UIColor.lightGray
        textView.toAutoLayout()
        textView.layer.cornerRadius = 10
        return textView
    }()
    
    private let contentTextView: UITextView = {
        let textView = UITextView()
        textView.text = "Type the text of your note"
        textView.textColor = UIColor.lightGray
        textView.toAutoLayout()
        textView.layer.cornerRadius = 10
        return textView
    }()
    
    @objc private func saveButtonPressed() {
        print("save button pressed")
        coreDataStack.createNewNote(content: contentTextView.text, title: titleTextView.text)
        navigationController?.popToRootViewController(animated: true)
        
    }
    
    @objc private func tapDone(sender: Any) {
           self.view.endEditing(true)
       }
    
    init(stack: CoreDataStack) {
        self.coreDataStack = stack
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
}

//MARK: EXTENSIONS

private extension NoteViewController {
    func setupViews() {
        titleTextView.delegate = self
        contentTextView.delegate = self
        titleTextView.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
        contentTextView.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))

        view.backgroundColor = .lightGray
        view.addSubviews(titleTextView, contentTextView)
        let constraints = [
            
            titleTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            titleTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            titleTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 110),
            
            contentTextView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 25),
            contentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            contentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            contentTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),


        ]
        NSLayoutConstraint.activate(constraints)
        
        let saveButton  = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonPressed))
        
        navigationItem.rightBarButtonItem = saveButton
        
    }
}

extension NoteViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Nothing typed"
            textView.textColor = UIColor.lightGray
        }
    }
    
    
}


