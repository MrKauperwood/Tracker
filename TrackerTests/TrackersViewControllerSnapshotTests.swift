import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackersViewControllerSnapshotTests: XCTestCase {
    
    // MARK: - Properties
    var viewController: TrackersViewController!
    
    override func setUp() {
        super.setUp()
        viewController = TrackersViewController()
        viewController.loadViewIfNeeded()
    }
    
    // MARK: - Snapshot Tests
    
    func testTrackersViewControllerEmptyState() {
        setupViewControllerWithTrackers()
        verifySnapshots()
    }
    
    func testTrackersViewControllerWithSampleData() {
        let tracker = generateTracker()
        let category = generateCategory(withTrackers: [tracker])
        
        setupViewControllerWithTrackers([tracker], for: [category])
        verifySnapshots()
    }
    
    func testTrackersViewControllerWithMultipleCategories() {
        let tracker1 = generateTracker(name: "Tracker 1", color: .lbCS3Blue)
        let tracker2 = generateTracker(name: "Tracker 2", color: .lbCS6Pink)
        let category1 = generateCategory(withTitle: "Category 1", withTrackers: [tracker1])
        let category2 = generateCategory(withTitle: "Category 2", withTrackers: [tracker2])
        
        setupViewControllerWithTrackers([tracker1, tracker2], for: [category1, category2])
        verifySnapshots()
    }
    
    func testTrackersViewControllerWithPinnedTrackers() {
        let pinnedTracker = generateTracker(name: "Pinned Tracker", isPinned: true)
        let regularTracker = generateTracker(name: "Regular Tracker")
        let category = generateCategory(withTrackers: [pinnedTracker, regularTracker])
        
        setupViewControllerWithTrackers([pinnedTracker, regularTracker], for: [category])
        verifySnapshots()
    }
    
    func testTrackersViewControllerWithSearchFilterEmptyState() {
        let tracker1 = generateTracker(name: "Tracker 3", color: .lbCS3Blue)
        let tracker2 = generateTracker(name: "Tracker 2", color: .lbCS6Pink)
        let category = generateCategory(withTrackers: [tracker1, tracker2])
        
        setupViewControllerWithTrackers([tracker1, tracker2], for: [category])
        viewController.setSearchBarText("Mike Tyson")
        verifySnapshots()
    }
    
    func testTrackersViewControllerWithSuccessfulSearch() {
        let tracker1 = generateTracker(name: "One", color: .lbCS3Blue)
        let tracker2 = generateTracker(name: "Two", color: .lbCS6Pink)
        let category1 = generateCategory(withTitle: "Category 1", withTrackers: [tracker1, tracker2])
        
        let tracker3 = generateTracker(name: "Three", color: .lbCS13Peach)
        let tracker4 = generateTracker(name: "Four", color: .lbCS5Green)
        let category2 = generateCategory(withTitle: "Category 2", withTrackers: [tracker3, tracker4])
        
        setupViewControllerWithTrackers([tracker1, tracker2, tracker3, tracker4], for: [category1, category2])
        viewController.setSearchBarText("e")
        verifySnapshots()
    }
    
    func testTrackersViewControllerWithCompletedTrackers() {
        let completedTracker = generateTracker(name: "Completed Tracker")
        viewController.trackerCompleted(completedTracker, on: Date())
        let category = generateCategory(withTrackers: [completedTracker])
        
        let completedRecord = TrackerRecord(trackerId: completedTracker.id, date: Date())
        viewController.setAllRecords = [completedRecord]
        
        setupViewControllerWithTrackers([completedTracker], for: [category])
        verifySnapshots()
    }
    
    // MARK: - Helper Methods
    
    private func generateTracker(
        id: UUID = UUID(),
        name: String = "Sample Tracker",
        color: UIColor = .lbCS1Red,
        emoji: String = "🔥",
        schedule: [Weekday] = [
            .thursday, .tuesday, .wednesday,
            .saturday, .friday, .sunday, .monday
        ],
        trackerType: TrackerType = .habit,
        isPinned: Bool = false
    ) -> Tracker {
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule,
            trackerType: trackerType,
            isPinned: isPinned
        )
    }
    
    private func generateCategory(
        withTitle title: String = "Test LB Category",
        withTrackers trackers: [Tracker] = []
    ) -> TrackerCategory {
        return TrackerCategory(
            title: title,
            trackers: trackers
        )
    }
    
    private func setupViewControllerWithTrackers(
        _ trackers: [Tracker] = [],
        for categories: [TrackerCategory] = []
    ) {
        viewController.setAllExistingTrackers = trackers
        viewController.setAllExistingCategories = categories
        viewController.filterAndReloadData()
    }
    
    private func verifySnapshots(
        file: StaticString = #file,
        testName: String = #function
    ) {
        assertSnapshot(of: viewController, as: .image(traits: .init(userInterfaceStyle: .light)), file: file, testName: testName)
        assertSnapshot(of: viewController, as: .image(traits: .init(userInterfaceStyle: .dark)), file: file, testName: testName)
    }
    
}
