import Foundation

protocol IFunction {
    func call(argument: Argument) -> Context<Argument>
}

protocol Argument {}
extension String: Argument {}
extension Array: Argument {}
extension Dictionary: Argument where Key == String, Value == Int {}

class Context<T> {
    var data: T

    init(data: T) {
        self.data = data
    }
}

class Monad {
    var context: Context<Argument>

    init(context: Context<Argument>) {
        self.context = context
    }

    func bind(bindableFunction: IFunction) -> Self {
        let context = bindableFunction.call(argument: self.context.data)
        self.context = context
        return self
    }

    func printContext() {
        print(context.data)
    }
}

class ReadFile: IFunction {
    func call(argument: Argument) -> Context<Argument> {
        guard
            let filePath = argument as? String,
            let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
            let contents = String(data: data, encoding: .utf8)
        else {
            return Context(data: argument)
        }
        return Context(data: contents)
    }
}

class FilterCharsAndNormalize: IFunction {
    func call(argument: Argument) -> Context<Argument> {
        guard let strData = argument as? String else { return Context(data: argument) }

        let argument: String = strData.map { c in
            return (c.isLetter || c.isNumber) ? c.lowercased() : " ";
        }.joined()

        return Context(data: argument)
    }
}

class Scan: IFunction {
    func call(argument: Argument) -> Context<Argument> {
        let result = (argument as? String)?.components(separatedBy: [" "]) ?? []
        return Context(data: result)
    }
}

class RemoveStopWords: IFunction {
    func call(argument: Argument) -> Context<Argument> {
        guard
            let data = try? Data(contentsOf: URL(fileURLWithPath: "../stop_words.txt")),
            let contents = String(data: data, encoding: .utf8),
            let argument = argument as? [String]
        else {
            return Context(data: argument)
        }
        var stopWords = contents.components(separatedBy: ",")
        let lowercaseLetters = "abcdefghijklmnopqrstuvwxyz".map { String($0) }
        stopWords.append(contentsOf: lowercaseLetters)

        let filteredWords = argument.filter { w in
            return !stopWords.contains(w) && w != ""
        }
        return Context(data: filteredWords)
    }
}

class Frequencies: IFunction {
    func call(argument: Argument) -> Context<Argument> {
        guard let words = argument as? [String] else {
            return Context(data: argument)
        }
        let dict = Dictionary(grouping: words) { $0 }.mapValues { $0.count }
        return Context(data: dict)
    }
}

class Top25Freq: IFunction {
    func call(argument: Argument) -> Context<Argument> {
        guard let wordFreqs = argument as? [String: Int] else {
            return Context(data: argument)
        }

        let top25 = wordFreqs
            .sorted { $0.1 > $1.1 }
            .prefix(upTo: 25)
            .reduce("") {
                return $0 + "\($1.0) - \($1.1)\n"
            }
        return Context(data: top25)
    }
}

Monad(context: .init(data: CommandLine.arguments.last!))
    .bind(bindableFunction: ReadFile())
    .bind(bindableFunction: FilterCharsAndNormalize())
    .bind(bindableFunction: Scan())
    .bind(bindableFunction: RemoveStopWords())
    .bind(bindableFunction: Frequencies())
    .bind(bindableFunction: Top25Freq())
    .printContext()