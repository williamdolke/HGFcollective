//
//  LogFileHandler.swift
//  HGFcollective
//
//  Created by William Dolke on 19/10/2023.
//

import Foundation
import Logging

class LogFileHandler: LogHandler {
    var metadata: Logging.Logger.Metadata = [:]
    var logLevel: Logger.Level = .info
    private var logFileURL: URL?
    private var fileHandle: FileHandle?

    init(logFileURL: URL) {
        self.logFileURL = logFileURL

        FileManager.default.createFile(atPath: logFileURL.path, contents: nil, attributes: nil)

        if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
            self.fileHandle = fileHandle
            self.fileHandle?.seekToEndOfFile()
        }
    }

    subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return metadata[metadataKey]
        }
        set(newValue) {
            metadata[metadataKey] = newValue
        }
    }

    func log(level: Logger.Level,
             message: Logger.Message,
             metadata: Logger.Metadata?,
             file: String,
             function: String,
             line: UInt) {
        let timestamp = Date.now
        let logMessage = "\(timestamp): \(level): \(message)"
        guard let data = "\(logMessage)\n".data(using: .utf8) else { return }

        fileHandle?.write(data)
    }
}

extension LoggingSystem {
    static func bootstrapLogFile(logFileURL: URL) {
        let logHandler = LogFileHandler(logFileURL: logFileURL)
        LoggingSystem.bootstrap { _ in
            logHandler
        }
    }
}
