//
//  ContentView.swift
//  MacOS_SwiftUI_Articles
//
//  Created by Jan Hovland on 16/04/2020.
//  Copyright © 2020 Jan Hovland. All rights reserved.
//

import SwiftUI
import CloudKit

var selectedRecordId: CKRecord.ID?

struct MacOS_SwiftUI_Articles: View {
    
    /// Dersom du legger inn nye AppIcon, reset Xcode, kjør CleanMyMacX og kompiler på nytt
    
    @State private var articles =
        [Article(title: "Getting Started With Combine",
                 introduction: "Maybe you’re not yet ready to jump into SwiftUI but you can still get started with Combine. Here’s a gentle introduction to using Combine to validate user input.",
                 url: "https://useyourloaf.com/blog/getting-started-with-combine/?utm_campaign=AppCoda%20Weekly&utm_medium=email&utm_source=Revue%20newsletter"),
         Article(title: "SwiftUI ButtonStyle",
                 introduction: "SwiftUI makes it very easy to customize a button style. Learn how to create a reusable button style in SwiftUI.",
                 url:"https://sarunw.com/posts/swiftui-buttonstyle/?utm_campaign=AppCoda%20Weekly&utm_medium=email&utm_source=Revue%20newsletter")
    ]
    
    private var showNewWindow = NSLocalizedString("AddArticle", comment: "MacOS_SwiftUI_Articles")
    private var cannotShowNewWindow = NSLocalizedString("Cannot show AddArticle", comment: "MacOS_SwiftUI_Articles")
    
    /// Vise flere vinduer
    class DetailWindowController<RootView: View>: NSWindowController {
        convenience init(rootView: RootView) {
            let hostingController = NSHostingController(rootView:
                rootView.frame(width: 700, height: 450))
            let window = NSWindow(contentViewController: hostingController)
            window.setContentSize(NSSize(width: 700, height: 450))
            self.init(window: window)
        }
    }
    
    @State private var alertIdentifier: AlertID?
    @State private var message: String = ""
    @State private var message1: String = ""
    @State private var vindowCounter = 0
    @State private var indexSetDelete = IndexSet()
    @State private var dialogResult = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(vindowCounter == 0 ? showNewWindow : cannotShowNewWindow) {
//                        if self.vindowCounter == 0 {
//                            self.vindowCounter += 1
                            let controller = DetailWindowController(rootView: AddArticleView())
                            controller.window?.title = self.showNewWindow
                            controller.showWindow(nil)
//                        }
                    }
                    .controlSize(ControlSize.small)
                        /// Dette virker ikke :
                        ///     . background(Color(red: 30, green: 105, blue: 219))
                        ///  OK:
                        /// .background(Color.blue)
                        .padding(.top, 5)
                        .padding(.leading, 5)
                    
                    Button(action: {
                        self.Refresh(showAlert: true)
                    }, label: {
                        HStack {
                            Text("Refresh")
                        }
                    })
                        .controlSize(ControlSize.small)
                        .padding(.top, 5)
                        .padding(.leading, 5)
                    
                    Spacer()
                    
                }
                List (articles) { article in
                    NavigationLink(destination: SafariView(url: article.url, recordID: article.recordID)) {
                        MasterView(article: article)
                    }
                    
                }
                    
                .onDeleteCommand {
                    /// Sjekk om denne artikkelen virkelig skal slettes
                    self.CheckDeleteArticle(recordID: selectedRecordId!)
                }
                
            }
        }
        .listStyle(SidebarListStyle())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            /// Henter alle artiklene
            self.Refresh(showAlert: false)
        }
        .alert(item: $alertIdentifier) { alert in
            switch alert.id {
            case .first:
                return Alert(title: Text(self.message), message: Text(self.message1), dismissButton: .cancel())
            case .second:
                return Alert(title: Text(self.message), message: Text(self.message1), dismissButton: .cancel())
            case .delete:
                return Alert(title: Text(self.message), message: Text(self.message1), primaryButton: .cancel(),
                             secondaryButton: .default(Text("OK"), action: {self.DeleteAction()}))
            }
        }
    }
    
    /// Rutine for å friske opp bildet
    /// Sender bare alert når showAlert er true
    func Refresh(showAlert: Bool) {
        /// Sletter alt tidligere innhold i person
        articles.removeAll()
        /// Fetch all tutorials from CloudKit
        let predicate = NSPredicate(value: true)
        CloudKitArticle.fetchArticle(predicate: predicate)  { (result) in
            switch result {
            case .success(let tutorial):
                self.articles.append(tutorial)
                self.articles.sort(by: {$0.title.uppercased() < $1.title.uppercased()})
//                self.articles.sort(by: {$0.mainType.uppercased() < $1.mainType.uppercased()})
//                self.articles.sort(by: {$0.subType.uppercased() < $1.subType.uppercased()})
                self.message = NSLocalizedString("Fetched all Article data", comment: "MacOS_SwiftUI_Articles")
                self.message1 = NSLocalizedString("Now all the data is extracted from the Article table on CloudKit", comment: "MacOS_SwiftUI_Articles")
                if showAlert == true {
                    self.alertIdentifier = AlertID(id: .first)
                }
            case .failure(let err):
                self.message = err.localizedDescription
                self.alertIdentifier = AlertID(id: .first)
            }
        }
    }

    /// Spør om denne artikkelen virkelig skal slettes
    func CheckDeleteArticle(recordID: CKRecord.ID?) {
        self.message = NSLocalizedString("Delete this article?", comment: "MacOS_SwiftUI_Articles")
        self.message1 = NSLocalizedString("Do you really want to delete this article?", comment: "MacOS_SwiftUI_Articles")
        self.alertIdentifier = AlertID(id: .delete)
    }

    /// Her slettes artikkelen i CloudKit og så kalles: self.Refresh
    func DeleteAction() {
        print("Article is deleted")
        /// Slette artikkelen i CloudKit
        CloudKitArticle.deleteArticle(recordID: selectedRecordId!) { (result) in
           switch result {
           case .success :
               self.message = NSLocalizedString("Successfully deleted the article", comment: "MacOS_SwiftUI_Articles")
               self.alertIdentifier = AlertID(id: .first)
           case .failure(let err):
               self.message = err.localizedDescription
               self.alertIdentifier = AlertID(id: .first)
           }
       }
    }
}

struct MasterView: View {
    var article: Article
    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
//            Text(article.mainType + " - " + article.subType)
//                .font(.system(size: 15, weight: .light, design: .rounded))
            Text(article.title)
                .font(.system(size: 13, weight: .light, design: .rounded))
            Text(article.introduction)
                .font(.system(size: 13, weight: .ultraLight))
                .padding(.leading, 15)
                /// .frame gjør at en lang tekst spittes opp i flere linjer uten at enmå legge inn \n
                .frame(width: 400)
        }
        .padding(.top, 5)
    }
}






