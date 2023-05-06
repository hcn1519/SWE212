import Foundation

func readFile(filePath: String) -> String {
    guard
        filePath != "",
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath))
    else {
        return ""
    }
    return String(data: data, encoding: .utf8) ?? ""
}

func extractWords(filePath: String) -> [String] {

    let contents = readFile(filePath: filePath)

    guard contents != "" else {
        return []
    }
    return contents
        .map { return ($0.isLetter || $0.isNumber) ? $0.lowercased() : " " }
        .joined()
        .components(separatedBy: [" "])
}

func removeStopWords(words: [String]) -> [String] {
    guard
        let data = try? Data(contentsOf: URL(fileURLWithPath: "../stop_words.txt")),
        let contents = String(data: data, encoding: .utf8)
    else {
        return words
    }

    let lowercaseLetters = "abcdefghijklmnopqrstuvwxyz".map { String($0) }
    let stopWords = contents
        .trimmingCharacters(in: CharacterSet(["\n"]))
        .components(separatedBy: ",") + lowercaseLetters + [""]

    return words.filter { w in
        return !stopWords.contains(w) && w != ""
    }
}

func frequencies(words: [String]) -> [String: Int] {
    return Dictionary(grouping: words) { $0 }.mapValues { $0.count }
}

func sortFreq(wordFreqs: [String: Int]) -> [Dictionary<String, Int>.Element] {
    return wordFreqs.sorted { $0.1 > $1.1 }
}

func top25<T>(wordPairs: [T]) -> [T] {
    guard wordPairs.count > 0 else {
        return []
    }
    return wordPairs.prefix(upTo: min(wordPairs.count, 25)).map { $0 }
}

func printAll(elements: [Dictionary<String, Int>.Element]) {
    guard elements.count > 0 else { return }
    print("\(elements[0].0) - \(elements[0].1)")
    printAll(elements: Array(elements.dropFirst()))
}

let filePath = CommandLine.arguments.count > 1 ? CommandLine.arguments.last ?? "" : "../pride-and-prejudice.txt"
let extractedWords = extractWords(filePath: filePath)
let sortedFreq = sortFreq(wordFreqs: frequencies(words: removeStopWords(words: extractedWords)))
printAll(elements: top25(wordPairs: sortedFreq))