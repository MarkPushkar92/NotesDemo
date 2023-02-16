//
//  ViewController.swift
//  NotesDemo
//
//  Created by Марк Пушкарь on 16.02.2023.
//

import UIKit

class ViewController: UIViewController {
    
    let coreDataStack: CoreDataStack
    
    static var noteList = [Note]()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .white
        tableView.toAutoLayout()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: cellID)
        return tableView
    }()
    
    private let cellID = "cellID"
    
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
        ViewController.noteList = coreDataStack.fetchTasks()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ViewController.noteList = coreDataStack.fetchTasks()
        tableView.reloadData()
    }
    
    @objc private func addButtonPressed() {
        let vc = NoteViewController(stack: coreDataStack)
        navigationController?.pushViewController(vc, animated: true)
    }
  
}

//MARK: EXTENSIONS

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ViewController.noteList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! TableViewCell
        cell.titleLabel.text = ViewController.noteList[indexPath.row].title
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ViewController.noteList.remove(at: indexPath.row)
            let note = coreDataStack.fetchTasks()[indexPath.row]
            self.coreDataStack.remove(note: note)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

private extension ViewController {
    func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        let constraints = [
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        let addBarButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addButtonPressed))
        navigationItem.rightBarButtonItem = addBarButton
        
    }
}

