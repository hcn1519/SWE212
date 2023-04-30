import Foundation

class WordFrequencyFramework {
    var loadEventHandlers: [(String) -> Void] = []
    var doWorkEventHandlers: [() -> Void] = []
    var endEventHandlers: [() -> Void] = []

    func register(loadHandler: @escaping (String) -> Void) {
        self.loadEventHandlers.append(loadHandler)
    }

    func register(doWorkHandler: @escaping () -> Void) {
        self.doWorkEventHandlers.append(doWorkHandler)
    }

    func register(endHandler: @escaping () -> Void) {
        self.endEventHandlers.append(endHandler)
    }

    func run(filePath: String) {
        self.loadEventHandlers.forEach {
            $0(filePath)
        }
        self.doWorkEventHandlers.forEach {
            $0()
        }
        self.endEventHandlers.forEach {
            $0()
        }
    }
}

// The entities of the application

class DataStorage {
    weak var stopWordFilter: StopWordFilter?
    private var data: [String] = []
    var wordEventHandlers: [(String) -> Void] = []

    init(wfapp: WordFrequencyFramework, stopWordFilter: StopWordFilter? = nil) {
        self.stopWordFilter = stopWordFilter
        wfapp.register(loadHandler: load)
        wfapp.register(doWorkHandler: self.produceWords)
    }

    private func load(filePath: String) {
        self.data = scan(strData: filterCharsAndNormalize(strData: readFile(filePath: filePath)))
    }

    private func readFile(filePath: String) -> String {
        guard
            let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
            let contents = String(data: data, encoding: .utf8)
        else {
            return ""
        }
        return contents
    }

    private func filterCharsAndNormalize(strData: String) -> String {
        return strData.map { c in
            return (c.isLetter || c.isNumber) ? c.lowercased() : " ";
        }.joined()
    }

    private func scan(strData: String) -> [String] {
        return strData.components(separatedBy: [" "])
    }

    private func produceWords() {
        for w in self.data {
            if !(stopWordFilter?.isStopWord(word: w) ?? false) {
                self.wordEventHandlers.forEach {
                    $0(w)
                }
            }
        }
    }

    func register(wordEventHandler: @escaping (String) -> Void) {
        self.wordEventHandlers.append(wordEventHandler)
    }
}

class StopWordFilter {
    private var stopWords = Set<String>()

    init(wfapp: WordFrequencyFramework) {
        wfapp.register(loadHandler: load)
    }

    func load(ignore: String) {
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
        self.stopWords = Set(stopWords)
    }

    func isStopWord(word: String) -> Bool {
        return self.stopWords.contains(word)
    }
}

class WordFrequencyCounter {
    private var wordFreqs: [String: Int] = [:]

    init(wfapp: WordFrequencyFramework, dataStorage: DataStorage) {
        dataStorage.register(wordEventHandler: self.incrementCount)
        wfapp.register(endHandler: self.printFreqs)
    }

    private func incrementCount(word: String) {
        if let count = wordFreqs[word] {
            wordFreqs[word] = count + 1
        } else {
            wordFreqs[word] = 1
        }
    }

    private func printFreqs() {
        wordFreqs.sorted { $0.1 > $1.1 }.prefix(upTo: 25).map{ $0 }.forEach { print("\($0) - \($1)")}
    }
}

let wfapp = WordFrequencyFramework()
let stopWordFilter = StopWordFilter(wfapp: wfapp)
let dataStorage = DataStorage(wfapp: wfapp, stopWordFilter: stopWordFilter)
let word_freq_counter = WordFrequencyCounter(wfapp: wfapp, dataStorage: dataStorage)
wfapp.run(filePath: CommandLine.arguments.last ?? "")
