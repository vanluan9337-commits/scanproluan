import SwiftUI
import VisionKit
import PDFKit
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - Camera quét tài liệu (tự nhận diện cạnh + nắn phẳng phối cảnh)
struct ScannerView: UIViewControllerRepresentable {
    var onFinish: ([UIImage]) -> Void
    var onCancel: () -> Void

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = context.coordinator
        return vc
    }
    func updateUIViewController(_ vc: VNDocumentCameraViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let p: ScannerView
        init(_ p: ScannerView) { self.p = p }
        func documentCameraViewController(_ c: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            p.onFinish((0..<scan.pageCount).map { scan.imageOfPage(at: $0) })
        }
        func documentCameraViewControllerDidCancel(_ c: VNDocumentCameraViewController) { p.onCancel() }
        func documentCameraViewController(_ c: VNDocumentCameraViewController, didFailWithError e: Error) { p.onCancel() }
    }
}

// MARK: - Làm trắng nền như máy scan
enum Enhancer {
    enum Mode: String, CaseIterable { case color = "Màu", gray = "Xám", bw = "Đen trắng", original = "Gốc" }
    static let ctx = CIContext()

    static func process(_ img: UIImage, mode: Mode) -> UIImage {
        guard mode != .original, let ci = CIImage(image: img) else { return img }
        let ext = ci.extent
        // Ước lượng ánh sáng nền bằng blur lớn, rồi chia ảnh cho nền => nền thành trắng, chữ giữ nguyên
        let blur = ci.clampedToExtent()
            .applyingGaussianBlur(sigma: max(ext.width, ext.height) / 40).cropped(to: ext)
        let div = CIFilter.divideBlendMode()
        div.inputImage = blur
        div.backgroundImage = ci
        var out = div.outputImage ?? ci

        let cc = CIFilter.colorControls()
        cc.inputImage = out
        switch mode {
        case .color: cc.saturation = 1.1; cc.contrast = 1.15
        case .gray:  cc.saturation = 0;   cc.contrast = 1.3
        default:     cc.saturation = 0;   cc.contrast = 2.0; cc.brightness = -0.05
        }
        out = cc.outputImage ?? out
        guard let cg = ctx.createCGImage(out, from: ext) else { return img }
        return UIImage(cgImage: cg, scale: img.scale, orientation: img.imageOrientation)
    }
}

// MARK: - Lưu trữ PDF
enum PDFStore {
    static var dir: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] }

    static func list() -> [URL] {
        let urls = (try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.contentModificationDateKey])) ?? []
        return urls.filter { $0.pathExtension.lowercased() == "pdf" }.sorted {
            let a = (try? $0.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            let b = (try? $1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            return a > b
        }
    }

    @discardableResult
    static func save(_ images: [UIImage], mode: Enhancer.Mode) -> URL? {
        let pdf = PDFDocument()
        for (i, img) in images.enumerated() {
            if let page = PDFPage(image: Enhancer.process(img, mode: mode)) { pdf.insert(page, at: i) }
        }
        guard pdf.pageCount > 0 else { return nil }
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd HH.mm.ss"
        let url = dir.appendingPathComponent("Scan \(f.string(from: Date())).pdf")
        return pdf.write(to: url) ? url : nil
    }
}

struct PDFPreview: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> PDFView {
        let v = PDFView(); v.autoScales = true; v.document = PDFDocument(url: url); return v
    }
    func updateUIView(_ v: PDFView, context: Context) {}
}
