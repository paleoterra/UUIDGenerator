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
}

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        let selections = invocation.buffer.selections
        var lines = Array(invocation.buffer.lines)
        guard selections.count > 0 else {
            completionHandler(nil)
            return
        }

        selections.reversed().forEach { (selection) in

            guard let textSelection = selection as? XCSourceTextRange else {
                return
            }
            //get start and end positions
            let selectedLines = Array(lines[textSelection.start.line...textSelection.end.line])
            let newLine = replace(selectedLines: selectedLines,
                                  range: textSelection,
                                  replacementString: generatedUUID(invocation: invocation))
            lines.removeSubrange(textSelection.start.line...textSelection.end.line)
            lines.insert(newLine, at: textSelection.start.line)

        }
        invocation.buffer.lines.setArray(lines)


        completionHandler(nil)
    }

    func generatedUUID(invocation: XCSourceEditorCommandInvocation) -> String {
        var newUuid = NSUUID().uuidString
        if invocation.commandIdentifier == UUIDGenInvocation.generatelowercase.rawValue {
            newUuid = newUuid.lowercased()
        }
        return newUuid
    }

    func replace(selectedLines: [Any], range: XCSourceTextRange, replacementString: String) -> String {
        guard let firstLine = selectedLines.first as? String, let lastLine = selectedLines.last as? String else {
            return ""
        }
        var finalString = ""
        let firstLineEndIndex = firstLine.index(firstLine.startIndex, offsetBy: range.start.column - 1)
        finalString += String(firstLine[firstLine.startIndex...firstLineEndIndex])
        finalString += replacementString
        let lastLineStartIndex = lastLine.index(lastLine.startIndex, offsetBy: range.end.column)
        finalString += String(lastLine[lastLineStartIndex..<lastLine.endIndex])
        return finalString
    }
    
}

