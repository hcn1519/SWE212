import Foundation

typealias PrintAll = [Dictionary<String, Int>.Element]
typealias SortFreqFunc = (PrintAll) -> Void
typealias FrequenciesFunc = ([String: Int], (PrintAll) -> Void) -> Void
typealias RemoveStopWordsFunc = ([String], ([String: Int], SortFreqFunc) -> Void) -> Void
typealias ScanFunc = ([String], ([String], FrequenciesFunc) -> Void) -> Void
typealias FilterCharsAndNormalizeFunc = (String, ([String], RemoveStopWordsFunc) -> Void) -> Void
typealias ReadFileFunc = (String, (String, ScanFunc) -> Void) -> Void

func readFile(filePath: String, def: ReadFileFunc) {

    guard
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
        let contents = String(data: data, encoding: .utf8)
    else {
        return
    }
    // filterCharsAndNormalize
    def(contents, scan)
}

func filterCharsAndNormalize(strData: String, def: FilterCharsAndNormalizeFunc) {
    let joined = strData.map { c in
        return (c.isLetter || c.isNumber) ? c.lowercased() : " ";
    }.joined()

    // scan
    def(joined, removeStopWords)
}

func scan(strData: String, def: ScanFunc) {
    let scanned = strData.components(separatedBy: [" "])

    // removeStopWords
    def(scanned, frequencies)
}

func removeStopWords(words: [String], def: RemoveStopWordsFunc) {
    guard
        let data = try? Data(contentsOf: URL(fileURLWithPath: "../stop_words.txt")),
        let contents = String(data: data, encoding: .utf8)
    else {
        return
    }
    var stopWords = contents.components(separatedBy: ",")
    let lowercaseLetters = "abcdefghijklmnopqrstuvwxyz".map { String($0) }
    stopWords.append(contentsOf: lowercaseLetters)

    let filteredWords = words.filter { w in
        return !stopWords.contains(w) && w != ""
    }

    // frequencies
    def(filteredWords, sortFreq)
}

func frequencies(words: [String], def: FrequenciesFunc) {
    let dic = Dictionary(grouping: words) { $0 }.mapValues { $0.count }

    // sortFreq
    def(dic, printAll)
}

func sortFreq(wordFreqs: [String: Int], def: SortFreqFunc) {
    let sorted = wordFreqs.sorted { $0.1 > $1.1 }
    // printAll
    def(sorted)
}

func printAll(elements: [Dictionary<String, Int>.Element]) {
    elements.prefix(upTo: 25).forEach { e in
        print("\(e.0) - \(e.1)")
    }
}

readFile(filePath: CommandLine.arguments.last!, def: filterCharsAndNormalize)