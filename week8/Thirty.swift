
import Foundation

class BlockingQueue<T> {
    private(set) var queue = [T]()
    private let semaphore = DispatchSemaphore(value: 2)
    private let lock = NSLock()

    func put(_ item: T) {
        lock.lock()
        queue.append(item)
        lock.unlock()
        semaphore.signal()
    }

    func get() -> T {
        semaphore.wait()
        lock.lock()
        let item = queue.removeFirst()
        lock.unlock()
        return item
    }
}

enum Thirty {
    case instance

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

    func run() {
        let wordSpace = BlockingQueue<String>()
        let freqSpace = BlockingQueue<[String: Int]>()

        let filePath = CommandLine.arguments.last ?? "../pride-and-prejudice.txt"

        let stopWords = stopWords()

        @Sendable func processWords() async {
            var freq: [String: Int] = [:]
            while !wordSpace.queue.isEmpty {
                let word = wordSpace.get()
                if !stopWords.contains(word) && word != "" {
                    if freq.keys.contains(word) {
                        let c = freq[word] ?? 0
                        freq[word] = c + 1
                    } else {
                        freq[word] = 1
                    }
                }
            }
            freqSpace.put(freq)
        }

        let extractedWords = extractWords(filePath: filePath)

        extractedWords.forEach {
            wordSpace.put($0)
        }

        Task.detached {
            await processWords()
            var res: [String: Int] = [:]
            while !freqSpace.queue.isEmpty {
                let freq = freqSpace.get()
                freq.forEach { (key: String, value: Int) in
                    let count = (res[key] ?? 0) + value
                    res[key] = count
                }
            }

            let sortedFreq = sortFreq(wordFreqs: res)
            printAll(elements: top25(wordPairs: sortedFreq))
            exit(EXIT_SUCCESS)
        }
        RunLoop.main.run()
    }
}

Thirty.instance.run()