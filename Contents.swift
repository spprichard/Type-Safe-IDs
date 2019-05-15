// Inspired By https://www.swiftbysundell.com/posts/type-safe-identifiers-in-swift

import Foundation

struct Identifier<Value>: Hashable {
    let string: String
}

// Breaks after refactor to make Identifier type more generic
//let someID = Identifier(string: "some-unique-value")
//someID.string


extension Identifier: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        string = value
    }
}

extension Identifier: CustomStringConvertible {
    var description: String {
        return string
    }
}

extension Identifier: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        string = try container.decode(String.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(string)
    }
}

struct User: Codable {
    enum error: Error {
        case encodingToString
    }
    
    var id: Identifier<User>
    var name: String
}

let john = User(id: "john-sundell", name: "John Sundel")
john.id

let jsonData = try JSONEncoder().encode(john)
guard let jsonString = String(bytes: jsonData, encoding: .utf8) else {
    // This is pretty neat, by placing enum in User definition, you can namespace it.
    // Makes that throw more readible
    throw User.error.encodingToString
}

print(jsonString)

struct Article {
    var id: Identifier<Article>
    var title: String
}

struct ArticleManager {
    func find(by id: Identifier<Article>) -> Article? {
        // implementation is not important here
        return nil
    }
}

let someArticle = Article(id: "article-01", title: "My First Article")
let articleManager = ArticleManager()

// Line below produces a compile time error,
// the identifier type is now generic over some specifc type.
// Meaning, you can leverage the type system to validate you are giving in the
// correct identifier when you are trying to find that type
// articleManager.find(by: john.id)
// ^ uncomment to see error ^ // 


// The line below represents the proper way to find an article
articleManager.find(by: someArticle.id)



