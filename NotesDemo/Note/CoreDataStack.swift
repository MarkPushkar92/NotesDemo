//
//  CoreDataStack.swift
//  NotesDemo
//
//  Created by Марк Пушкарь on 16.02.2023.
//

import Foundation
import CoreData

class CoreDataStack {
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
            The persistent container for the application. This implementation
            creates and returns a container, having loaded the store for the
            application to it. This property is optional since there are legitimate
            error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "NotesDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    func fetchTasks() -> [Note] {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        do {
            return try viewContext.fetch(request)
        } catch {
            fatalError("🤷‍♂️ Что-то пошло не так..")
        }
    }
    
    func remove(note: Note) {
        viewContext.delete(note)
        save(context: viewContext)
    }
    
    func createNewNote(content: String, title: String, image: Data?) {
        let context = persistentContainer.viewContext
        let newNote = Note(context: context)
        newNote.desc = content
        newNote.title = title
        newNote.id = UUID()
        newNote.date = Date()
        newNote.image = image
        save(context: context)
    }
    
    func undateExistingObject(note: Note, content: String, title: String, image: Data?) {
        remove(note: note)
        createNewNote(content: content, title: title, image: image)
    }
    
    private func save(context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
}

class Policy: NSMergePolicy {
    override init(merge ty: NSMergePolicyType) {
        super.init(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    }
}
