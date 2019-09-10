//
//  Category.swift
//  ToDoey With Realm
//
//  Created by indianrenters on 07/09/19.
//  Copyright © 2019 indianrenters. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    let item = List<Items>()
}
