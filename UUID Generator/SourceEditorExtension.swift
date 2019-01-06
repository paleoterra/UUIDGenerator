//
//  SourceEditorExtension.swift
//  UUID Generator
//
//  Created by Thomas Moore on 1/6/19.
//  Copyright © 2019 Thomas Moore. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    
    /*
    func extensionDidFinishLaunching() {
        // If your extension needs to do any work at launch, implement this optional method.
    }
    */
    
    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        // If your extension needs to return a collection of command definitions that differs from those in its Info.plist, implement this optional property getter.
        return [[.classNameKey: "UUID_Generator.SourceEditorCommand",
                 .identifierKey: UUIDGenInvocation.generate.rawValue,
                 .nameKey: "UUID"],
                [.classNameKey: "UUID_Generator.SourceEditorCommand",
                 .identifierKey: UUIDGenInvocation.generatelowercase.rawValue,
                 .nameKey: "UUID (Lowercase)"]]
    }
    
}
