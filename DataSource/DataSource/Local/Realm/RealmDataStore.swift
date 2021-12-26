//
//  RealmDataStore.swift
//  DataSource
//
//  Created by Yuki Okudera on 2021/11/28.
//

import RealmSwift

protocol RealmDataStoreProviding {

    var realm: Realm { get }

    /// 新規主キー発行
    func newId(for type: RealmSwift.Object.Type) -> Int?

    /// レコード追加
    func add(object: RealmSwift.Object) throws

    /// レコード追加
    func add(objects: [RealmSwift.Object]) throws

    /// レコード更新
    /// RealmSwift.ObjectにprimaryKey()が実装されている場合のみ有効
    func update(object: RealmSwift.Object, block:(() -> Void)?) throws

    /// レコード全削除
    func deleteAll(for type: RealmSwift.Object.Type) throws

    /// レコード削除
    func delete(object: RealmSwift.Object) throws

    /// レコード削除
    func delete(objects: [RealmSwift.Object]) throws

    /// 全件取得
    func findAll(for type: RealmSwift.Object.Type) -> Results<RealmSwift.Object>

    /// 指定キーのレコードを取得
    func findById(id: Any, for type: RealmSwift.Object.Type) -> RealmSwift.Object?

    /// 指定キーのレコードを取得
    func findByIds(ids: [Any], type: RealmSwift.Object.Type) -> Results<RealmSwift.Object>?
}

final class RealmDataStore: RealmDataStoreProviding, ExceptionCatchable {

    @Injected(\.realmConfiguratorProvider)
    private var realmConfigurator: RealmConfiguratorProviding

    var realm: Realm {
        do {
            return try Realm(configuration: realmConfigurator.configuration)
        } catch {
            assertionFailure("Realm initialize failed.")
            return try! Realm()
        }
    }

    // MARK: - Create a new primary key

    /// 新規主キー発行
    func newId(for type: RealmSwift.Object.Type) -> Int? {
        guard let primaryKey = type.primaryKey() else {
            log("primaryKey未設定")
            return nil
        }
        if let maxValue = realm.objects(type).max(ofProperty: primaryKey) as Int? {
            return maxValue + 1
        } else {
            return 1
        }
    }

    // MARK: - Add record

    /// レコード追加
    func add(object: RealmSwift.Object) throws {
        let executionError = executionBlock(realm: realm) { [weak self] in
            self?.realm.add(object)
        }

        // エラーがある場合throw
        if let executionError = executionError {
            throw executionError
        }
    }

    /// レコード追加
    func add(objects: [RealmSwift.Object]) throws {
        let executionError = executionBlock(realm: realm) { [weak self] in
            self?.realm.add(objects)
        }

        // エラーがある場合throw
        if let executionError = executionError {
            throw executionError
        }
    }

    // MARK: - Update record

    /// レコード更新
    /// RealmSwift.ObjectにprimaryKey()が実装されている場合のみ有効
    func update(object: RealmSwift.Object, block:(() -> Void)? = nil) throws {
        let executionError = executionBlock(realm: realm) { [weak self] in
            block?()
            self?.realm.add(object, update: .modified)
        }

        // エラーがある場合throw
        if let executionError = executionError {
            throw executionError
        }
    }

    // MARK: - Delete records

    /// レコード全削除
    func deleteAll(for type: RealmSwift.Object.Type) throws {
        let objs = realm.objects(type)

        let executionError = executionBlock(realm: realm) { [weak self] in
            self?.realm.delete(objs)
        }

        // エラーがある場合throw
        if let executionError = executionError {
            throw executionError
        }
    }

    /// レコード削除
    func delete(object: RealmSwift.Object) throws {
        let executionError = executionBlock(realm: realm) { [weak self] in
            self?.realm.delete(object)
        }

        // エラーがある場合throw
        if let executionError = executionError {
            throw executionError
        }
    }

    /// レコード削除
    func delete(objects: [RealmSwift.Object]) throws {
        let executionError = executionBlock(realm: realm) { [weak self] in
            self?.realm.delete(objects)
        }

        // エラーがある場合throw
        if let executionError = executionError {
            throw executionError
        }
    }

    // MARK: - Find records

    /// 全件取得
    func findAll(for type: RealmSwift.Object.Type) -> Results<RealmSwift.Object> {
        return realm.objects(type)
    }

    /// 指定キーのレコードを取得
    func findById(id: Any, for type: RealmSwift.Object.Type) -> RealmSwift.Object? {
        return realm.object(ofType: type, forPrimaryKey: id)
    }

    /// 指定キーのレコードを取得(複数)
    func findByIds(ids: [Any], type: RealmSwift.Object.Type) -> Results<RealmSwift.Object>? {
        guard let pk = type.primaryKey() else {
            return nil
        }
        let predicate = NSPredicate(format: "\(pk) IN %@", ids)
        let results = realm.objects(type).filter(predicate)
        return results
    }
}

// MARK: - private
extension RealmDataStore {

    private func transaction(block:(() throws -> Void)? = nil) throws {
        realm.beginWrite()
        do {
            try block?()
            try realm.commitWrite()
        } catch {
            log("transaction", error, "realm.cancelWrite()")
            realm.cancelWrite()
            throw error
        }
    }

    private func executionBlock(realm: Realm, block:(() -> Void)? = nil) -> Swift.Error? {
        // WriteTransaction外の場合は、outsideOfTransactionBlockを実行する
        if !realm.isInWriteTransaction {
            return outsideOfTransactionBlock(realm: realm, block: block)
        }

        do {
            try execute {
                block?()
            }
            return nil

        } catch {
            log("executionBlock error:", error)
            return error
        }
    }

    private func outsideOfTransactionBlock(realm: Realm, block:(() -> Void)? = nil) -> Swift.Error? {
        do {
            try realm.write {
                try execute {
                    block?()
                }
            }
            return nil

        } catch {
            log("outsideOfTransactionBlock error:", error)
            return error
        }
    }
}
