//
//  Schema.swift
//  CodeGen
//
//  Created by Maxim Zaks on 19.07.17.
//  Copyright © 2017 maxim.zaks. All rights reserved.
//

import Foundation

struct Include {
    let path: StringLiteral
}
extension Include: ASTNode {
    static func with(pointer: UnsafePointer<UInt8>, length: Int) -> (Include, UnsafePointer<UInt8>)? {
        guard let r = parse("include", pointer: pointer, length: length) else {
            return nil
        }
        return (Include(path: r.0), r.1)
    }
}

struct Attribute {
    let value: StringLiteral
}
extension Attribute: ASTNode {
    static func with(pointer: UnsafePointer<UInt8>, length: Int) -> (Attribute, UnsafePointer<UInt8>)? {
        guard let r = parse("attribute", pointer: pointer, length: length) else {
            return nil
        }
        return (Attribute(value: r.0), r.1)
    }
}

struct FileExtension {
    let value: StringLiteral
}
extension FileExtension: ASTNode {
    static func with(pointer: UnsafePointer<UInt8>, length: Int) -> (FileExtension, UnsafePointer<UInt8>)? {
        guard let r = parse("file_extension", pointer: pointer, length: length) else {
            return nil
        }
        return (FileExtension(value: r.0), r.1)
    }
}

struct FileIdent {
    let value: StringLiteral
}
extension FileIdent: ASTNode {
    static func with(pointer: UnsafePointer<UInt8>, length: Int) -> (FileIdent, UnsafePointer<UInt8>)? {
        guard let r = parse("file_identifier", pointer: pointer, length: length) else {
            return nil
        }
        return (FileIdent(value: r.0), r.1)
    }
}

fileprivate func parse(_ prefix: StaticString, pointer: UnsafePointer<UInt8>, length: Int) -> (StringLiteral, UnsafePointer<UInt8>)? {
    var p0 = pointer
    var length = length
    var comments = [Comment]()
    while let r = Comment.with(pointer: p0, length: length) {
        comments.append(r.0)
        length -= p0.distance(to: r.1)
        p0 = r.1
    }
    guard let p1 = eat(prefix, from: p0, length: length) else {return nil}
    length = length - p0.distance(to: p1)
    guard let (value, p2) = StringLiteral.with(pointer: p1, length: length) else {return nil}
    length -= p1.distance(to: p2)
    guard let p3 = eat(";", from: p2, length: length) else {return nil}
    return (value, p3)
}

struct Namespace {
    let parts: [Ident]
}
extension Namespace: ASTNode {
    static func with(pointer: UnsafePointer<UInt8>, length: Int) -> (Namespace, UnsafePointer<UInt8>)? {
        var p0 = pointer
        var length = length
        var comments = [Comment]()
        while let r = Comment.with(pointer: p0, length: length) {
            comments.append(r.0)
            length -= p0.distance(to: r.1)
            p0 = r.1
        }
        guard let p1 = eat("namespace", from: p0, length: length) else {return nil}
        length = length - p0.distance(to: p1)
        var p2 = p1
        var parts = [Ident]()
        while let (part, _p2) = Ident.with(pointer: p2, length: length) {
            length -= p2.distance(to: _p2)
            parts.append(part)
            p2 = _p2
            guard let _p3 = eat(".", from: p2, length: length) else {break}
            length -= p2.distance(to: _p3)
            p2 = _p3
        }
        guard let p3 = eat(";", from: p2, length: length) else {return nil}
        return (Namespace(parts: parts), p3)
    }
}

struct RootType {
    let ident: Ident
}
extension RootType: ASTNode {
    static func with(pointer: UnsafePointer<UInt8>, length: Int) -> (RootType, UnsafePointer<UInt8>)? {
        var p0 = pointer
        var length = length
        var comments = [Comment]()
        while let r = Comment.with(pointer: p0, length: length) {
            comments.append(r.0)
            length -= p0.distance(to: r.1)
            p0 = r.1
        }
        guard let p1 = eat("root_type", from: p0, length: length) else {return nil}
        length = length - p0.distance(to: p1)
        guard let (ident, p2) = Ident.with(pointer: p1, length: length) else {return nil}
        length -= p1.distance(to: p2)
        guard let p3 = eat(";", from: p2, length: length) else {return nil}
        return (RootType(ident: ident), p3)
    }
}

struct Schema {
    let includes: [Include]
    let namespace: Namespace?
    let rootType: RootType?
    let fileIdent: FileIdent?
    let fileExtansion: FileExtension?
    let attributes: [Attribute]
    let tables: [Table]
    let structs: [Struct]
    let enums: [Enum]
    let unions: [Union]
}

extension Schema: ASTNode {
    static func with(pointer: UnsafePointer<UInt8>, length: Int) -> (Schema, UnsafePointer<UInt8>)? {
        var includes: [Include] = []
        var namespace: Namespace?
        var rootType: RootType?
        var fileIdent: FileIdent?
        var fileExtension: FileExtension?
        var attributes: [Attribute] = []
        var tables: [Table] = []
        var structs: [Struct] = []
        var enums: [Enum] = []
        var unions: [Union] = []
        
        var p1 = pointer
        var length = length
        while(true) {
            if let r = Include.with(pointer: p1, length: length) {
                length -= p1.distance(to: r.1)
                includes.append(r.0)
                p1 = r.1
                continue
            }
            if let r = Namespace.with(pointer: p1, length: length) {
                length -= p1.distance(to: r.1)
                guard namespace == nil else {return nil}
                namespace = r.0
                p1 = r.1
                continue
            }
            if let r = RootType.with(pointer: p1, length: length) {
                length -= p1.distance(to: r.1)
                guard rootType == nil else {return nil}
                rootType = r.0
                p1 = r.1
                continue
            }
            if let r = FileIdent.with(pointer: p1, length: length) {
                length -= p1.distance(to: r.1)
                guard fileIdent == nil else {return nil}
                fileIdent = r.0
                p1 = r.1
                continue
            }
            if let r = FileExtension.with(pointer: p1, length: length) {
                length -= p1.distance(to: r.1)
                guard fileExtension == nil else {return nil}
                fileExtension = r.0
                p1 = r.1
                continue
            }
            if let r = Attribute.with(pointer: p1, length: length) {
                length -= p1.distance(to: r.1)
                attributes.append(r.0)
                p1 = r.1
                continue
            }
            if let r = Table.with(pointer: p1, length: length) {
                length -= p1.distance(to: r.1)
                tables.append(r.0)
                p1 = r.1
                continue
            }
            if let r = Struct.with(pointer: p1, length: length) {
                length -= p1.distance(to: r.1)
                structs.append(r.0)
                p1 = r.1
                continue
            }
            if let r = Enum.with(pointer: p1, length: length) {
                length -= p1.distance(to: r.1)
                enums.append(r.0)
                p1 = r.1
                continue
            }
            if let r = Union.with(pointer: p1, length: length) {
                length -= p1.distance(to: r.1)
                unions.append(r.0)
                p1 = r.1
                continue
            }
            break
        }
        
        return (Schema(
            includes: includes,
            namespace: namespace,
            rootType: rootType,
            fileIdent: fileIdent,
            fileExtansion: fileExtension,
            attributes: attributes,
            tables: tables,
            structs: structs,
            enums: enums,
            unions: unions
        ), p1)
    }
}

struct IdentLookup {
    let structs: [String: Struct]
    let tables: [String:Table]
    let enums: [String: Enum]
    let unions: [String: Union]
}

extension Schema {
    var identLookup: IdentLookup {
        var structs = [String:Struct]()
        var tables = [String:Table]()
        var enums = [String: Enum]()
        var unions =  [String: Union]()
        
        for s in self.structs {
            structs[s.name.value] = s
        }
        for t in self.tables {
            tables[t.name.value] = t
        }
        for e in self.enums {
            enums[e.name.value] = e
        }
        for u in self.unions {
            unions[u.name.value] = u
        }
        
        return IdentLookup(structs: structs, tables: tables, enums: enums, unions: unions)
    }
}
