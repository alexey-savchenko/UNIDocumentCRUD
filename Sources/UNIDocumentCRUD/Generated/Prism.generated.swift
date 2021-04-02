// Generated using Sourcery 1.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import UIKit
import UNILibCore
import UNIScanLib




extension Attachment {
    public enum prism {
        public static let signature = Prism<Attachment,SignatureAttachment>(
            tryGet: { if case .signature(let value) = $0 { return value } else { return nil } },
            inject: { (x1) in .signature(signature:x1) })

    }
}



extension AttachmentPositioning {
    public enum prism {
        public static let indefinite = Prism<AttachmentPositioning, ()>(
            tryGet: { if case .indefinite = $0 { return () } else { return nil } },
            inject: { .indefinite })

        public static let defined = Prism<AttachmentPositioning,CGAffineTransform>(
            tryGet: { if case .defined(let value) = $0 { return value } else { return nil } },
            inject: { (x1) in .defined(transform:x1) })

    }
}



extension DocumentItem {
    public enum prism {
        public static let scan = Prism<DocumentItem,ScannedDocument>(
            tryGet: { if case .scan(let value) = $0 { return value } else { return nil } },
            inject: { (x1) in .scan(item:x1) })

        public static let text = Prism<DocumentItem,TextDocument>(
            tryGet: { if case .text(let value) = $0 { return value } else { return nil } },
            inject: { (x1) in .text(item:x1) })

        public static let folder = Prism<DocumentItem,CustomFolder>(
            tryGet: { if case .folder(let value) = $0 { return value } else { return nil } },
            inject: { (x1) in .folder(item:x1) })

    }
}



extension Folder {
    public enum prism {
        public static let root = Prism<Folder, ()>(
            tryGet: { if case .root = $0 { return () } else { return nil } },
            inject: { .root })

        public static let custom = Prism<Folder,CustomFolder>(
            tryGet: { if case .custom(let value) = $0 { return value } else { return nil } },
            inject: { (x1) in .custom(value:x1) })

    }
}


