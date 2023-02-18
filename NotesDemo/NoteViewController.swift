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
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let containerView = UIView()
    
    private let regularButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.setImage(UIImage(systemName: "character"), for: .normal)
        return button
    }()
    
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
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.textColor = UIColor.lightGray
        textView.toAutoLayout()
        textView.layer.cornerRadius = 10
        return textView
    }()
    
    //MARK: UIMethods
    
    @objc private func saveButtonPressed() {
        print("save button pressed")
        if note == nil {
            coreDataStack.createNewNote(content: contentTextView.attributedText, title: titleTextView.text)
        } else {
            guard let note = note else { return }
            coreDataStack.undateExistingObject(note: note, content: contentTextView.attributedText, title: titleTextView.text)
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
        contentTextView.attributedText = note.desc
        contentTextView.textColor = .label
        titleTextView.textColor = .label
        
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
        contentTextView.attributedText = note?.desc
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc fileprivate func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.contentInset.bottom = keyboardSize.height
            scrollView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }
    
    @objc fileprivate func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = .zero
        scrollView.verticalScrollIndicatorInsets = .zero
    }
    
    override func viewDidLayoutSubviews() {
        let constraints = [
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleTextView.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            titleTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            titleTextView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: 110),
            
            contentTextView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 25),
            contentTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 35),
            contentTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            contentTextView.heightAnchor.constraint(equalToConstant: 300),
            contentTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -60),
            
            attachmentButton.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 10),
            attachmentButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            
            removeButton.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 10),
            removeButton.trailingAnchor.constraint(equalTo: attachmentButton.leadingAnchor, constant: -15),
            
            boldButton.topAnchor.constraint(equalTo: contentTextView.topAnchor, constant: 70),
            boldButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
            
            italicButton.topAnchor.constraint(equalTo: boldButton.bottomAnchor, constant: 10),
            italicButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
            
            underlineButton.topAnchor.constraint(equalTo: italicButton.bottomAnchor, constant: 10),
            underlineButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
            
            colorButton.topAnchor.constraint(equalTo: underlineButton.bottomAnchor, constant: 10),
            colorButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
            
            regularButton.topAnchor.constraint(equalTo: colorButton.bottomAnchor, constant: 10),
            regularButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
        ]
        NSLayoutConstraint.activate(constraints)
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
    
    @objc private func regularText() {
        textAppearenceControll.regular()
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
        regularButton.addTarget(self, action: #selector(regularText), for: .touchUpInside)

        
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = .lightGray
        containerView.addSubviews(titleTextView, contentTextView, attachmentButton, removeButton, boldButton, italicButton, underlineButton, colorButton, regularButton)
        
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

