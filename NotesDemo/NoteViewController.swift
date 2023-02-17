//
//  NoteViewController.swift
//  NotesDemo
//
//  Created by Марк Пушкарь on 16.02.2023.
//

import UIKit

class NoteViewController: UIViewController {
    
    //MARK: properties
    
    var note: Note?
    
    private let textAppearenceControll = TextAppearenceControll()
    
    private var image: UIImage?
    
    private let coreDataStack: CoreDataStack
    
    //MARK: buttons and views
    
    private let boldButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.setImage(UIImage(systemName: "bold"), for: .normal)
        return button
    }()
    
    private let italicButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.setImage(UIImage(systemName: "italic"), for: .normal)
        return button
    }()
    
    private let underlineButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.setImage(UIImage(systemName: "underline"), for: .normal)
        return button
    }()
    
    private let colorButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.setImage(UIImage(systemName: "paintbrush"), for: .normal)
        return button
    }()
    private let attachmentButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.setImage(UIImage(named: "photo"), for: .normal)
        return button
    }()
    
    private let removeButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.toAutoLayout()
        button.setImage(UIImage(systemName: "trash"), for: .normal)
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
    
    //MARK: UIMethods
    
    @objc private func saveButtonPressed() {
        print("save button pressed")
        let imageData = image?.pngData()
        if note == nil {
            coreDataStack.createNewNote(content: contentTextView.text, title: titleTextView.text, image: imageData)
        } else {
            guard let note = note else { return }
            coreDataStack.undateExistingObject(note: note, content: contentTextView.text, title: titleTextView.text, image: imageData)
        }
        navigationController?.popToRootViewController(animated: true)
        
    }
    
    @objc private func tapDone(sender: Any) {
           self.view.endEditing(true)
    }
    
    @objc private func handleTapOnAttachment() {
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
        
        guard let imageData = note.image else { return }
        image = UIImage(data: imageData)
        guard let image = image else { return }
        appendImage(image: image)
    }
    
    private func appendImage(image: UIImage) {
        var attributedString :NSMutableAttributedString!
        attributedString = NSMutableAttributedString(attributedString: contentTextView.attributedText)
        let textAttachment = NSTextAttachment()
        textAttachment.image = image
        let oldWidth = textAttachment.image!.size.width;
        let scaleFactor = oldWidth / (contentTextView.frame.size.width - 10);
        textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        attributedString.append(attrStringWithImage)
        contentTextView.attributedText = attributedString
        attachmentButton.isHidden = true
        removeButton.isHidden = false
    }
    
    @objc private func removeImage() {
        image = nil
        contentTextView.text = note?.desc
        attachmentButton.isHidden = false
        removeButton.isHidden = true
        
    }
    
    //MARK: life cycle
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
        DispatchQueue.main.async {
            self.setupTextViews()
        }
    }
    
    //MARK: editing text methods
    
    @objc private func boldText() {
        textAppearenceControll.btnTapp()
    }
    
    @objc private func italicText() {
        textAppearenceControll.italicTapp()
    }
    
    @objc private func undelinedText() {
        textAppearenceControll.underlineTapp()
    }
    
    @objc private func coloredText() {
        textAppearenceControll.colourTapp()
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
        removeButton.addTarget(self, action: #selector(removeImage), for: .touchUpInside)
        
        
        textAppearenceControll.textView = contentTextView
        boldButton.addTarget(self, action: #selector(boldText), for: .touchUpInside)
        italicButton.addTarget(self, action: #selector(italicText), for: .touchUpInside)
        underlineButton.addTarget(self, action: #selector(undelinedText), for: .touchUpInside)
        colorButton.addTarget(self, action: #selector(coloredText), for: .touchUpInside)

        
        view.backgroundColor = .lightGray
        view.addSubviews(titleTextView, contentTextView, attachmentButton, removeButton, boldButton, italicButton, underlineButton, colorButton)
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
            attachmentButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            removeButton.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 10),
            removeButton.trailingAnchor.constraint(equalTo: attachmentButton.leadingAnchor, constant: -15),
            
            boldButton.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 10),
            boldButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            
            italicButton.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 10),
            italicButton.leadingAnchor.constraint(equalTo: boldButton.trailingAnchor, constant: 15),
            
            underlineButton.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 10),
            underlineButton.leadingAnchor.constraint(equalTo: italicButton.trailingAnchor, constant: 15),
            
            colorButton.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 10),
            colorButton.leadingAnchor.constraint(equalTo: underlineButton.trailingAnchor, constant: 15),


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
        appendImage(image: image)
        dismiss(animated: true)
    }
    
    
}
