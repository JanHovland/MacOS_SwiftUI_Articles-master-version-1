//
//  SafariView.swift
//  MacOS_SwiftUI_Articles
//
//  Created by Jan Hovland on 16/04/2020.
//  Copyright © 2020 Jan Hovland. All rights reserved.
//

import SwiftUI
import WebKit
import CloudKit

struct SafariView : NSViewRepresentable {
    var url: String
    var recordID: CKRecord.ID?
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        selectedRecordId = recordID
    }
    
    func makeNSView(context: Context) -> WKWebView  {
        let view = WKWebView()
        if let url = URL(string: url) {
            view.load(URLRequest(url: url))
        }
        return view
    }
}
