
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

  let bag = DisposeBag()

  func items() -> [DocumentItem] {
    let storeURL = url(for: Directory.documents)
    let contentsPaths = (try? FileManager.default.contentsOfDirectory(atPath: storeURL.path)) ?? []
    let rawContents = contentsPaths
      .map { path in URL(fileURLWithPath: path) }
      .compactMap { url in try? Data(contentsOf: url) }
      .compactMap { data in try? JSONDecoder().decode(DocumentItem.self, from: data) }

    let rawFolders = rawContents.compactMap { $0.folder }
    let otherItems = rawContents.filter { $0.folder == nil }

    let folders = rawFolders
      .map { rawFolder -> Folder in
        let contentsCount = otherItems.filter { $0.parentFolderID == rawFolder.id }.count
        return Folder.lens.contentsCount.set(contentsCount)(rawFolder)
      }
      .map(DocumentItem.folder)
    return folders + otherItems
  }

  func contentsOf(_ folder: Folder) -> [DocumentItem] {
    return items().filter { $0.parentFolderID == folder.id }
  }

  func createFolder(
    name: String,
    parentFolderID: UUID
  ) -> Result<DocumentItem, CRUDService.Error> {
    let folder = Folder(
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

  func createTextDocument(
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

  func createPage(
    from image: UIImage
  ) -> Result<ScanPage, CRUDService.Error> {
    let page = ScanPage(
      id: UUID(),
      settings: ImageSettings(quad: .defaultQuad(for: image)),
      attachments: [],
      cachedOcr: nil
    )
    if let imageData = autoreleasepool(invoking: { image.jpegData(compressionQuality: 0.5) }) {
      let encodedPageData = try! JSONEncoder().encode(page)
      let pageURL = url(for: Directory.documents)
        .appendingPathComponent(page.id.uuidString)
        .appendingPathExtension("json")
      let resourceURL = url(for: Directory.resources)
        .appendingPathComponent(page.id.uuidString)
        .appendingPathExtension("jpg")
      do {
        try imageData.write(to: resourceURL)
        try encodedPageData.write(to: pageURL)

        return .success(page)
      } catch {
        return .failure(.other(error: error))
      }
    } else {
      return .failure(.cannotSaveImage)
    }
  }

  func createDocument(
    from pageImages: [UIImage],
    name: String,
    folder: Folder
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
        parentFolderID: folder.id
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

  func createDocument(
    from pages: [ScanPage],
    name: String,
    folder: Folder
  ) -> Result<DocumentItem, CRUDService.Error> {
    let document = ScannedDocument(
      id: UUID(),
      creationDate: Date(),
      updateDate: Date(),
      name: name,
      pages: pages,
      parentFolderID: folder.id
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

  func removePage(_ page: ScanPage) {
    let pageURL = url(for: .documents)
      .appendingPathComponent(page.id.uuidString)
      .appendingPathComponent("json")
    let picURL = url(for: .resources)
      .appendingPathComponent(page.id.uuidString)
      .appendingPathComponent("jpg")

    try? FileManager.default.removeItem(at: pageURL)
    try? FileManager.default.removeItem(at: picURL)
  }

  func deleteDocument(item: DocumentItem) {
    let rootDir = url(for: .documents)
    if case .folder(let folder) = item {
      let contents = contentsOf(folder)
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

  func update(item: DocumentItem) {
    let documentURL = url(for: .documents)
      .appendingPathComponent(item.id.uuidString)
      .appendingPathExtension("json")
    let encodedDocumentData = try! JSONEncoder().encode(item)
    try! encodedDocumentData.write(to: documentURL)
  }
}
