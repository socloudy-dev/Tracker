import Foundation

enum Loc {

    enum TrackersMain {
        static let title = NSLocalizedString("trackers.title", comment: "")
        static let filtersButton = NSLocalizedString("trackers.filtersButton", comment: "")
        static let searchPlaceholder = NSLocalizedString("trackers.searchPlaceholder", comment: "")
        static let placeholderLabel = NSLocalizedString("trackers.placeholderLabel", comment: "")
        static let filterPlaceholderLabel = NSLocalizedString("trackers.filterPlaceholderLabel", comment: "")
    }

    enum TabBar {
        static let trackers = NSLocalizedString("tabBar.trackers", comment: "")
        static let statistics = NSLocalizedString("tabBar.statistics", comment: "")
    }

    enum Filters {
        static let title = NSLocalizedString("filters.title", comment: "")
        static let all = NSLocalizedString("filters.all", comment: "")
        static let today = NSLocalizedString("filters.today", comment: "")
        static let completed = NSLocalizedString("filters.completed", comment: "")
        static let notCompleted = NSLocalizedString("filters.notCompleted", comment: "")
    }
}
