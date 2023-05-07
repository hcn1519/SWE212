
import Foundation

enum TwentyTwoError: Error {
    case filePathIsEmpty
}

    //Every single procedure and function checks the sanity of its arguments and refuses to continue when the arguments are unreasonable
    //All code blocks check for all possible errors, possibly print out context-specific messages when errors occur, and pass the errors up the function call chain

func readFile(filePath: String) throws -> String {

    guard filePath != "" else {
        throw TwentyTwoError.filePathIsEmpty
    }
    let url = URL(fileURLWithPath: filePath)
    let data = try Data(contentsOf: url)
    return String(data: data, encoding: .utf8) ?? ""
}

func extractWords(filePath: String) throws -> [String] {
    let contents = try readFile(filePath: filePath)
    return contents
        .map { return ($0.isLetter || $0.isNumber) ? $0.lowercased() : " " }
        .joined()
        .components(separatedBy: [" "])
}

func removeStopWords(words: [String]) throws -> [String] {
    assert(!words.isEmpty, "words should not be empty")
  
    let data = try Data(contentsOf: URL(fileURLWithPath: "../stop_words.txt"))
    let contents = String(data: data, encoding: .utf8) ?? ""
    let lowercaseLetters = "abcdefghijklmnopqrstuvwxyz".map { String($0) }
    let stopWords = contents
        .trimmingCharacters(in: CharacterSet(["\n"]))
        .components(separatedBy: ",") + lowercaseLetters + [""]

    return words.filter { w in
        return !stopWords.contains(w) && w != ""
    }
}

func frequencies(words: [String]) -> [String: Int] {
    assert(!words.isEmpty, "words should not be empty")

    return Dictionary(grouping: words) { $0 }.mapValues { $0.count }
}

func sortFreq(wordFreqs: [String: Int]) -> [Dictionary<String, Int>.Element] {
    assert(!wordFreqs.isEmpty, "wordFreqs should not be empty")
    return wordFreqs.sorted { $0.1 > $1.1 }
}

func top25<T>(wordPairs: [T]) -> [T] {
    assert(!wordPairs.isEmpty, "wordPairs should not be empty")
    return wordPairs.prefix(upTo: min(wordPairs.count, 25)).map { $0 }
}

func printAll(elements: [Dictionary<String, Int>.Element]) {
    assert(!elements.isEmpty, "elements should not be empty")

    elements.forEach {
        print("\($0.0) - \($0.1)")
    }
}

do {
    assert(CommandLine.arguments.count > 1, "Input file should be provided")
    let filePath = CommandLine.arguments[1]
    let extractedWords = try extractWords(filePath: filePath)
    let filteredWords = try removeStopWords(words: extractedWords)
    let sortedFreq = sortFreq(wordFreqs: frequencies(words: filteredWords))
    printAll(elements: top25(wordPairs: sortedFreq))
} catch let error {
    print("error happens: \(error)")
}
