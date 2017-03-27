//
//  VisitorCount.swift
//  RetirePro
//
//  Created by David Luong on 3/20/17.
//  Copyright © David Luong. All rights reserved.
//

import Foundation
import RealmSwift

class VisitorCount: Object {
    dynamic var date: Date = Date()
    dynamic var count: Int = Int(0)
    
    func save() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func delete() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
}
