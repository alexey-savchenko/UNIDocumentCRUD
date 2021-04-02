//
//  File.swift
//
//
//  Created by Alexey Savchenko on 01.04.2021.
//

import Foundation
import CoreGraphics
import UNILibCore
import UNIScanLib

/// sourcery: prism
public enum AttachmentPositioning: Hashable, Codable {
  case indefinite
  case defined(transform: CGAffineTransform)

  public func hash(into hasher: inout Hasher) {
    switch self {
    case .indefinite:
      hasher.combine(0)
    case .defined(let transform):
      hasher.combine(transform)
    }
  }

  private enum CodingKeys: String, CodingKey {
    case indefinite
    case defined
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let _ = try? container.decodeIfPresent(Int.self, forKey: .indefinite) {
      self = .indefinite
    } else if let transform = try? container.decodeIfPresent(
      CGAffineTransform.self,
      forKey: .defined
    ) {
      self = .defined(transform: transform)
    } else {
      fatalError()
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .defined(let transform):
      try container.encode(transform, forKey: .defined)
    case .indefinite:
      try container.encode(0, forKey: .indefinite)
    }
  }
}

/// sourcery: lens
public struct SignatureAttachment: Hashable, Codable, Identifiable {
  public init(id: UUID, positioning: AttachmentPositioning) {
    self.id = id
    self.positioning = positioning
  }

  public let id: UUID
  public let positioning: AttachmentPositioning
}

/// sourcery: prism
public enum Attachment: Hashable, Identifiable {
  case signature(signature: SignatureAttachment)

  public var id: UUID {
    switch self {
    case .signature(let signature):
      return signature.id
    }
  }
}

extension Attachment: Codable {
  private enum CodingKeys: String, CodingKey {
    case signature
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let signature = try? container
      .decodeIfPresent(SignatureAttachment.self, forKey: .signature) {
      self = .signature(signature: signature)
    } else {
      fatalError()
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .signature(let signature):
      try container.encode(signature, forKey: .signature)
    }
  }
}

/// sourcery: lens
public struct TextPage: Codable, Hashable, Identifiable {
  public init(id: UUID, contentData: Data) {
    self.id = id
    self.contentData = contentData
  }

  public let id: UUID
  public let contentData: Data
}

/// sourcery: lens
public struct TextDocument: Codable, Hashable, Identifiable {
  public init(
    id: UUID,
    creationDate: Date,
    updateDate: Date,
    name: String,
    textPages: [TextPage],
    parentFolderID: UUID
  ) {
    self.id = id
    self.creationDate = creationDate
    self.updateDate = updateDate
    self.name = name
    self.textPages = textPages
    self.parentFolderID = parentFolderID
  }

  public let id: UUID
  public let creationDate: Date
  public let updateDate: Date
  public let name: String
  public let textPages: [TextPage]
  let parentFolderID: UUID
}

/// sourcery: lens
public struct ImageSettings: Hashable, Codable {
  public init(
    quad: Quadrilateral,
    rotationDegrees: CGFloat,
    colorFilter: ColorFilter,
    contrast: Float,
    brightness: Float
  ) {
    self.quad = quad
    self.rotationDegrees = rotationDegrees
    self.colorFilter = colorFilter
    self.contrast = contrast
    self.brightness = brightness
  }

  public let quad: Quadrilateral
  public let rotationDegrees: CGFloat
  public let colorFilter: ColorFilter
  public let contrast: Float
  public let brightness: Float
}

public extension ImageSettings {
  static let brightnessScale: ClosedRange<Float> = -1 ... 1
  static let contrastScale: ClosedRange<Float> = 0.5 ... 1.5
  static let uiScale: ClosedRange<Float> = -100 ... 100

  init(quad: Quadrilateral) {
    self.quad = quad
    self.rotationDegrees = 0
    self.colorFilter = .none
    self.contrast = Self.contrastScale.middle
    self.brightness = Self.brightnessScale.middle
  }
}

public enum ColorFilter: String, Hashable, Codable, CaseIterable {
  case none
  case contrast
  case blackWhite
  case grayScale
}

/// sourcery: lens
public struct ScanPage: Codable, Hashable, Identifiable {
  public init(
    id: UUID,
    settings: ImageSettings,
    attachments: [Attachment],
    cachedOcr: TextDocument?
  ) {
    self.id = id
    self.settings = settings
    self.attachments = attachments
    self.cachedOcr = cachedOcr
  }

  public let id: UUID
  public let settings: ImageSettings
  public let attachments: [Attachment]
  public let cachedOcr: TextDocument?
}

/// sourcery: lens
public struct ScannedDocument: Codable, Hashable, Identifiable {
  public init(
    id: UUID,
    creationDate: Date,
    updateDate: Date,
    name: String,
    pages: [ScanPage],
    parentFolderID: UUID
  ) {
    self.id = id
    self.creationDate = creationDate
    self.updateDate = updateDate
    self.name = name
    self.pages = pages
    self.parentFolderID = parentFolderID
  }

  public let id: UUID
  public let creationDate: Date
  public let updateDate: Date
  public let name: String
  public let pages: [ScanPage]
  public let parentFolderID: UUID
}

/// sourcery: prism
public enum Folder {
  case root
  case custom(value: CustomFolder)
  
  public var id: UUID {
    switch self {
    case .custom(let value): return value.id
    case .root: return Constants.rootFolderID
    }
  }
}

/// sourcery: lens
public struct CustomFolder: Codable, Hashable, Identifiable {
  public init(
    creationDate: Date,
    updateDate: Date,
    name: String,
    id: UUID,
    parentFolderID: UUID,
    contentsCount: Int
  ) {
    self.creationDate = creationDate
    self.updateDate = updateDate
    self.name = name
    self.id = id
    self.parentFolderID = parentFolderID
    self.contentsCount = contentsCount
  }

  public let creationDate: Date
  public let updateDate: Date
  public let name: String
  public let id: UUID
  public let parentFolderID: UUID
  public let contentsCount: Int
}

/// sourcery: prism
public enum DocumentItem: Hashable, Equatable, Identifiable {
  case scan(item: ScannedDocument)
  case text(item: TextDocument)
  case folder(item: CustomFolder)

  public var id: UUID {
    switch self {
    case .folder(let item): return item.id
    case .scan(let item): return item.id
    case .text(let item): return item.id
    }
  }

  var parentFolderID: UUID {
    switch self {
    case .folder(let item): return item.parentFolderID
    case .scan(let item): return item.parentFolderID
    case .text(let item): return item.parentFolderID
    }
  }

  var name: String {
    switch self {
    case .folder(let item): return item.name
    case .scan(let item): return item.name
    case .text(let item): return item.name
    }
  }

  var updateDate: Date {
    switch self {
    case .folder(let item): return item.updateDate
    case .scan(let item): return item.updateDate
    case .text(let item): return item.updateDate
    }
  }

  var creationDate: Date {
    switch self {
    case .folder(let item): return item.creationDate
    case .scan(let item): return item.creationDate
    case .text(let item): return item.creationDate
    }
  }
}

extension DocumentItem: Codable {
  public struct CodingError: Error {}

  private enum CodingKeys: String, CodingKey {
    case scan
    case text
    case folder
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let scan = try? container.decode(ScannedDocument.self, forKey: .scan) {
      self = .scan(item: scan)
    } else if let textDoc = try? container.decode(TextDocument.self, forKey: .text) {
      self = .text(item: textDoc)
    } else if let folder = try? container.decode(CustomFolder.self, forKey: .folder) {
      self = .folder(item: folder)
    } else {
      throw CodingError()
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .folder(let item): try container.encode(item, forKey: .folder)
    case .scan(let item): try container.encode(item, forKey: .scan)
    case .text(let item): try container.encode(item, forKey: .text)
    }
  }
}
