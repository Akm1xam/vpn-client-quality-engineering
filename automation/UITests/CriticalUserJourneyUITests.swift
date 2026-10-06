import XCTest

/// Critical user journey end-to-end tests using Apple XCTest / XCUITest.
final class CriticalUserJourneyUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppLaunchAndServerListRender() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--mock-servers"]
        app.launch()

        // Verify Home view elements
        XCTAssertTrue(app.buttons["vpn_toggle_button"].waitForExistence(timeout: 5.0), "Connect button must be present on initial launch.")

        // Navigate to Servers tab
        let serversTab = app.tabBars.buttons["Servers"]
        if serversTab.exists {
            serversTab.tap()
            XCTAssertTrue(app.tables["server_list_view"].waitForExistence(timeout: 3.0) || app.scrollViews["server_list_view"].exists)
        }
    }

    func testSettingsNavigationAndPrivacyBulletVerification() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()

        // Navigate to Settings tab
        let settingsTab = app.tabBars.buttons["Settings"]
        if settingsTab.exists {
            settingsTab.tap()

            // Verify "No Analytics or Trackers" policy is visible to user
            let noAnalyticsText = app.staticTexts["No Analytics or Trackers"]
            XCTAssertTrue(noAnalyticsText.waitForExistence(timeout: 3.0), "Privacy guarantee must be displayed in Settings view.")
        }
    }
}

