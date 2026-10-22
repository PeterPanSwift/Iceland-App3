import XCTest

/// Drives a guided tour through the app. The CI workflow records the simulator
/// screen while this runs; `markers.txt` tells it where the tour starts and ends
/// so everything outside the app (home screen, test runner) can be trimmed.
@MainActor
final class IcelandUITests: XCTestCase {
    private var app: XCUIApplication!
    private let captureDir = ProcessInfo.processInfo.environment["CAPTURE_DIR"]

    func testTour() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["-resetFavorites"]
        app.launch()

        XCTAssertTrue(element("card-skogafoss").waitForExistence(timeout: 20))
        pause(1.0)
        mark("start")
        pause(1.5)
        snapshot("01-explore")

        // Featured carousel
        let carousel = element("featuredCarousel")
        carousel.swipeLeft(velocity: .slow)
        pause(1.2)
        carousel.swipeLeft(velocity: .slow)
        pause(1.2)

        // Category filter
        let exploreScroll = element("exploreScroll")
        exploreScroll.swipeUp(velocity: .slow)
        pause(1.0)
        element("chip-waterfall").tap()
        pause(1.8)
        element("chip-all").tap()
        pause(1.2)

        // Open Kirkjufell and add it to favorites
        let kirkjufell = element("card-kirkjufell")
        scrollUntilHittable(kirkjufell, in: exploreScroll)
        pause(0.8)
        kirkjufell.tap()
        XCTAssertTrue(element("favoriteButton").waitForExistence(timeout: 10))
        pause(2.0)
        snapshot("02-detail")
        element("favoriteButton").tap()
        pause(1.2)
        app.swipeUp(velocity: .slow)
        pause(1.5)
        app.swipeUp(velocity: .slow)
        pause(2.0)
        goBack()
        pause(1.2)

        // Map
        selectTab("地圖")
        pause(4.0)
        snapshot("03-map")
        let card = element("mapcard-jokulsarlon")
        let strip = element("mapCardStrip")
        scrollUntilHittable(card, in: strip, horizontal: true)
        pause(0.8)
        card.tap()
        pause(4.0)
        snapshot("04-map-detail")
        let detailLink = element("mapDetail-jokulsarlon")
        XCTAssertTrue(detailLink.waitForExistence(timeout: 5))
        detailLink.tap()
        XCTAssertTrue(element("favoriteButton").waitForExistence(timeout: 10))
        pause(1.5)
        element("favoriteButton").tap()
        pause(1.2)
        app.swipeUp(velocity: .slow)
        pause(1.5)
        goBack()
        pause(1.0)

        // Favorites
        selectTab("收藏")
        pause(2.5)
        snapshot("05-favorites")

        // About Iceland
        selectTab("認識冰島")
        pause(2.0)
        snapshot("06-info")
        let infoScroll = element("infoScroll")
        infoScroll.swipeUp(velocity: .slow)
        pause(1.5)
        infoScroll.swipeUp(velocity: .slow)
        pause(2.0)

        selectTab("探索")
        pause(2.0)
        mark("end")
    }

    // MARK: - Helpers

    private func pause(_ seconds: TimeInterval) {
        Thread.sleep(forTimeInterval: seconds)
    }

    private func selectTab(_ label: String) {
        let tabButton = app.tabBars.buttons[label]
        if tabButton.waitForExistence(timeout: 3) {
            tabButton.tap()
        } else {
            app.buttons[label].firstMatch.tap()
        }
    }

    private func goBack() {
        let back = app.navigationBars.buttons["BackButton"]
        if back.exists {
            back.tap()
        } else {
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
    }

    private func scrollUntilHittable(_ element: XCUIElement, in container: XCUIElement, horizontal: Bool = false) {
        for _ in 0..<10 {
            if element.exists && isComfortablyVisible(element, horizontal: horizontal) && element.isHittable { return }
            if horizontal {
                // A press-and-drag moves a fixed distance without a fling.
                let from = container.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.5))
                let to = container.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.5))
                from.press(forDuration: 0.1, thenDragTo: to, withVelocity: .slow, thenHoldForDuration: 0.3)
            } else {
                container.swipeUp(velocity: .slow)
            }
            pause(0.6)
        }
    }

    private func isComfortablyVisible(_ element: XCUIElement, horizontal: Bool) -> Bool {
        let frame = element.frame
        let window = app.windows.firstMatch.frame
        if horizontal {
            return frame.minX >= window.minX - 1 && frame.maxX <= window.maxX + 1
        }
        return frame.minY >= window.minY + 100 && frame.maxY <= window.maxY - 120
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    private func mark(_ label: String) {
        guard let captureDir else { return }
        let line = "\(label) \(Date().timeIntervalSince1970)\n"
        let url = URL(fileURLWithPath: captureDir).appendingPathComponent("markers.txt")
        if let handle = try? FileHandle(forWritingTo: url) {
            handle.seekToEndOfFile()
            handle.write(Data(line.utf8))
            try? handle.close()
        } else {
            try? line.write(to: url, atomically: true, encoding: .utf8)
        }
    }

    private func snapshot(_ name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        if let captureDir {
            let url = URL(fileURLWithPath: captureDir).appendingPathComponent("\(name).png")
            try? screenshot.pngRepresentation.write(to: url)
        }
    }
}
