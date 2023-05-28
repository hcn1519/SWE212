import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

    func partition(filePath: String, numberOfLines: Int) -> [[String]] {
        let contents = readFile(filePath: filePath)
        let lines = contents.split(separator: "\n").map { String($0) }
        return lines.chunked(into: numberOfLines)
    }

    func readFile(filePath: String) -> String {
        guard
            filePath != "",
            let data = try? Data(contentsOf: URL(fileURLWithPath: filePath))
        else {
            return ""
        }
        return String(data: data, encoding: .utf8) ?? ""
    }

    func stopWords() -> Set<String> {
        guard
            let data = try? Data(contentsOf: URL(fileURLWithPath: "../stop_words.txt")),
            let contents = String(data: data, encoding: .utf8)
        else {
            return Set()
        }
        var stopWords = contents.components(separatedBy: ",")
        let lowercaseLetters = "abcdefghijklmnopqrstuvwxyz".map { String($0) }
        stopWords.append(contentsOf: lowercaseLetters)
        return Set(stopWords)
    }

    func splitWords(lines: [String]) -> [(String, Int)] {

        let stopWordSet = stopWords()

        let wordPairs = lines
            .map { line in
                return line
                    .map {
                        return ($0.isLetter || $0.isNumber) ? $0.lowercased() : " "
                    }.joined()
                    .components(separatedBy: [" "])
                    .compactMap {
                        return stopWordSet.contains($0) || $0 == "" ? nil : ($0, 1)
                    }
            }.joined()
        return Array(wordPairs)
    }

    func regroup(pairs: [(String, Int)]) -> [String: [(String, Int)]] {
        var dict: [String: [(String, Int)]] = [:]
        for pair in pairs {
            let v = dict[pair.0] ?? []
            dict[pair.0] = v + [pair]
        }
        return dict
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

let filePath = CommandLine.arguments.last ?? "../pride-and-prejudice.txt"

let strChunks = partition(filePath: filePath, numberOfLines: 200)

let splitedWordPairs = strChunks
    .map { lines in
        return splitWords(lines: lines)
    }.joined()

let splitPerWords = regroup(pairs: Array(splitedWordPairs))

let wordFreqs = splitPerWords.reduce(into: [String: Int]()) { partialResult, wordPair in
    partialResult[wordPair.key] = wordPair.value.count
}
printAll(elements: top25(wordPairs: sortFreq(wordFreqs: wordFreqs)))
