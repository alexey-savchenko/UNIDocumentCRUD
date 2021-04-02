
import CoreGraphics
import Foundation
import UNIScanLib
import UNILibCore
import UIKit
import RxSwift
import DeepDiff
import RxUNILib

public class CRUDService {
  public enum Error: Swift.Error {
    case cannotSaveImage
    case other(error: Swift.Error)
  }

  public init() {
    Directory.allCases.forEach { dir in
      var isDir = ObjCBool(true)
      let dirURL = url(for: dir)
      if !FileManager.default.fileExists(atPath: dirURL.path, isDirectory: &isDir) {
        try? FileManager.default.createDirectory(
          at: dirURL,
          withIntermediateDirectories: true,
          attributes: nil
        )
      }
    }
  }

  public func items() -> [DocumentItem] {
    let storeURL = url(for: Directory.documents)
    let contentsPaths = (try? FileManager.default.contentsOfDirectory(atPath: storeURL.path)) ?? []
    let rawContents = contentsPaths
      .map { path in URL(fileURLWithPath: path) }
      .compactMap { url in try? Data(contentsOf: url) }
      .compactMap { data in try? JSONDecoder().decode(DocumentItem.self, from: data) }

    let rawFolders = rawContents.compactMap(DocumentItem.prism.folder.tryGet)
    let otherItems = rawContents.filter { DocumentItem.prism.folder.tryGet($0) == nil }

    let folders = rawFolders
      .map { rawFolder -> CustomFolder in
        let contentsCount = otherItems.filter { $0.parentFolderID == rawFolder.id }.count
        return CustomFolder.lens.contentsCount.set(contentsCount)(rawFolder)
      }
      .map(DocumentItem.folder)
    return folders + otherItems
  }

  public func contentsOf(_ folder: Folder) -> [DocumentItem] {
    return items().filter { $0.parentFolderID == folder.id }
  }

  public func createFolder(
    name: String,
    parentFolderID: UUID
  ) -> Result<DocumentItem, CRUDService.Error> {
    let folder = CustomFolder(
      creationDate: Date(),
      updateDate: Date(),
      name: name,
      id: UUID(),
      parentFolderID: parentFolderID,
      contentsCount: 0
    )
    let boxed = DocumentItem.folder(item: folder)
    let folderURL = url(for: Directory.documents)
      .appendingPathComponent(folder.id.uuidString)
      .appendingPathExtension("json")

    do {
      let encoded = try JSONEncoder().encode(boxed)
      try encoded.write(to: folderURL)
      return .success(boxed)
    } catch {
      return .failure(.other(error: error))
    }
  }

  public func createTextDocument(
    from pages: [TextPage],
    name: String,
    parentFolderID: UUID
  ) -> Result<DocumentItem, CRUDService.Error> {
    let textDocument = TextDocument(
      id: UUID(),
      creationDate: Date(),
      updateDate: Date(),
      name: name,
      textPages: pages,
      parentFolderID: parentFolderID
    )
    let boxed = DocumentItem.text(item: textDocument)
    let documentURL = url(for: Directory.documents)
      .appendingPathComponent(textDocument.id.uuidString)
      .appendingPathExtension("json")
    do {
      let encoded = try JSONEncoder().encode(boxed)
      try encoded.write(to: documentURL)
      return .success(boxed)
    } catch {
      return .failure(.other(error: error))
    }
  }

  public func createPage(
    from image: UIImage
  ) -> Result<ScanPage, CRUDService.Error> {
    let page = ScanPage(
      id: UUID(),
      settings: ImageSettings(
        quad: Quadrilateral.defaultQuad(for: image).relativeToSize(image.size)
      ),
      attachments: [],
      cachedOcr: nil
    )
    if let imageData = autoreleasepool(invoking: { image.jpegData(compressionQuality: 0.5) }) {
      let resourceURL = url(for: Directory.resources)
        .appendingPathComponent(page.id.uuidString)
        .appendingPathExtension("jpg")
      do {
        try imageData.write(to: resourceURL)

        return .success(page)
      } catch {
        return .failure(.other(error: error))
      }
    } else {
      return .failure(.cannotSaveImage)
    }
  }

  public func createDocument(
    from pageImages: [UIImage],
    name: String,
    parentFolderID: UUID
  ) -> Result<DocumentItem, CRUDService.Error> {
    let pages = pageImages.map(createPage)

    do {
      let scanPages = try pages.map { try $0.get() }
      let document = ScannedDocument(
        id: UUID(),
        creationDate: Date(),
        updateDate: Date(),
        name: name,
        pages: scanPages,
        parentFolderID: parentFolderID
      )
      let boxed = DocumentItem.scan(item: document)
      let encodedDocumentData = try! JSONEncoder().encode(boxed)
      let documentURL = url(for: Directory.documents)
        .appendingPathComponent(document.id.uuidString)
        .appendingPathExtension("json")
      do {
        try encodedDocumentData.write(to: documentURL)
        return .success(boxed)
      } catch {
        return .failure(.other(error: error))
      }
    } catch {
      return .failure(.other(error: error))
    }
  }

  public func createDocument(
    from pages: [ScanPage],
    name: String,
    parentFolderID: UUID
  ) -> Result<DocumentItem, CRUDService.Error> {
    let document = ScannedDocument(
      id: UUID(),
      creationDate: Date(),
      updateDate: Date(),
      name: name,
      pages: pages,
      parentFolderID: parentFolderID
    )
    let boxed = DocumentItem.scan(item: document)

    do {
      let encodedDocumentData = try JSONEncoder().encode(boxed)
      let documentURL = url(for: Directory.documents)
        .appendingPathComponent(document.id.uuidString)
        .appendingPathExtension("json")
      try encodedDocumentData.write(to: documentURL)
      return .success(boxed)
    } catch {
      return .failure(.other(error: error))
    }
  }

  public func removePage(_ page: ScanPage) {
    let pageURL = url(for: .documents)
      .appendingPathComponent(page.id.uuidString)
      .appendingPathComponent("json")
    let picURL = url(for: .resources)
      .appendingPathComponent(page.id.uuidString)
      .appendingPathComponent("jpg")

    try? FileManager.default.removeItem(at: pageURL)
    try? FileManager.default.removeItem(at: picURL)
  }

  public func deleteDocument(item: DocumentItem) {
    let rootDir = url(for: .documents)
    if case .folder(let folder) = item {
      let contents = contentsOf(.custom(value: folder))
      contents.forEach(deleteDocument)
    }

    let itemUrl = rootDir
      .appendingPathComponent(item.id.uuidString)
      .appendingPathExtension("json")

    try? FileManager.default.removeItem(at: itemUrl)

    if case .scan(let scan) = item {
      scan.pages.forEach(removePage)
    }
  }

  public func update(item: DocumentItem) {
    let documentURL = url(for: .documents)
      .appendingPathComponent(item.id.uuidString)
      .appendingPathExtension("json")
    let encodedDocumentData = try! JSONEncoder().encode(item)
    try! encodedDocumentData.write(to: documentURL)
  }
}
