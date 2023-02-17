//
//  TableViewCell.swift
//  NotesDemo
//
//  Created by Марк Пушкарь on 16.02.2023.
//


import UIKit

class TableViewCell: UITableViewCell {
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.numberOfLines = 0 
        label.toAutoLayout()
        return label
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Date"
        label.numberOfLines = 0
        label.toAutoLayout()
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubviews(titleLabel, dateLabel)
        let constraints = [
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -70),
            
            dateLabel.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -50),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
            dateLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5)

        ]
        NSLayoutConstraint.activate(constraints)
    }
}


