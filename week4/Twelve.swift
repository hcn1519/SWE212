import Foundation

protocol Dispatchable {
    func dispatch(messages: [String]) -> Any
}

class DataStorageManager: Dispatchable {
    var data: [String] = []

    func dispatch(messages: [String]) -> Any {
        if messages[0] == "init" {
            self.data = initialize(filePath: messages[1])
            return self.data
        } else if messages[0] == "words" {
            return self.splitWords(strData: self.data)
        }
        return ""
    }

    private func initialize(filePath: String) -> [String] {
        guard
            let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
            let contents = String(data: data, encoding: .utf8)
        else {
            return []
        }
        return filterCharsAndNormalize(strData: contents)
    }

    private func filterCharsAndNormalize(strData: String) -> [String] {
        return strData.map { c in
            return (c.isLetter || c.isNumber) ? c.lowercased() : " ";
        }
    }

    private func splitWords(strData: [String]) -> [String] {
        return strData.joined().components(separatedBy: [" "])
    }
}

class StopWordManager: Dispatchable {

    var stopWords = Set<String>()

    func dispatch(messages: [String]) -> Any {
        if messages[0] == "init" {
            return self.initialize()
        } else if messages[0] == "is_stop_word" {
            return self.isStopWord(word: messages[1])
        }

        return ""
    }

    private func initialize() -> Set<String> {
       guard
           let data = try? Data(contentsOf: URL(fileURLWithPath: "../stop_words.txt")),
           let contents = String(data: data, encoding: .utf8)
       else {
           return stopWords
       }
        var stopWords = contents.components(separatedBy: ",")
        let lowercaseLetters = "abcdefghijklmnopqrstuvwxyz".map { String($0) }
        stopWords.append(contentsOf: lowercaseLetters)
        self.stopWords = Set(stopWords)
        return self.stopWords
    }

    private func isStopWord(word: String) -> Bool {
        return stopWords.contains(word) || word == ""
    }
}

class WordFrequencyManager: Dispatchable {

    var wordFreq: [String: Int] = [:]

    func dispatch(messages: [String]) -> Any {
        if messages[0] == "increment_count" {
            return self.incrementCount(word: messages[1])
        } else if messages[0] == "sorted" {
            return self.sorted()
        }
        return ""
    }

    private func incrementCount(word: String) {
        if let count = wordFreq[word] {
            wordFreq[word] = count + 1
        } else {
            wordFreq[word] = 1
        }
    }

    private func sorted() -> [Dictionary<String, Int>.Element] {
        return wordFreq.sorted { $0.1 > $1.1 }
    }
}

class WordFrequencyController {

    private let storageManager = DataStorageManager()
    private let stopWordManager = StopWordManager()
    private let wordFrequencyManager = WordFrequencyManager()

    func dispatch(messages: [String]) {
        if messages[0] == "init" {
            self.initialize(filePath: messages[1])
        } else if messages[0] == "run" {
            self.run()
        }
    }

    private func initialize(filePath: String) {
        let _ = storageManager.dispatch(messages: ["init", filePath])
        let _ = stopWordManager.dispatch(messages: ["init"])
    }

    private func run() {
        guard let words = storageManager.dispatch(messages: ["words"]) as? [String] else {
            return
        }

        words.forEach { w in
            let isStopWord = stopWordManager.dispatch(messages: ["is_stop_word", w]) as? Bool ?? false

            if !isStopWord {
                let _ = wordFrequencyManager.dispatch(messages: ["increment_count", w])

            }
        }

        let sorted = wordFrequencyManager.dispatch(messages: ["sorted"]) as? [Dictionary<String, Int>.Element] ?? []
        sorted.prefix(upTo: 25).map{ $0 }.forEach { print("\($0) - \($1)")}
    }
}

let wfController = WordFrequencyController()
wfController.dispatch(messages: ["init", CommandLine.arguments.last ?? ""])
wfController.dispatch(messages: ["run"])