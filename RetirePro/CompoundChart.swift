//
//  CompoundChart.swift
//  RetirePro
//
//  Created by David Luong on 3/21/17.
//  Copyright © 2017 David Luong. All rights reserved.
//

import Foundation
import RealmSwift

class CompoundChart: Object {
    dynamic var year: Int = Int(0)
    dynamic var money: Int = Int(0)
    
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
