import Foundation

func readFile(filePath: String) -> String {

    guard
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
        let contents = String(data: data, encoding: .utf8)
    else {
        return ""
    }
    return contents
}

func filterCharsAndNormalize(strData: String) -> String {
    return strData.map { c in
        return (c.isLetter || c.isNumber) ? c.lowercased() : " ";
    }.joined()
}

func scan(strData: String) -> [String] {
    return strData.components(separatedBy: [" "])
}

func removeStopWords(words: [String]) -> [String] {
    guard
        let data = try? Data(contentsOf: URL(fileURLWithPath: "../stop_words.txt")),
        let contents = String(data: data, encoding: .utf8)
    else {
        return words
    }
    var stopWords = contents.components(separatedBy: ",")
    let lowercaseLetters = "abcdefghijklmnopqrstuvwxyz".map { String($0) }
    stopWords.append(contentsOf: lowercaseLetters)

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

func printAll(elements: [Dictionary<String, Int>.Element]) {
    guard elements.count > 0 else { return }
    print("\(elements[0].0) - \(elements[0].1)")
    printAll(elements: Array(elements.dropFirst()))
}

printAll(elements: sortFreq(wordFreqs: frequencies(words: removeStopWords(words: scan(strData: filterCharsAndNormalize(strData: readFile(filePath: CommandLine.arguments.last!)))))).prefix(upTo: 25).map { $0 })
