enum TrackerFilter: String, CaseIterable {
    case all = "all"
    case today = "today"
    case completed = "completed"
    case incomplete = "incomplete"

    var title: String {
        switch self {
        case .all: return Loc.Filters.all
        case .today: return Loc.Filters.today
        case .completed: return Loc.Filters.completed
        case .incomplete: return Loc.Filters.notCompleted
        }
    }
}
