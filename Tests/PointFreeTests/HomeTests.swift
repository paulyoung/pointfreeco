import ApplicativeRouter
import SnapshotTesting
import Prelude
import XCTest
@testable import PointFree
import PointFreeTestSupport
import HttpPipeline
import Optics
#if !os(Linux)
import WebKit
#endif

class HomeTests: TestCase {
  override func setUp() {
    super.setUp()

    let eps = [
      ep10,
      ep2,
      ep1,
      introduction,
      ]
      .suffix(4)
      .map(\.image .~ "")

    let env: (Environment) -> Environment =
      (\.database .~ .mock)
      <> (\.episodes .~ unzurry(eps))

    AppEnvironment.push(env)
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }

  func testHomepage_LoggedOut() {
    let conn = connection(from: request(to: .home))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 3000))
      webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 400
      webView.frame.size.height = 3500

      let render = expectation(description: "Render")
      DispatchQueue.main.async {
        assertSnapshot(matching: webView, named: "mobile")
        render.fulfill()
      }
      waitForExpectations(timeout: 2) { XCTAssert($0 == nil) }
    }
    #endif
  }

  func testHomepage_Subscriber() {
    let conn = connection(from: request(to: .home, session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2300))
      webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 400
      webView.frame.size.height = 2800

      let render = expectation(description: "Render")
      DispatchQueue.main.async {
        assertSnapshot(matching: webView, named: "mobile")
        render.fulfill()
      }
      waitForExpectations(timeout: 2) { XCTAssert($0 == nil) }
    }
    #endif
  }

  func testEpisodesIndex() {
    let conn = connection(from: request(to: .episodes))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
  }
}
