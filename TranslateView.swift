import SwiftUI
import PhotosUI
import Vision
import Translation

struct TranslateView: View {
    @State private var recognized = ""
    @State private var translated = ""
    @State private var target = "vi"
    @State private var config: TranslationSession.Configuration?
    @State private var showScanner = false
    @State private var picked: PhotosPickerItem?
    @State private var busy = false
    @State private var error: String?

    private let languages: [(code: String, name: String)] = [
        ("vi", "Tiếng Việt"), ("en", "English"), ("zh-Hans", "中文 (giản thể)"), ("ja", "日本語"),
        ("ko", "한국어"), ("fr", "Français"), ("de", "Deutsch"), ("es", "Español"),
        ("ru", "Русский"), ("th", "ไทย")
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Ảnh nguồn") {
                    Button { showScanner = true } label: { Label("Chụp bằng camera", systemImage: "camera") }
                    PhotosPicker(selection: $picked, matching: .images) { Label("Chọn ảnh từ thư viện", systemImage: "photo") }
                }
                Section("Dịch sang") {
                    Picker("Ngôn ngữ đích", selection: $target) {
                        ForEach(languages, id: \.code) { Text($0.name).tag($0.code) }
                    }
                    .onChange(of: target) { _, _ in startTranslate() }
                }
                Section("Văn bản nhận dạng (tự phát hiện ngôn ngữ)") {
                    TextEditor(text: $recognized).frame(minHeight: 120)
                    Button("Dịch lại", action: startTranslate).disabled(recognized.isEmpty)
                }
                Section("Bản dịch") {
                    if busy { ProgressView() }
                    Text(translated.isEmpty ? "—" : translated).textSelection(.enabled)
                    if !translated.isEmpty { ShareLink(item: translated) }
                    if let error { Text(error).foregroundStyle(.red).font(.footnote) }
                }
            }
            .navigationTitle("Dịch ảnh")
            .fullScreenCover(isPresented: $showScanner) {
                ScannerView(onFinish: { imgs in showScanner = false; Task { await run(imgs) } },
                            onCancel: { showScanner = false })
                    .ignoresSafeArea()
            }
            .onChange(of: picked) { _, item in
                guard let item else { return }
                Task {
                    if let d = try? await item.loadTransferable(type: Data.self), let img = UIImage(data: d) { await run([img]) }
                }
            }
            // Apple Translation: miễn phí, chạy trên máy, không cần API key
            .translationTask(config) { session in
                do {
                    let r = try await session.translate(recognized)
                    translated = r.targetText; error = nil
                } catch { self.error = "Không dịch được: \(error.localizedDescription)" }
                busy = false
            }
        }
    }

    private func run(_ images: [UIImage]) async {
        busy = true; error = nil; translated = ""
        var parts: [String] = []
        for img in images { parts.append(await OCR.recognize(img)) }
        recognized = parts.joined(separator: "\n\n")
        if recognized.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            busy = false; error = "Không nhận dạng được chữ trong ảnh."
        } else { startTranslate() }
    }

    private func startTranslate() {
        guard !recognized.isEmpty else { return }
        busy = true
        let t = Locale.Language(identifier: target)
        if config == nil { config = .init(source: nil, target: t) }
        else { config?.source = nil; config?.target = t; config?.invalidate() }
    }
}

enum OCR {
    static func recognize(_ image: UIImage) async -> String {
        guard let cg = image.cgImage else { return "" }
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        return await withCheckedContinuation { cont in
            DispatchQueue.global(qos: .userInitiated).async {
                let req = VNRecognizeTextRequest()
                req.recognitionLevel = .accurate
                req.automaticallyDetectsLanguage = true
                req.usesLanguageCorrection = true
                do {
                    try VNImageRequestHandler(cgImage: cg, orientation: orientation).perform([req])
                    let text = (req.results ?? []).compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
                    cont.resume(returning: text)
                } catch { cont.resume(returning: "") }
            }
        }
    }
}

extension CGImagePropertyOrientation {
    init(_ o: UIImage.Orientation) {
        switch o {
        case .up: self = .up; case .down: self = .down; case .left: self = .left; case .right: self = .right
        case .upMirrored: self = .upMirrored; case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored; case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
