//
//  SourceEditorCommand.swift
//  UUID Generator
//
//  Created by Thomas Moore on 1/6/19.
//  Copyright © 2019 Thomas Moore. All rights reserved.
//

import Foundation
import XcodeKit

enum UUIDGenInvocation: String {
    case generate = "com.paleoterra.uuidgenerator.uuid"
    case generatelowercase = "com.paleoterra.uuidgeneratorlowercase.uuid"
    case selectNextUuid = "com.paleoterra.uuidgeneratorselectnext.uuid"
}

class SourceEditorCommand: NSObject, XCSourceEditorCommand {

    static let tabRegex = try? NSRegularExpression.init(pattern: "[\t]", options: [])
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        let selections = invocation.buffer.selections
        let lines = invocation.buffer.lines
        guard selections.count > 0 else {
            completionHandler(nil)
            return
        }

        selections.reversed().forEach { (selection) in

            guard let textSelection = selection as? XCSourceTextRange else {
                return
            }
            let startLine = textSelection.start.line
            let endLine = textSelection.end.line
            let selectedLineRange = NSRange(location: startLine, length: endLine - startLine + 1)
            let selectedLines = lines.subarray(with: selectedLineRange)
            let (newLine, uuidrange) = replace(selectedLines: selectedLines,
                                               range: textSelection,
                                               replacementString: generatedUUID(invocation: invocation),
                                               tabWidth: invocation.buffer.tabWidth)
            lines.removeObjects(in: selectedLineRange)
            lines.insert(newLine, at: selectedLineRange.location)

            //replace selection
            invocation.buffer.selections.remove(selection)
            invocation.buffer.selections.add(XCSourceTextRange(start: XCSourceTextPosition(line: selectedLineRange.location, column: uuidrange.location),
                                                               end: XCSourceTextPosition(line: selectedLineRange.location, column: uuidrange.location + uuidrange.length)))
        }
        completionHandler(nil)
    }

    func generatedUUID(invocation: XCSourceEditorCommandInvocation) -> String {
        var newUuid = NSUUID().uuidString
        if invocation.commandIdentifier == UUIDGenInvocation.generatelowercase.rawValue {
            newUuid = newUuid.lowercased()
        }
        return newUuid
    }

    func replace(selectedLines: [Any], range: XCSourceTextRange, replacementString: String, tabWidth: Int) -> (String, NSRange) {
        guard let firstLine = selectedLines.first as? String, let lastLine = selectedLines.last as? String else {
            return ("", NSRange(location: 0, length: 0))
        }
        var finalString = ""
        let firstLineEndIndex = firstLine.index(firstLine.startIndex, offsetBy: range.start.column - 1)
        finalString += String(firstLine[firstLine.startIndex...firstLineEndIndex])
        let finalStringStartPosition = finalString.count
        finalString += replacementString
        let lastLineStartIndex = lastLine.index(lastLine.startIndex, offsetBy: range.end.column)
        finalString += String(lastLine[lastLineStartIndex..<lastLine.endIndex])
        let offset = checkTabOffset(line: finalString, column: finalStringStartPosition, tabWidth: tabWidth)
        return (finalString, NSRange(location: finalStringStartPosition + offset, length: replacementString.count))
    }

    //since columns != characters, we have to adjust position if tabs present
    func checkTabOffset(line: String, column: Int, tabWidth: Int) -> Int {
        guard let regex = SourceEditorCommand.tabRegex else { return 0 }
        let matches = regex.matches(in: line, options: [], range: NSRange(location: 0, length: line.count))
        var offset = matches.reduce(0, { (matches, result) -> Int in
            var count = matches
            let range = result.range
            if range.location < column {
                count += tabWidth
            }
            return count
        })
        if offset > 0 {
            offset -= 1
        }
        return offset

    }
    
}
