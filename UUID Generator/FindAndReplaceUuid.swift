//
//  FindAndReplaceUuid.swift
//  UUID Generator
//
//  Created by Thomas L Moore on 1/19/19.
//  Copyright © 2019 Thomas Moore. All rights reserved.
//

import Foundation
import XcodeKit

class FindAndReplaceUuid: NSObject, XCSourceEditorCommand {

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        let selections = invocation.buffer.selections
        let lines = invocation.buffer.lines
        guard selections.count > 0 else {
            completionHandler(nil)
            return
        }

        guard let regex = try? NSRegularExpression(pattern: "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}", options: []) else {
            completionHandler(nil)
            return
        }

        let matchArray = lines.reduce([XCSourceTextRange]()) { (matches, line) -> [XCSourceTextRange] in
            var newMatches = matches
            let regexMatches = regex.matches(in: line as! String, options: [], range: NSRange(location: 0, length: (line as! String).count))
            if regexMatches.count > 0 {
                let lineIndex = lines.index(of: line)
                regexMatches.forEach({ (result) in
                    newMatches.append(XCSourceTextRange(start: XCSourceTextPosition(line: lineIndex,
                                                                                    column: result.range.location),
                                                        end: XCSourceTextPosition(line: lineIndex,
                                                                                  column: result.range.location + result.range.length)))
                })

            }
            return newMatches
        }

        var finalSelections = [XCSourceTextRange]()
        selections.forEach { (selection) in
            if let range = firstRange(afterSelection: selection as! XCSourceTextRange, proposedSelections: matchArray) {
                let location = finalSelections.firstIndex(of: range)
                if location == nil {
                    finalSelections.append(range)
                }
            }
        }
        if finalSelections.count > 0 {
            invocation.buffer.selections.removeAllObjects()
            invocation.buffer.selections.addObjects(from: finalSelections)
        }
        completionHandler(nil)
    }

    private func firstRange(afterSelection: XCSourceTextRange, proposedSelections: [XCSourceTextRange]) -> XCSourceTextRange? {
        return proposedSelections.reduce([XCSourceTextRange](), { (ranges, newRange) -> [XCSourceTextRange] in
            var newRanges = ranges
            if newRange.beginsAfter(range: afterSelection) {
                newRanges.append(newRange)
            }
            return newRanges
        }).first
    }
}

extension XCSourceTextRange {
    func beginsAfter(range: XCSourceTextRange) -> Bool {
        if range.start.line < self.start.line { return true }
        if range.start.line == self.start.line &&
            range.start.column <= self.start.column { return true }
        return false
    }

    func beginsBefore(range: XCSourceTextRange) -> Bool {
        if range.start.line > self.start.line { return true }
        if range.start.line == self.start.line &&
            range.start.column > self.start.column { return true }
        return false
    }
}
