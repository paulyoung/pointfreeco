import Either
import Html
import HtmlPrettyPrint
import HttpPipeline
@testable import PointFree
import PointFreeTestSupport
import Prelude
import Optics
import SnapshotTesting
import XCTest
#if !os(Linux)
import WebKit
#endif

class BlogTests: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.push(\.database .~ .mock)
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }

  func testBlogIndex() {
    let req = request(to: .blog(.index), basicAuth: true)
    let result = connection(from: req)
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: result)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 2000))
      webView.loadHTMLString(String(data: result.data, encoding: .utf8)!, baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 500
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

  func testBlogIndex_Unauthed() {
    let req = request(to: .blog(.index), basicAuth: true)
    let result = connection(from: req)
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: result)
  }

  func testBlogShow() {
    let req = request(to: .blog(.show(post0000_mock)), basicAuth: true)
    let result = connection(from: req)
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: result)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 2000))
      webView.loadHTMLString(String(data: result.data, encoding: .utf8)!, baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 500
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

  func testBlogShow_Unauthed() {
    let req = request(to: .blog(.show(post0000_mock))) 
    let result = connection(from: req)
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: result)
  }

  func testBlogAtomFeed() {
    let req = request(to: .blog(.feed(.atom)), basicAuth: true)
    let result = connection(from: req)
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: result)
  }

  func testBlogAtomFeed_Unauthed() {
    let req = request(to: .blog(.feed(.atom)))
    let result = connection(from: req)
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: result)
  }
}
