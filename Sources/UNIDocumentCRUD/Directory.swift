//
//  File.swift
//
//
//  Created by Alexey Savchenko on 01.04.2021.
//

import Foundation

public enum Directory: String, CaseIterable {
  case documents
  case resources
}

public func url(for directory: Directory) -> URL {
  let rootDocDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  return rootDocDir.appendingPathComponent(directory.rawValue)
}
