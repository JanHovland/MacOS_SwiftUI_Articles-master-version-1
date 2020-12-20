//
//  AlertID.swift
//  MacOS_SwiftUI_Articles
//
//  Created by Jan Hovland on 16/04/2020.
//  Copyright © 2020 Jan Hovland. All rights reserved.
//

import SwiftUI

struct AlertID: Identifiable {
    enum Choice {
        case first, second, delete
    }

    var id: Choice
}

