//
//  Article.swift
//  MacOS_SwiftUI_Articles
//
//  Created by Jan Hovland on 16/04/2020.
//  Copyright © 2020 Jan Hovland. All rights reserved.
//

import SwiftUI
import CloudKit

struct Article: Identifiable {
    var id = UUID()
    var recordID: CKRecord.ID?
    var mainType: String = ""
    var subType: String = ""
    var title: String = ""
    var introduction: String = ""
    var url: String = ""
}
