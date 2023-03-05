//
//  Items.swift
//  Todoey
//
//  Created by Matthew Cheung on 27/2/2023.
//  Copyright © 2023 Matthew Cheng. All rights reserved.
//

import Foundation
import RealmSwift

class Items: Object{
  @Persisted var title: String = ""
  @Persisted var done: Bool = false
  @Persisted var dateCreated : Date?
  @Persisted (originProperty: "items") var parentCategory: LinkingObjects<Category>
  
}
