import AppIntents
import WidgetKit

@available(iOS 17, *)
struct MemoriesWidgetConfigurationIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Background Color"
    static let description = IntentDescription("Change the background of the widget.")

    @Parameter(title: "Priority", default: IntentWidgetPriority.unknown)
    var priority: IntentWidgetPriority

    init(
        priority: IntentWidgetPriority
    ) {
        self.priority = priority
    }

    init() {}
}

@available(iOS 17, *)
enum IntentWidgetPriority: String, AppEnum {
    case unknown
    case main

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Priority")

    static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .unknown: DisplayRepresentation(title: "Unknown"),
        .main: DisplayRepresentation(title: "Main")
    ]
}
