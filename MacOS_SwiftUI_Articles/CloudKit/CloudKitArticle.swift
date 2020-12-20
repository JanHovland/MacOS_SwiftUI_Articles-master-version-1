//
//  CloudKitArticle.swift
//  MacOS_SwiftUI_Articles
//
//  Created by Jan Hovland on 16/04/2020.
//  Copyright © 2020 Jan Hovland. All rights reserved.
//

import CloudKit
import SwiftUI

struct CloudKitArticle {
    struct RecordType {
        static let Article = "Article"
    }
    /// MARK: - errors
    enum CloudKitHelperError: Error {
        case recordFailure
        case recordIDFailure
        case castFailure
        case cursorFailure
    }
    
    /// MARK: - saving to CloudKit
    static func saveArticle(item: Article, completion: @escaping (Result<Article, Error>) -> ()) {
        let itemRecord = CKRecord(recordType: RecordType.Article)
        itemRecord["mainType"] = item.mainType as CKRecordValue
        itemRecord["subType"] = item.subType as CKRecordValue
        itemRecord["title"] = item.title as CKRecordValue
        itemRecord["introduction"] = item.introduction as CKRecordValue
        itemRecord["url"] = item.url as CKRecordValue
        
        CKContainer.default().privateCloudDatabase.save(itemRecord) { (record, err) in
            DispatchQueue.main.async {
                if let err = err {
                    completion(.failure(err))
                    return
                }
                guard let record = record else {
                    completion(.failure(CloudKitHelperError.recordFailure))
                    return
                }
                let recordID = record.recordID
                guard let mainType = record["mainType"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                guard let subType = record["subType"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                guard let title = record["title"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                guard let introduction = record["introduction"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                guard let url = record["url"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                let article = Article(recordID: recordID,
                                      mainType: mainType,
                                      subType: subType,
                                      title: title,
                                      introduction: introduction,
                                      url: url)

                completion(.success(article))
            }
        }
    }
    
    // MARK: - delete from CloudKit
    static func deleteArticle(recordID: CKRecord.ID, completion: @escaping (Result<CKRecord.ID, Error>) -> ()) {
        CKContainer.default().privateCloudDatabase.delete(withRecordID: recordID) { (recordID, err) in
            DispatchQueue.main.async {
                if let err = err {
                    completion(.failure(err))
                    return
                }
                guard let recordID = recordID else {
                    completion(.failure(CloudKitHelperError.recordIDFailure))
                    return
                }
                completion(.success(recordID))
            }
        }
    }
    
    // MARK: - check if the article record exists
    static func doesArticleExist(introduction: String,
                                 completion: @escaping (Bool) -> ()) {
        var result = false
        let predicate = NSPredicate(format: "introduction == %@", introduction)
        let query = CKQuery(recordType: RecordType.Article, predicate: predicate)
        DispatchQueue.main.async {
             /// inZoneWith: nil : Specify nil to search the default zone of the database.
             CKContainer.default().privateCloudDatabase.perform(query, inZoneWith: nil, completionHandler: { (results, er) in
                DispatchQueue.main.async {
                    if results != nil {
                        if results!.count >= 1 {
                            result = true
                        }
                    }
                    completion(result)
                }
            })
        }
    }

    // MARK: - fetching from CloudKit
    static func fetchArticle(predicate:  NSPredicate, completion: @escaping (Result<Article, Error>) -> ()) {
        let query = CKQuery(recordType: RecordType.Article, predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["mainType",
                                 "subType",
                                 "title",
                                 "introduction",
                                 "url"]
        operation.resultsLimit = 50
        operation.recordFetchedBlock = { record in
            DispatchQueue.main.async {
                let recordID = record.recordID
                guard let mainType  = record["mainType"] as? String else { return }
                guard let subType  = record["subType"] as? String else { return }
                guard let title1  = record["title"] as? String else { return }
                guard let introduction1 = record["introduction"] as? String else { return }
                guard let url = record["url"] as? String else { return }
                
                /// Fjerner eventuelle linjeskift med et balnkt tegn
                let title = title1.replacingOccurrences(of: "\n", with: "")
                let introduction = introduction1.replacingOccurrences(of: "\n", with: "")
 
                let article = Article(recordID: recordID,
                                      mainType: mainType,
                                      subType: subType,
                                      title: title,
                                      introduction: introduction,
                                      url: url)
                completion(.success(article))
            }
        }
        operation.queryCompletionBlock = { ( _, err) in
            DispatchQueue.main.async {
                if let err = err {
                    completion(.failure(err))
                    return
                }
            }
        }
        CKContainer.default().privateCloudDatabase.add(operation)
    }
}


