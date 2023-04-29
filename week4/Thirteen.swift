import Foundation

// Helper Functions
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

// Auxiliary functions that can't be lambdas

func extractWords(obj: inout [String: Any], filePath: String) {
    obj["data"] = scan(strData: filterCharsAndNormalize(strData: readFile(filePath: filePath)))
}

func loadStopWords(obj: inout [String: Any]) {
    guard
        let data = try? Data(contentsOf: URL(fileURLWithPath: "../stop_words.txt")),
        let contents = String(data: data, encoding: .utf8)
    else {
        return
    }
    var stopWords = contents.components(separatedBy: ",")
    let lowercaseLetters = "abcdefghijklmnopqrstuvwxyz".map { String($0) }
    stopWords.append(contentsOf: lowercaseLetters)
    stopWords.append("")
    obj["stop_words"] = Set(stopWords)
}

func incrementCount(obj: inout [String: Any], word: String) {
    var dic = obj["freqs"] as! [String: Int]

    if let count = dic[word] {
        dic[word] = count + 1
    } else {
        dic[word] = 1
    }
    obj["freqs"] = dic
}

func sorted(obj: [String: Any]) -> [Dictionary<String, Int>.Element] {
    let dic = obj["freqs"] as! [String: Int]
    return dic.sorted { $0.1 > $1.1 }
}

var dataStorageObj: [String: Any] = [
    "data": [String](),
    "init": { filePath in extractWords(obj: &dataStorageObj, filePath: filePath) },
    "words": { return dataStorageObj["data"] as! [String] }
]

var stopWordsObj: [String: Any] = [
    "stop_words" : Set<String>(),
    "init": { loadStopWords(obj: &stopWordsObj) },
    "is_stop_word": { word in return (stopWordsObj["stop_words"] as! Set<String>).contains(word) }
]

var wordFreqsObj: [String: Any] = [
    "freqs": [String: Int](),
    "increment_count": { w in incrementCount(obj: &wordFreqsObj, word: w) },
    "sorted": { return sorted(obj: wordFreqsObj) }
]

(dataStorageObj["init"] as! (String) -> Void)(CommandLine.arguments.last ?? "")
(stopWordsObj["init"] as! () -> Void)()

(dataStorageObj["words"] as! () -> [String])().forEach { w in
    if !(stopWordsObj["is_stop_word"] as! (String) -> Bool)(w) {
        (wordFreqsObj["increment_count"] as! (String) -> Void)(w)
    }
}
let sorted: [Dictionary<String, Int>.Element] = (wordFreqsObj["sorted"] as! () -> [Dictionary<String, Int>.Element])()
sorted.prefix(upTo: 25).map{ $0 }.forEach { print("\($0) - \($1)")}
