import Foundation

enum Loc {

    enum TrackersMain {
        static let title = NSLocalizedString("trackers.title", comment: "")
        static let filtersButton = NSLocalizedString("trackers.filtersButton", comment: "")
        static let searchPlaceholder = NSLocalizedString("trackers.searchPlaceholder", comment: "")
        static let placeholderLabel = NSLocalizedString("trackers.placeholderLabel", comment: "")
        static let filterPlaceholderLabel = NSLocalizedString("trackers.filterPlaceholderLabel", comment: "")
        static let completedFilterHeader = NSLocalizedString("trackers.completedFilterHeader", comment: "")
        static let uncompleteFilterHeader = NSLocalizedString("trackers.uncompleteFilterHeader", comment: "")
        static let searchResultsHeader = NSLocalizedString("trackers.searchResultsHeader", comment: "")
        static let trackerAlertTitle = NSLocalizedString("trackers.trackerAlertTitle", comment: "")
        static let contextMenuEditButton = NSLocalizedString("trackers.contextMenuEditButton", comment: "")
        static let contextMenuDeleteButton = NSLocalizedString("trackers.contextMenuDeleteButton", comment: "")
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
    
    enum Alert {
        static let cancelLabel = NSLocalizedString("alert.cancelLabel", comment: "")
        static let deleteLabel = NSLocalizedString("alert.deleteLabel", comment: "")
    }

}
