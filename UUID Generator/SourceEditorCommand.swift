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
                                  replacementString: generatedUUID(invocation: invocation))
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

    func replace(selectedLines: [Any], range: XCSourceTextRange, replacementString: String) -> (String, NSRange) {
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
        return (finalString, NSRange(location: finalStringStartPosition, length: replacementString.count))
    }
    
}
