import Foundation 

// Helper Interface for typing
protocol Argument {}
extension String: Argument {}
extension Array: Argument {}
extension Dictionary: Argument where Key == String, Value == Int {}

class Context<T> {
    var data: T

    init(data: T) {
        self.data = data
    }
}
typealias ContextCallable = (Context<Argument>?) -> Context<Argument>

// Implementation
class TFQuarantine {

    private var funcs: [ContextCallable] = []

    init(contextFunc: @escaping ContextCallable) {
        funcs.append(contextFunc)
    }

    func bind(def: @escaping ContextCallable) -> Self {
        self.funcs.append(def)
        return self
    }

    func execute() {
        var value = self.funcs.removeFirst()(nil)
        self.funcs.forEach { callable in
            value = callable(value)
        }
        print(value.data)
    }
}

func getInput(context: Context<any Argument>?) -> Context<any Argument> {
    guard CommandLine.arguments.count > 1 else {
        return Context(data: "")
    }
    return Context(data: CommandLine.arguments[1])
}

func extractWords(context: Context<any Argument>?) -> Context<any Argument> {

    do {
        let filePath = context?.data as? String ?? ""
        let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
        let contents = String(data: data, encoding: .utf8) ?? ""

        let extractedWords = contents
            .map { return ($0.isLetter || $0.isNumber) ? $0.lowercased() : " " }
            .joined()
            .components(separatedBy: [" "])

        return Context(data: extractedWords)
    } catch {
        return Context(data: [String]())
    }
}

func removeStopWords(context: Context<any Argument>?) -> Context<any Argument> {

    do {
        let data = try Data(contentsOf: URL(fileURLWithPath: "../stop_words.txt"))
        let contents = String(data: data, encoding: .utf8) ?? ""
        let lowercaseLetters = "abcdefghijklmnopqrstuvwxyz".map { String($0) }
        let stopWords = contents
            .trimmingCharacters(in: CharacterSet(["\n"]))
            .components(separatedBy: ",") + lowercaseLetters + [""]

        let words = context?.data as? [String] ?? []
        return Context(data: words.filter { w in
            return !stopWords.contains(w) && w != ""
        })
    } catch {
        return Context(data: [String]())
    }
}

func frequencies(context: Context<any Argument>?) -> Context<any Argument> {
    let words = context?.data as? [String] ?? []
    return Context(data: Dictionary(grouping: words) { $0 }.mapValues { $0.count })
}

func sortFreq(context: Context<any Argument>?) -> Context<any Argument> {
    let wordFreqs = context?.data as? [String: Int] ?? [:]
    return Context(data: wordFreqs.sorted { $0.1 > $1.1 })
}

func top25(context: Context<any Argument>?) -> Context<any Argument> {

    let wordPairs = context?.data as? [Dictionary<String, Int>.Element] ?? []

    let res = wordPairs
        .prefix(upTo: min(wordPairs.count, 25))
        .reduce(into: "", {acc, cur in
            acc += "\(cur.key) - \(cur.value)\n"
        })
    return Context(data: res)
}

TFQuarantine(contextFunc: getInput)
    .bind(def: extractWords)
    .bind(def: removeStopWords)
    .bind(def: frequencies)
    .bind(def: sortFreq)
    .bind(def: top25)
    .execute()