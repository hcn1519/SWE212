import Foundation
let fts = { String(data: try! Data(contentsOf: URL(fileURLWithPath: $0)), encoding: .utf8)! }
let sw = fts("../stop_words.txt").components(separatedBy: ",") + "abcdefghijklmnopqrstuvwxyz".map {String($0)} + [""]
Dictionary(grouping: fts(CommandLine.arguments.last!).map { ($0.isLetter || $0.isNumber) ? $0.lowercased() : " " }.joined().components(separatedBy: " ").filter { !sw.contains($0) }) { $0 }.mapValues { $0.count }.sorted { $0.1 > $1.1 }.prefix(upTo: 25).map{ $0 }.forEach { print("\($0) - \($1)")}