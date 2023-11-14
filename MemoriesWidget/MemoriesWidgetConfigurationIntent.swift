import AppIntents
import WidgetKit
import Activity

@available(iOS 17, *)
class ConfigurationTimelineProvider: AppIntentTimelineProvider {
    typealias Entry = SimpleEntry
    typealias Intent = MemoriesWidgetConfigurationIntent
    
    private let common = TimelineCommon()
    private let viewModel = ActivityViewModel()
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date())
    }
    
    func snapshot(for configuration: MemoriesWidgetConfigurationIntent, in context: Context) async -> SimpleEntry {
        let activity = ActivityViewModel.getActivityFromUserDefault()
        let error = ActivityViewModel.getErrorFromUserDefault()
        return SimpleEntry(date: Date(), activity: activity, error: error)
    }
    
    func timeline(for configuration: MemoriesWidgetConfigurationIntent, in context: Context) async -> Timeline<SimpleEntry> {
        self.common.initializeDependencies()
        await self.common.onGetTimeline()
        
        // Home screen was forced refresh, update the widget with user defaults only
        if ActivityViewModel.getUnseenWidgetForceRefreshFromUserDefault() {
            let activity = ActivityViewModel.getActivityFromUserDefault()
            let error = ActivityViewModel.getErrorFromUserDefault()
            viewModel.forceRefreshWidgetProcessed()
            return self.common.buildTimeline(activity: activity, error: error)
        } else {
            await viewModel.fetchRandomActivity(persist: configuration.priority == .main)
            return self.common.buildTimeline(activity: viewModel.activity, error: viewModel.error)
        }
    }
}

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
