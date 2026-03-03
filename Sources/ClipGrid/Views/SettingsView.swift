import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    let backgroundColor: Binding<Color>
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(AppStrings.settingsTitle)
                .font(.title2)
                .fontWeight(.semibold)

            HStack {
                Stepper(AppStrings.columns(settings.columns), value: $settings.columns, in: 1...10)
                Stepper(AppStrings.rows(settings.rows), value: $settings.rows, in: 1...10)
            }

            HStack {
                VStack(alignment: .leading) {
                    Text(AppStrings.thumbnailWidth(Int(settings.thumbnailWidth)))
                    Slider(value: $settings.thumbnailWidth, in: 120...480, step: 10)
                }

                VStack(alignment: .leading) {
                    Text(AppStrings.thumbnailHeight(Int(settings.thumbnailHeight)))
                    Slider(value: $settings.thumbnailHeight, in: 90...320, step: 10)
                }
            }

            VStack(alignment: .leading) {
                Text(AppStrings.spacing(Int(settings.thumbnailSpacing)))
                Slider(value: $settings.thumbnailSpacing, in: 0...40, step: 1)
            }

            HStack {
                Picker(AppStrings.exportFormat, selection: $settings.exportFormat) {
                    ForEach(ExportFormat.allCases) { format in
                        Text(format.displayName).tag(format)
                    }
                }
                .pickerStyle(.segmented)

                ColorPicker(AppStrings.background, selection: backgroundColor, supportsOpacity: false)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(AppStrings.metadata)
                    .font(.headline)

                Toggle(AppStrings.showFileName, isOn: $settings.showFileName)
                Toggle(AppStrings.showDuration, isOn: $settings.showDuration)
                Toggle(AppStrings.showFileSize, isOn: $settings.showFileSize)
                Toggle(AppStrings.showResolution, isOn: $settings.showResolution)
            }

            HStack {
                Spacer()
                Button(AppStrings.close) {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 620)
    }
}
