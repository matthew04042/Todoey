//
//  Category.swift
//  Todoey
//
//  Created by Matthew Cheung on 27/2/2023.
//  Copyright © 2023 Matthew Cheng. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object{
    @Persisted var name: String = ""
    @Persisted var items = List<Items>()
    @Persisted var cellColor: String
}
