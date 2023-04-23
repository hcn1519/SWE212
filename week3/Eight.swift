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

func mergeSort(words: inout [String], wordFreqs: inout [String: Int], lhsIdx: Int, rhsIdx: Int) -> [String] {

    var words = words
    var wordFreqs = wordFreqs
    // base case
    if rhsIdx - lhsIdx == 0 {
        return [words[lhsIdx]]
    }

    let half =  Int((lhsIdx + rhsIdx) / 2)
    let leftSlice = mergeSort(words: &words, wordFreqs: &wordFreqs, lhsIdx: lhsIdx, rhsIdx: half)
    let rightSlice = mergeSort(words: &words, wordFreqs: &wordFreqs, lhsIdx: half + 1, rhsIdx: rhsIdx)

    // merge sorted leftSlice and rightSlice
    var res: [String] = []
    var l = 0
    var r = 0

    while (l < leftSlice.count && r < rightSlice.count) {

        if wordFreqs[leftSlice[l]]! < wordFreqs[rightSlice[r]]! {
            res.append(leftSlice[l])
            l += 1
        } else {
            res.append(rightSlice[r])
            r += 1
        }
    }

    if l == leftSlice.count && r < rightSlice.count {
      res.append(contentsOf: rightSlice[r..<rightSlice.count])
    } else if r == rightSlice.count && l < leftSlice.count {
      res.append(contentsOf: leftSlice[l..<leftSlice.count])
    }
    return res
}

func sortFreq(wordFreqs: [String: Int]) -> [(String, Int)] {

    var words = wordFreqs.keys.map { String($0)}
    var wordFreqs = wordFreqs
    let sortedWords = mergeSort(words: &words,
                                wordFreqs: &wordFreqs,
                                lhsIdx: 0,
                                rhsIdx: words.count - 1)

    return sortedWords.map { ($0, wordFreqs[$0]!) }
}

func printAll(elements: [(String, Int)]) {
    guard elements.count > 0 else { return }
    print("\(elements[0].0) - \(elements[0].1)")
    printAll(elements: Array(elements.dropFirst()))
}

printAll(elements: sortFreq(wordFreqs: frequencies(words: removeStopWords(words: scan(strData: filterCharsAndNormalize(strData: readFile(filePath: CommandLine.arguments.last!)))))).reversed().prefix(upTo: 25).map { $0 })
