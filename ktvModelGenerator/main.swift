//
//  main.swift
//  ktvModelGenerator
//
//  Created by Alexander Babaev on 24.02.16.
//  Copyright © 2016 LonelyBytes. All rights reserved.
//

import Foundation
import Darwin

var sourcesPath = ""
var outputClassPath = ""
var outputFileName = "KTVModelExtensions.swift"

var skipArgument = false
var index = 0
for argument in Process.arguments {
    if skipArgument {
        skipArgument = false
        index += 1
        continue
    }

    switch argument.lowercaseString {
        case "-s":
            sourcesPath = Process.arguments[index + 1]
            skipArgument = true
        case "-o":
            outputClassPath = Process.arguments[index + 1]
            skipArgument = true

        default:
            if index != 0 {
                print("Unknown argument: \(argument)");
            }
    }

    index += 1
}

if sourcesPath.isEmpty || outputFileName.isEmpty || outputClassPath.isEmpty {
    print("Usage: ktvModelGenerator -s SourcesDirectory -o OutputExtensionsFileDirectory\n" +
          "Will return 1 if generation is OK or 0 otherwise")

    exit(0)
} else {
    sourcesPath = (sourcesPath as NSString).stringByExpandingTildeInPath
    outputClassPath = (outputClassPath as NSString).stringByExpandingTildeInPath

    let generator = KTVGenerator(pathToSearchForClasses:sourcesPath, pathToSaveGeneratedTo:outputClassPath)
    do {
        try generator.process()
    } catch {
        print("Error during generating of the parsers/serializers: \(error)")
    }

    exit(1)
}
