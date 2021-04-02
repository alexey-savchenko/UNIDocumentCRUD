// Generated using Sourcery 1.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import UIKit
import UNILibCore
import UNIScanLib

public extension CustomFolder {
  enum lens {
    public static let creationDate = Lens<CustomFolder, Date>(
      get: { $0.creationDate },
      set: { part in 
        { whole in
          CustomFolder.init(creationDate: part, updateDate: whole.updateDate, name: whole.name, id: whole.id, parentFolderID: whole.parentFolderID, contentsCount: whole.contentsCount)
        }
      }
    )
    public static let updateDate = Lens<CustomFolder, Date>(
      get: { $0.updateDate },
      set: { part in 
        { whole in
          CustomFolder.init(creationDate: whole.creationDate, updateDate: part, name: whole.name, id: whole.id, parentFolderID: whole.parentFolderID, contentsCount: whole.contentsCount)
        }
      }
    )
    public static let name = Lens<CustomFolder, String>(
      get: { $0.name },
      set: { part in 
        { whole in
          CustomFolder.init(creationDate: whole.creationDate, updateDate: whole.updateDate, name: part, id: whole.id, parentFolderID: whole.parentFolderID, contentsCount: whole.contentsCount)
        }
      }
    )
    public static let id = Lens<CustomFolder, UUID>(
      get: { $0.id },
      set: { part in 
        { whole in
          CustomFolder.init(creationDate: whole.creationDate, updateDate: whole.updateDate, name: whole.name, id: part, parentFolderID: whole.parentFolderID, contentsCount: whole.contentsCount)
        }
      }
    )
    public static let parentFolderID = Lens<CustomFolder, UUID>(
      get: { $0.parentFolderID },
      set: { part in 
        { whole in
          CustomFolder.init(creationDate: whole.creationDate, updateDate: whole.updateDate, name: whole.name, id: whole.id, parentFolderID: part, contentsCount: whole.contentsCount)
        }
      }
    )
    public static let contentsCount = Lens<CustomFolder, Int>(
      get: { $0.contentsCount },
      set: { part in 
        { whole in
          CustomFolder.init(creationDate: whole.creationDate, updateDate: whole.updateDate, name: whole.name, id: whole.id, parentFolderID: whole.parentFolderID, contentsCount: part)
        }
      }
    )
  }
}
public extension ImageSettings {
  enum lens {
    public static let quad = Lens<ImageSettings, Quadrilateral>(
      get: { $0.quad },
      set: { part in 
        { whole in
          ImageSettings.init(quad: part, rotationDegrees: whole.rotationDegrees, colorFilter: whole.colorFilter, contrast: whole.contrast, brightness: whole.brightness)
        }
      }
    )
    public static let rotationDegrees = Lens<ImageSettings, CGFloat>(
      get: { $0.rotationDegrees },
      set: { part in 
        { whole in
          ImageSettings.init(quad: whole.quad, rotationDegrees: part, colorFilter: whole.colorFilter, contrast: whole.contrast, brightness: whole.brightness)
        }
      }
    )
    public static let colorFilter = Lens<ImageSettings, ColorFilter>(
      get: { $0.colorFilter },
      set: { part in 
        { whole in
          ImageSettings.init(quad: whole.quad, rotationDegrees: whole.rotationDegrees, colorFilter: part, contrast: whole.contrast, brightness: whole.brightness)
        }
      }
    )
    public static let contrast = Lens<ImageSettings, Float>(
      get: { $0.contrast },
      set: { part in 
        { whole in
          ImageSettings.init(quad: whole.quad, rotationDegrees: whole.rotationDegrees, colorFilter: whole.colorFilter, contrast: part, brightness: whole.brightness)
        }
      }
    )
    public static let brightness = Lens<ImageSettings, Float>(
      get: { $0.brightness },
      set: { part in 
        { whole in
          ImageSettings.init(quad: whole.quad, rotationDegrees: whole.rotationDegrees, colorFilter: whole.colorFilter, contrast: whole.contrast, brightness: part)
        }
      }
    )
  }
}
public extension ScanPage {
  enum lens {
    public static let id = Lens<ScanPage, UUID>(
      get: { $0.id },
      set: { part in 
        { whole in
          ScanPage.init(id: part, settings: whole.settings, attachments: whole.attachments, cachedOcr: whole.cachedOcr)
        }
      }
    )
    public static let settings = Lens<ScanPage, ImageSettings>(
      get: { $0.settings },
      set: { part in 
        { whole in
          ScanPage.init(id: whole.id, settings: part, attachments: whole.attachments, cachedOcr: whole.cachedOcr)
        }
      }
    )
    public static let attachments = Lens<ScanPage, [Attachment]>(
      get: { $0.attachments },
      set: { part in 
        { whole in
          ScanPage.init(id: whole.id, settings: whole.settings, attachments: part, cachedOcr: whole.cachedOcr)
        }
      }
    )
    public static let cachedOcr = Lens<ScanPage, TextDocument?>(
      get: { $0.cachedOcr },
      set: { part in 
        { whole in
          ScanPage.init(id: whole.id, settings: whole.settings, attachments: whole.attachments, cachedOcr: part)
        }
      }
    )
  }
}
public extension ScannedDocument {
  enum lens {
    public static let id = Lens<ScannedDocument, UUID>(
      get: { $0.id },
      set: { part in 
        { whole in
          ScannedDocument.init(id: part, creationDate: whole.creationDate, updateDate: whole.updateDate, name: whole.name, pages: whole.pages, parentFolderID: whole.parentFolderID)
        }
      }
    )
    public static let creationDate = Lens<ScannedDocument, Date>(
      get: { $0.creationDate },
      set: { part in 
        { whole in
          ScannedDocument.init(id: whole.id, creationDate: part, updateDate: whole.updateDate, name: whole.name, pages: whole.pages, parentFolderID: whole.parentFolderID)
        }
      }
    )
    public static let updateDate = Lens<ScannedDocument, Date>(
      get: { $0.updateDate },
      set: { part in 
        { whole in
          ScannedDocument.init(id: whole.id, creationDate: whole.creationDate, updateDate: part, name: whole.name, pages: whole.pages, parentFolderID: whole.parentFolderID)
        }
      }
    )
    public static let name = Lens<ScannedDocument, String>(
      get: { $0.name },
      set: { part in 
        { whole in
          ScannedDocument.init(id: whole.id, creationDate: whole.creationDate, updateDate: whole.updateDate, name: part, pages: whole.pages, parentFolderID: whole.parentFolderID)
        }
      }
    )
    public static let pages = Lens<ScannedDocument, [ScanPage]>(
      get: { $0.pages },
      set: { part in 
        { whole in
          ScannedDocument.init(id: whole.id, creationDate: whole.creationDate, updateDate: whole.updateDate, name: whole.name, pages: part, parentFolderID: whole.parentFolderID)
        }
      }
    )
    public static let parentFolderID = Lens<ScannedDocument, UUID>(
      get: { $0.parentFolderID },
      set: { part in 
        { whole in
          ScannedDocument.init(id: whole.id, creationDate: whole.creationDate, updateDate: whole.updateDate, name: whole.name, pages: whole.pages, parentFolderID: part)
        }
      }
    )
  }
}
public extension SignatureAttachment {
  enum lens {
    public static let id = Lens<SignatureAttachment, UUID>(
      get: { $0.id },
      set: { part in 
        { whole in
          SignatureAttachment.init(id: part, positioning: whole.positioning)
        }
      }
    )
    public static let positioning = Lens<SignatureAttachment, AttachmentPositioning>(
      get: { $0.positioning },
      set: { part in 
        { whole in
          SignatureAttachment.init(id: whole.id, positioning: part)
        }
      }
    )
  }
}
public extension TextDocument {
  enum lens {
    public static let id = Lens<TextDocument, UUID>(
      get: { $0.id },
      set: { part in 
        { whole in
          TextDocument.init(id: part, creationDate: whole.creationDate, updateDate: whole.updateDate, name: whole.name, textPages: whole.textPages, parentFolderID: whole.parentFolderID)
        }
      }
    )
    public static let creationDate = Lens<TextDocument, Date>(
      get: { $0.creationDate },
      set: { part in 
        { whole in
          TextDocument.init(id: whole.id, creationDate: part, updateDate: whole.updateDate, name: whole.name, textPages: whole.textPages, parentFolderID: whole.parentFolderID)
        }
      }
    )
    public static let updateDate = Lens<TextDocument, Date>(
      get: { $0.updateDate },
      set: { part in 
        { whole in
          TextDocument.init(id: whole.id, creationDate: whole.creationDate, updateDate: part, name: whole.name, textPages: whole.textPages, parentFolderID: whole.parentFolderID)
        }
      }
    )
    public static let name = Lens<TextDocument, String>(
      get: { $0.name },
      set: { part in 
        { whole in
          TextDocument.init(id: whole.id, creationDate: whole.creationDate, updateDate: whole.updateDate, name: part, textPages: whole.textPages, parentFolderID: whole.parentFolderID)
        }
      }
    )
    public static let textPages = Lens<TextDocument, [TextPage]>(
      get: { $0.textPages },
      set: { part in 
        { whole in
          TextDocument.init(id: whole.id, creationDate: whole.creationDate, updateDate: whole.updateDate, name: whole.name, textPages: part, parentFolderID: whole.parentFolderID)
        }
      }
    )
    public static let parentFolderID = Lens<TextDocument, UUID>(
      get: { $0.parentFolderID },
      set: { part in 
        { whole in
          TextDocument.init(id: whole.id, creationDate: whole.creationDate, updateDate: whole.updateDate, name: whole.name, textPages: whole.textPages, parentFolderID: part)
        }
      }
    )
  }
}
public extension TextPage {
  enum lens {
    public static let id = Lens<TextPage, UUID>(
      get: { $0.id },
      set: { part in 
        { whole in
          TextPage.init(id: part, contentData: whole.contentData)
        }
      }
    )
    public static let contentData = Lens<TextPage, Data>(
      get: { $0.contentData },
      set: { part in 
        { whole in
          TextPage.init(id: whole.id, contentData: part)
        }
      }
    )
  }
}
