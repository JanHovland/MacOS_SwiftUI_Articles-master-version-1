//
//  AddArticleView.swift
//  MacOS_SwiftUI_Articles
//
//  Created by Jan Hovland on 17/04/2020.
//  Copyright © 2020 Jan Hovland. All rights reserved.
//

import SwiftUI

struct AddArticleView: View {
    
    @State private var mainType = 0
    @State private var subType = 0
    @State private var title = ""
    @State private var introduction = ""
    @State private var url = ""
    @State private var alertIdentifier: AlertID?
    @State private var message: String = ""
    @State private var message1: String = ""
    @State private var selectedAnimalIndex: Int = 0
    
    private var mainTypes = [
        "MacOS",
        "SwiftUI"
    ]
    
    private var subTypes = [
        "Button",
        "Text",
        "TextField"
    ]
    
    var body: some View {
        Form {
            VStack {
                HStack (alignment: .center) {
                    Text("Enter a new article")
                        .font(.system(size: 35, weight: .ultraLight, design: .rounded))
                        .padding(.top, 50)
                        .padding(.bottom, 30)
                }
                
                InputMainType(heading:  NSLocalizedString("MainType     ", comment: "AddArticleView"), mainTypes:   mainTypes,            spaceing: 10, value: $mainType)
                InputSubType(heading:   NSLocalizedString("SubType      ", comment: "AddArticleView"), subTypes:    subTypes,             spaceing: 10, value: $subType)
                InputTextField(heading: NSLocalizedString("Title        ", comment: "AddArticleView"), placeHolder: "Enter Title",        spaceing: 37, value: self.$title)
                InputTextField(heading: NSLocalizedString("Introduction ", comment: "AddArticleView"), placeHolder: "Enter Introduction", spaceing: 17, value: self.$introduction)
                InputTextField(heading: NSLocalizedString("Url          ", comment: "AddArticleView"), placeHolder: "Enter Url",          spaceing: 42, value: self.$url)
                
                Spacer()
                
                Button(action: {
                    self.saveArticle(mainType: self.mainType,
                                     subType: self.subType,
                                     title: self.title,
                                     introduction: self.introduction,
                                     url: self.url)
                }, label: {
                    HStack {
                        Text("Save article")
                    }
                })
                    .controlSize(ControlSize.small)
            }
        }
        .alert(item: $alertIdentifier) { alert in
            switch alert.id {
            case .first:
                return Alert(title: Text(self.message), message: Text(self.message1), dismissButton: .cancel())
            case .second:
                return Alert(title: Text(self.message), message: Text(self.message1), dismissButton: .cancel())
            case .delete:
                return Alert(title: Text(self.message), message: Text(self.message1), primaryButton: .cancel(),
                             secondaryButton: .default(Text("OK"), action: {}))
            }
        }
    }
    
    func saveArticle(mainType: Int,
                     subType: Int,
                     title: String,
                     introduction: String,
                     url: String) {
        
        if  self.title.count > 0,
            self.introduction.count > 0,
            self.url.count > 0  {
            
            /// Sjekker om denne posten finnes fra før
            CloudKitArticle.doesArticleExist(introduction: self.introduction) { (result) in
                if result == true {
                    self.message = NSLocalizedString("Existing data", comment: "AddArticleView")
                    self.message1 = NSLocalizedString("This article was stored earlier", comment: "AddArticleView")
                    self.alertIdentifier = AlertID(id: .first)
                } else {
                    let mainType = self.mainTypes[mainType]
                    let subType = self.subTypes[subType]
                    let article = Article(mainType: mainType,
                                          subType: subType,
                                          title: self.title,
                                          introduction: self.introduction,
                                          url: self.url)
                    CloudKitArticle.saveArticle(item: article) { (result) in
                        switch result {
                        case .success:
                            self.message = NSLocalizedString("Article saved", comment: "AddArticleView")
                            self.message1 = NSLocalizedString("This article is now stored in CloudKit", comment: "AddArticleView")
                            self.alertIdentifier = AlertID(id: .first)
                        case .failure(let err):
                            self.message = err.localizedDescription
                            self.alertIdentifier = AlertID(id: .first)
                        }
                    }
                }
            }
        } else {
            self.message = NSLocalizedString("Missing data", comment: "AddArticleView")
            self.message1 = NSLocalizedString("Check that all fields have a value", comment: "AddArticleView")
            self.alertIdentifier = AlertID(id: .first)
        }
    }
}

struct InputTextField: View {
    var heading: String
    var placeHolder: String
    var spaceing: Int
    @Binding var value: String
    var body: some View {
        HStack(alignment: .center, spacing: CGFloat(spaceing)) {
            Text(heading)
            /// .font(... virker ikke.
            /// .font(.custom("Menlo Normal", size: 15))
            TextField(placeHolder, text: $value)
        }
        .padding(10)
    }
}

struct InputMainType: View {
    var heading: String
    var mainTypes: [String]
    var spaceing: Int
    @Binding var value: Int
    
    var body: some View {
        HStack(alignment: .center, spacing: CGFloat(spaceing)) {
            Text(heading)
            /// .font(... virker ikke.
            /// .font(.custom("Menlo Normal", size: 15))
            Picker(selection: $value, label: Text("")) {
                ForEach(0..<mainTypes.count) { index in
                    Text(self.mainTypes[index]).tag(index)
                }
            }
        }
        .padding(10)
    }
}

struct InputSubType: View {
    var heading: String
    var subTypes: [String]
    var spaceing: Int
    @Binding var value: Int
    
    var body: some View {
        HStack(alignment: .center, spacing: CGFloat(spaceing)) {
            Text(heading)
            /// .font(... virker ikke.
            /// .font(.custom("Menlo Normal", size: 15))
            Picker(selection: $value, label: Text("")) {
                ForEach(0..<subTypes.count) { index in
                    Text(self.subTypes[index]).tag(index)
                }
            }
        }
        .padding(10)
    }
}


