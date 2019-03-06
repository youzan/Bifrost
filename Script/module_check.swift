#!/usr/bin/env xcrun --sdk macosx swift
//script to do quality check for modules

import Foundation

func projectPath() -> String {
    let currentPath = FileManager.default.currentDirectoryPath
    let path = currentPath+"/.."
//    let path = "/Users/yangke/Code/Projects/RetailIOS"
    return path
}

extension String {
    public init(file: String) {
        if let data = FileManager.default.contents(atPath: file) {
            self = String(data:data, encoding: String.Encoding.utf8)!
        } else {
            self = ""
        }
    }
    
    func range(of:String, offset: String.Index) -> Range<String.Index>? {
        let range = offset ..< self.endIndex
        return self.range(of: of, options: String.CompareOptions(rawValue: 0), range: range, locale: nil)
    }
    
    func range(pattern:String, offset: String.Index) -> Range<String.Index>? {
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        if regex != nil {
            let offsetInt = self.distance(from: self.startIndex, to: offset)
            let range = regex!.rangeOfFirstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(offsetInt, self.characters.count - offsetInt))
            if range.location != NSNotFound {
                return self.index(self.startIndex, offsetBy: range.location)..<self.index(self.startIndex, offsetBy: range.location + range.length)
            }
        }
        return nil;
    }
    
    func range(pattern:String) -> Range<String.Index>? {
        return self.range(pattern: pattern, offset: self.startIndex)
    }
    
    mutating func remove(pattern:String) {
        while true {
            let range = self.range(pattern: pattern)
            if range != nil {
                self.removeSubrange(range!)
            } else {
                break;
            }
        }
    }
    
    mutating func removeImports() {
        self.remove(pattern: "#import.*\n")
    }
    
    mutating func removeBlankLines() {
        while true {
            let range = self.range(pattern: "\n[ ]*\n")
            if range != nil {
                self.replaceSubrange(range!, with: "\n")
            } else {
                break;
            }
        }
        //trip useless whitespaces
        while true {
            let range = self.range(pattern: "[ ]+\n")
            if range != nil {
                self.replaceSubrange(range!, with: "\n")
            } else {
                break;
            }
        }
    }
    
    func interfaceRange() -> Range<String.Index>? {
        let beginKey = "@interface"
        let endKey = "@end"
        if let beginRange = self.range(of: beginKey) {
            if let endRange = self.range(of: endKey) {
                return beginRange.lowerBound ..< endRange.upperBound
            }
        }
        return nil;
    }
    
    //ignore category
    func mainInterfaceRange() -> Range<String.Index>? {
        let beginKey = "@interface *.* *:.*"
        let endKey = "@end"
        if let beginRange = self.range(pattern: beginKey) {
            if let endRange = self.range(of: endKey, offset: beginRange.upperBound) {
                return beginRange.lowerBound ..< endRange.upperBound
            }
        }
        return nil
    }
    
    func implementationRange(className: String) -> Range<String.Index>? {
        let beginKey = "@implementation *\(className)"
        let endKey = "@end"
        if let beginRange = self.range(pattern: beginKey) {
            if let endRange = self.range(of: endKey, offset:beginRange.upperBound) {
                return beginRange.lowerBound ..< endRange.upperBound
            }
        }
        return nil;
    }
    
    func mainImplementationRange(className: String) -> Range<String.Index>? {
        let beginKey = "@implementation *\(className) *\n"
        let endKey = "@end"
        if let beginRange = self.range(pattern: beginKey) {
            if let endRange = self.range(of: endKey, offset:beginRange.upperBound) {
                return beginRange.lowerBound ..< endRange.upperBound
            }
        }
        return nil;
    }
    
    mutating func removeInterface() {
        while true {
            let range = self.interfaceRange()
            if range != nil {
                self.removeSubrange(range!)
            } else {
                break;
            }
        }
    }
    
    func commentRange() -> Range<String.Index>? {
        let commentPattern = "//.*\n"
        let commetPattern2Begin = "/+[*]"
        let commetPattern2End = "[*]/+"
        let strPattern = "\".*\""
        var offset = self.startIndex
        var range :Range<String.Index>? = nil
        while offset < self.endIndex {
            range = self.range(pattern: commentPattern, offset: offset)
            if range == nil {
                let beginRange = self.range(pattern:commetPattern2Begin)
                let endRange = self.range(pattern:commetPattern2End)
                if beginRange != nil && endRange != nil {
                    range = beginRange!.lowerBound ..< endRange!.upperBound
                }
            }
            if range != nil {
                // check whether the "//..." is inside a string
                while (true) {
                    let strRange = self.range(pattern: strPattern, offset: offset)
                    if strRange != nil {
                        if strRange!.upperBound <= range!.lowerBound {
                            offset = strRange!.upperBound
                            continue
                        } else if strRange!.lowerBound > range!.upperBound {
                            break
                        } else if strRange!.lowerBound < range!.lowerBound &&
                            strRange!.upperBound > range!.lowerBound {
                            range = nil
                            offset = strRange!.upperBound
                            break
                        } else {
                            break
                        }
                    } else {
                        break
                    }
                }
                if range != nil {
                    //valid
                    break;
                }
            } else {
                break
            }
        }
        return range;
    }
    
    mutating func removeComments() {
        while true {
            let range = self.commentRange()
            if range != nil {
                self.replaceSubrange(range!, with: "\n")
            } else {
                break;
            }
        }
        
    }
    
    mutating func removeWhitespaces() {
        self = self.replacingOccurrences(of: " ", with: "")
    }
    mutating func removeBreaks() {
        self = self.replacingOccurrences(of: "\n", with: "")
    }
    
    func enumRange() -> Range<String.Index>? {
        var range :Range<String.Index>? = nil
        if let beginRange = self.range(of: "typedef enum") {
            if let endRange = self.range(pattern: "\\}[ a-zA-Z0-9]+;", offset: beginRange.upperBound) {
                range = beginRange.lowerBound ..< endRange.upperBound
            }
        } else if let beginRange = self.range(of: "typedef NS_ENUM(") {
            if let endRange = self.range(pattern: "\\}[ ]*;", offset: beginRange.upperBound) {
                range = beginRange.lowerBound ..< endRange.upperBound
            }
        }
        return range;
    }
    
    //self must be a enmu string
    func enumName() -> String? {
        if (self.range(of: "NS_ENUM") != nil) {
            if let rangeBegin = self.range(of: ",") {
                if let rangeEnd = self.range(pattern: "\\)", offset: rangeBegin.upperBound) {
                    let range = rangeBegin.upperBound ..< rangeEnd.lowerBound
                    var name = self.substring(with: range)
                    name.remove(pattern: " ")
                    return name
                }
            }
        } else {
            if let rangeBegin = self.range(of: "}") {
                if let rangeEnd = self.range(pattern: ";", offset: rangeBegin.upperBound) {
                    let range = rangeBegin.upperBound ..< rangeEnd.lowerBound
                    var name = self.substring(with: range)
                    name.remove(pattern: " ")
                    return name
                }
            }
        }
        return nil
    }
    
    func staticStringRange() -> Range<String.Index>? {
        var range :Range<String.Index>? = nil
        if let beginRange = self.range(pattern: "static NSString.*@\"") {
            if let endRange = self.range(of: "\";", offset:beginRange.upperBound) {
                range = beginRange.lowerBound ..< endRange.upperBound
            }
        }
        return range;
    }
    
    func staticStringValue() -> String? {
        if let beginRange = self.range(pattern: "static NSString.*@\"") {
            if let endRange = self.range(of: "\";", offset:beginRange.upperBound) {
                let range = beginRange.upperBound ..< endRange.lowerBound
                return self.substring(with: range)
            }
        }
        return nil;
    }
    
    func macroStringRange() -> Range<String.Index>? {
        return self.range(pattern: "#define .*@\".*\"");
    }
    
    func macroStringValue() -> String? {
        if let valueRange = self.range(pattern: "\".*\"") {
            var valueStr = self.substring(with: valueRange)
            if valueStr.characters.count > 2 {
                valueStr.remove(at: valueStr.startIndex)
                valueStr.remove(at: valueStr.index(before: valueStr.endIndex))
                return valueStr
            }
        }
        return nil;
    }
    
    func referRange() -> Range<String.Index>? {
        return self.range(pattern: "// *ReferTo[(].*[)]")
    }
    
    func className() -> String? {
        if let range = self.range(pattern: "@interface *.*:") {
            var str = self.substring(with: range)
            str = str.replacingOccurrences(of: "@interface", with: "")
            str = str.replacingOccurrences(of: " ", with: "")
            str = str.replacingOccurrences(of: ":", with: "")
            return str
            
        }
        return nil
    }
    
    func lineNum(of: String) -> Int {
        if let range = self.range(of: of) {
            let subStr = self.substring(with: self.startIndex..<range.upperBound)
            let list = subStr.components(separatedBy: "\n")
            return list.count
        }
        return -1
    }
    
    func lineNum(pattern: String) -> Int {
        if let range = self.range(pattern: pattern) {
            let subStr = self.substring(with: self.startIndex..<range.upperBound)
            let list = subStr.components(separatedBy: "\n")
            return list.count
        }
        return -1
    }
    
    func version() -> Version? {
        let range = self.range(pattern: "/// *< *v[0-9]+\\.[0-9]*\\.?[0-9]* *>") //sample: ///<v1.0>
        if (range != nil) {
            var str = self.substring(with: range!)
            str.remove(pattern: "///.*v")
            str.remove(pattern: " *>.*")
            let list = str.components(separatedBy: ".")
            if list.count >= 2 {
                let major = Int(list[0])
                let minor = Int(list[1])
                let version = Version()
                version.rawStr = str
                version.major = Int(major!)
                version.minor = Int(minor!)
                return version
            }
        }
        return nil
    }
}

func allModuleServiceFiles(path: String) -> [String] {
    let pattern = ".*ModuleService[.][h]"
    return allFiles(path: path, pattern: pattern)
}

func allFiles(path: String, pattern: String) -> [String] {
    let skipList = [".DS_Store", ".git", "Pods"]
    let manager = FileManager.default
    let allFileList = NSMutableArray()
    let contents = try? manager.contentsOfDirectory(atPath:path)
    if contents != nil {
        for content in contents! {
            var skip: Bool = false
            for skipFolder in skipList {
                if content.range(of:skipFolder) != nil  {
                    skip = true
                    break
                }
            }
            if skip {
                continue
            }
            let subPath = path + "/" + content
            var isDir: ObjCBool = ObjCBool(false)
            manager.fileExists(atPath: subPath, isDirectory: &isDir)
            if isDir.boolValue {
                let subContents = allFiles(path:subPath, pattern:pattern)
                allFileList.addObjects(from: subContents)
            } else {
                if subPath.range(pattern: pattern) != nil {
                    allFileList.add(subPath)
                }
            }
        }
    } else {
        //        print("There is no content under path " + path)
    }
    return allFileList as! [String]
}

func allMFiles(path: String) -> [String] {
    let pattern = ".*\\.m{1,2}$"
    return allFiles(path: path, pattern: pattern)
}

func allHFiles(path: String) -> [String] {
    let pattern = ".*\\.h$"
    return allFiles(path: path, pattern: pattern)
}

func allModuleServiceInfo(path: String) -> [String: ModuleServiceInfo] {
    let files = allModuleServiceFiles(path:path)
    var infoDict = [String: ModuleServiceInfo]()
    for file in files {
        let url = URL(string:file)
        let name = url?.lastPathComponent
        let path = file.replacingOccurrences(of: (name)!, with: "")
        var info = infoDict[name!]
        if info == nil {
            info = ModuleServiceInfo()
            infoDict[name!] = info
        }
        info?.name = name!
        let isRaw = path.range(of: "Dependence") == nil ? true : false;
        if isRaw {
            info?.rawFilePath = file
        } else {
            info?.otherFilePathList.add(file)
        }
    }
    return infoDict
}

func showWarning(file:String, line:Int, msg:String) {
    print("\(file):\(line): warning: Module Warning: \(msg)")
}

func showWarning(msg:String) {
    print(":: warning: Module Warning: \(msg)")
}


class ModuleServiceInfo {
    var name: String = ""
    var rawFilePath: String = ""
    var otherFilePathList: NSMutableArray = NSMutableArray()
}

class Version {
    //version str sample: major.minor, like 1.3
    var rawStr: String = ""
    var major: Int = 0
    var minor: Int = 0
}

func checkModuleServiceFiles(path: String) {
    let infoDict = allModuleServiceInfo(path: path);
    for (_, info) in infoDict {
        if info.rawFilePath.characters.count == 0 {
            for file in info.otherFilePathList {
                let msg = "Cannot find \(info.name)'s raw ModuleService file."
                showWarning(file:file as! String, line:0, msg:msg)
            }
        } else if info.otherFilePathList.count == 0 {
            print("Module‘s \(info.name) is not used by other modules.")
        } else {
            var rawContent = String(file:info.rawFilePath)
            let rawVersion = rawContent.version()
            var shouldCheckVersion = false
            if rawVersion != nil && rawVersion!.major > 0 {
                shouldCheckVersion = true
            }
            if shouldCheckVersion {
                for otherFile in info.otherFilePathList {
                    let copiedContent = String(file:otherFile as! String)
                    let version = copiedContent.version()
                    if version == nil {
                        let msg = "Lake of version info in this copied file, the latest version in raw file is " + rawVersion!.rawStr
                        showWarning(file: otherFile as! String, line: 0, msg: msg)
                    } else {
                        if version!.major != rawVersion?.major {
                            let msg = "Copied file is out of date. The latest version in is " + rawVersion!.rawStr
                            showWarning(file: otherFile as! String, line: 0, msg: msg)
                        }
                    }
                }
            } else {
                rawContent.removeImports()
                rawContent.removeComments()
                rawContent.removeBlankLines()
                for otherFile in info.otherFilePathList {
                    var copiedContent = String(file:otherFile as! String)
                    copiedContent.removeImports()
                    copiedContent.removeComments()
                    copiedContent.removeBlankLines()
                    if (copiedContent != rawContent) {
                        let msg = "Copied file is out of date"
                        showWarning(file: otherFile as! String, line: 0, msg: msg)
                    }
                }
            }
        }
    }
    print("all done")
}

func checkDuplicateMFiles(path: String) {
    //不应该存在重复的.m/.mm文件
    let allFileList = allMFiles(path: path)
    var dict = [String: String]()
    let skipList = ["YZAppDelegate.m", "main.m"]
    for file in allFileList {
        let url = URL(string:file)
        let name = url?.lastPathComponent
        if skipList.contains(name!) {
            continue
        }
        let existingFile = dict[name!]
        if existingFile != nil {
            let msg = "Found duplicate m file " + file + ", another existing file is " + existingFile!
            showWarning(file: file, line: 0, msg: msg)
        } else {
            dict[name!] = file
        }
    }
}

func checkDuplicateHFiles(path: String) {
    //不应该存在多余的.h文件（除了dependence module service）
    let allFileList = allHFiles(path: path)
    var dict = [String: String]()
    var moduleDict = [String: [String:String]]()
    let skipList = ["YZAppDelegate.h"]
    for file in allFileList {
        let url = URL(string:file)
        let name = url?.lastPathComponent
        if skipList.contains(name!) {
            continue
        }
        if name!.hasSuffix("ModuleService.h") {
            let range = file.range(pattern: "Modules/Retail.*/")
            if range == nil {
                let msg = "Incorrect location for module service: " + file;
                showWarning(file: file, line: 0, msg: msg)
                continue;
            } else {
                var str = file.substring(with: range!)
                str.remove(pattern: "Modules/Retail")
                str.remove(pattern: "/.*")
                let moduleName = str
                var dict = moduleDict[moduleName]
                if dict == nil  {
                    dict = [String:String]()
                    dict?[name!] = file
                    moduleDict[moduleName] = dict
                    continue
                }
                let existingFile = dict?[name!]
                if existingFile != nil {
                    let msg = "Found duplicate h file " + file + ", another existing file is " + existingFile!
                    showWarning(file: file, line: 0, msg: msg)
                } else {
                    dict?[name!] = file
                    moduleDict[moduleName] = dict
                }
            }
        } else {
            let existingFile = dict[name!]
            if existingFile != nil {
                let msg = "Found duplicate h file " + file + ", another existing file is " + existingFile!
                showWarning(file: file, line: 0, msg: msg)
            } else {
                dict[name!] = file
            }
        }
    }
}

func checkAll(){
    let startDate = Date()
    let path = projectPath()
    checkModuleServiceFiles(path: path) //check whether all module service files should be updated
    checkDuplicateMFiles(path: path)
    checkDuplicateHFiles(path: path)
    print("All done, total used time \(Date().timeIntervalSince(startDate))")
}


checkAll()

