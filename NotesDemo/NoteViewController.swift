//
//  NoteViewController.swift
//  NotesDemo
//
//  Created by Марк Пушкарь on 16.02.2023.
//

import UIKit

class NoteViewController: UIViewController {
    
    var note: Note?
    
    private var image: UIImage?
    
    private let coreDataStack: CoreDataStack
    
    private let attachmentButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.setImage(UIImage(named: "photo"), for: .normal)
        return button
    }()
    
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
        if note == nil {
            coreDataStack.createNewNote(content: contentTextView.text, title: titleTextView.text)
        } else {
            guard let note = note else { return }
            coreDataStack.undateExistingObject(note: note, content: contentTextView.text, title: titleTextView.text)
        }
        navigationController?.popToRootViewController(animated: true)
        
    }
    
    @objc private func tapDone(sender: Any) {
           self.view.endEditing(true)
    }
    
    @objc func handleTapOnAttachment() {
        let cameraImage = UIImage(named: "camera")
        let photoLibImage = UIImage(named: "photo")
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default) { _ in
            self.chooseImagePicker(source: .camera)
        }
        camera.setValue(cameraImage, forKey: "image")
        camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        let photo = UIAlertAction(title: "Photo", style: .default) { _ in
            self.chooseImagePicker(source: .photoLibrary)
        }
        photo.setValue(photoLibImage, forKey: "image")
        photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheet.addAction(camera)
        actionSheet.addAction(photo)
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true)
    }
    
    private func setupTextViews() {
        guard let note = note else { return }
        titleTextView.text = note.title
        contentTextView.text = note.desc
        contentTextView.textColor = .label
        titleTextView.textColor = .label
        
        // problems may occure 
        guard let imageData = note.image else { return }
        image = UIImage(data: imageData)
        guard let image = image else { return }
        workingWithImage(image: image)
    }
    
    private func workingWithImage(image: UIImage) {
        var attributedString :NSMutableAttributedString!
        attributedString = NSMutableAttributedString(attributedString: contentTextView.attributedText)
        let textAttachment = NSTextAttachment()
        textAttachment.image = image
        let oldWidth = textAttachment.image!.size.width;
        let scaleFactor = oldWidth / (contentTextView.frame.size.width - 10);
        textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        attributedString.append(attrStringWithImage)
        contentTextView.attributedText = attributedString;
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
        setupTextViews()
    }
    
    
}

    

//MARK: EXTENSIONS

private extension NoteViewController {
    func setupViews() {
        titleTextView.delegate = self
        contentTextView.delegate = self
        titleTextView.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
        contentTextView.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
        attachmentButton.addTarget(self, action: #selector(handleTapOnAttachment), for: .touchUpInside)
        view.backgroundColor = .lightGray
        view.addSubviews(titleTextView, contentTextView, attachmentButton)
        let constraints = [
            
            titleTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            titleTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            titleTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 110),
            
            contentTextView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 25),
            contentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            contentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            contentTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            
            attachmentButton.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 10),
            attachmentButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)


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
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Nothing typed"
            textView.textColor = UIColor.lightGray
        }
    }
    
    
}

//MARK: EXTENSION WORKING WITH IMAGES

extension NoteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image = info[.editedImage] as? UIImage
        guard let image = image else {
            dismiss(animated: true)
            return
        }
        workingWithImage(image: image)
        dismiss(animated: true)
    }
    
    
}
