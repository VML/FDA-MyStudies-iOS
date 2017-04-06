//
//  FileDownloadModel.swift
//  DownloadManager
//
//  Created by Surender Rathore on 2/24/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation

public enum TaskStatus: Int {
    case unknown, gettingInfo, downloading, paused, failed
    
    public func description() -> String {
        switch self {
        case .gettingInfo:
            return "GettingInfo"
        case .downloading:
            return "Downloading"
        case .paused:
            return "Paused"
        case .failed:
            return "Failed"
        default:
            return "Unknown"
        }
    }
}
class FileDownloadModel {
    
    open var fileName: String!
    open var fileURL: String!
    open var status: String = TaskStatus.gettingInfo.description()
    
    open var file: (size: Float, unit: String)?
    open var downloadedFile: (size: Float, unit: String)?
    
    open var remainingTime: (hours: Int, minutes: Int, seconds: Int)?
    
    open var speed: (speed: Float, unit: String)?
    
    open var progress: Float = 0
    
    open var task: URLSessionDownloadTask?
    
    open var startTime: Date?
    
    fileprivate(set) open var destinationPath: String = ""
    
    fileprivate convenience init(fileName: String, fileURL: String) {
        self.init()
        
        self.fileName = fileName
        self.fileURL = fileURL
    }
    
    convenience init(fileName: String, fileURL: String, destinationPath: String) {
        self.init(fileName: fileName, fileURL: fileURL)
        
        self.destinationPath = destinationPath
    }

}
