import SwiftUI

struct CharacterView: View {

    @ObservedObject var tracker: TypingSpeedTracker
    @ObservedObject var selection: CharacterSelectionModel
    @ObservedObject var sizeModel: SizeSelectionModel

    private var currentURL: URL? {
        guard let character = selection.current else { return nil }
        switch tracker.state {
        case .idle:    return character.idleURL
        case .running: return character.runURL
        }
    }

    /// Maps typing speed to playback rate. Idle is fixed at 0.7×; running
    /// scales with characters-per-second so the run cycle accelerates as the
    /// user types faster, capped to keep the animation watchable.
    private var currentRate: Double {
        switch tracker.state {
        case .idle:
            return 0.7
        case .running:
            let scaled = 0.8 + tracker.cps * 0.25
            return min(max(scaled, 0.8), 3.0)
        }
    }

    private var sideLength: CGFloat {
        CGFloat(sizeModel.current.rawValue)
    }

    var body: some View {
        ZStack {
            if let currentURL {
                ChromaKeyVideoView(videoURL: currentURL, rate: currentRate)
            } else {
                placeholder
            }
        }
        .frame(width: sideLength, height: sideLength)
        .contentShape(Rectangle())
        .contextMenu { menu }
    }

    @ViewBuilder
    private var menu: some View {
        if !selection.library.isEmpty {
            Section("Character") {
                ForEach(selection.library) { character in
                    Button {
                        selection.select(character)
                    } label: {
                        if character.id == selection.current?.id {
                            Label(character.displayName, systemImage: "checkmark")
                        } else {
                            Text(character.displayName)
                        }
                    }
                }
            }
        }
        Section("Size") {
            ForEach(CharacterSize.allCases) { size in
                Button {
                    sizeModel.select(size)
                } label: {
                    if size == sizeModel.current {
                        Label(size.displayName, systemImage: "checkmark")
                    } else {
                        Text(size.displayName)
                    }
                }
            }
        }
        Divider()
        Button("Quit KeyHigh") {
            NSApp.terminate(nil)
        }
    }

    private var placeholder: some View {
        VStack(spacing: 4) {
            Text("KeyHigh")
                .font(.system(size: 14, weight: .semibold))
            Text("drop <name>_idle.mov\nand <name>_run.mov\ninto Resources/")
                .font(.system(size: 10))
                .multilineTextAlignment(.center)
                .opacity(0.85)
        }
        .padding(10)
        .foregroundStyle(.white)
        .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 12))
    }
}
