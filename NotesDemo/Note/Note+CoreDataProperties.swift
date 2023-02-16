//
//  Note+CoreDataProperties.swift
//  NotesDemo
//
//  Created by Марк Пушкарь on 16.02.2023.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var title: String?
    @NSManaged public var desc: String?

}

extension Note : Identifiable {

}
