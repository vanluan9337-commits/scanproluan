import SwiftUI

struct DocsView: View {
    @State private var files: [URL] = []
    @State private var showScanner = false
    @State private var busy = false
    @AppStorage("mode") private var modeRaw = Enhancer.Mode.color.rawValue
    private var mode: Enhancer.Mode { Enhancer.Mode(rawValue: modeRaw) ?? .color }

    var body: some View {
        NavigationStack {
            List {
                ForEach(files, id: \.self) { url in
                    NavigationLink {
                        PDFPreview(url: url)
                            .navigationTitle(url.deletingPathExtension().lastPathComponent)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar { ToolbarItem(placement: .topBarTrailing) { ShareLink(item: url) } }
                    } label: {
                        Label(url.deletingPathExtension().lastPathComponent, systemImage: "doc.richtext")
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            try? FileManager.default.removeItem(at: url); reload()
                        } label: { Label("Xoá", systemImage: "trash") }
                    }
                    .swipeActions(edge: .leading) {
                        ShareLink(item: url) { Label("Chia sẻ", systemImage: "square.and.arrow.up") }
                    }
                }
            }
            .overlay {
                if files.isEmpty {
                    ContentUnavailableView("Chưa có tài liệu", systemImage: "doc.viewfinder",
                                           description: Text("Nhấn nút Quét để bắt đầu"))
                }
                if busy { ProgressView("Đang xử lý…").padding().background(.regularMaterial, in: .rect(cornerRadius: 12)) }
            }
            .navigationTitle("Tài liệu")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Chế độ", selection: $modeRaw) {
                            ForEach(Enhancer.Mode.allCases, id: \.rawValue) { Text($0.rawValue).tag($0.rawValue) }
                        }
                    } label: { Label("Chế độ: \(mode.rawValue)", systemImage: "slider.horizontal.3") }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showScanner = true } label: { Label("Quét", systemImage: "camera.viewfinder") }
                }
            }
            .fullScreenCover(isPresented: $showScanner) {
                ScannerView(onFinish: { imgs in showScanner = false; save(imgs) },
                            onCancel: { showScanner = false })
                    .ignoresSafeArea()
            }
            .onAppear(perform: reload)
        }
    }

    private func reload() { files = PDFStore.list() }

    private func save(_ images: [UIImage]) {
        busy = true
        let m = mode
        Task.detached {
            PDFStore.save(images, mode: m)
            await MainActor.run { busy = false; reload() }
        }
    }
}
