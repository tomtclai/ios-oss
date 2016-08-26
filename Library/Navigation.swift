// swiftlint:disable file_length
import Argo
import Curry
import Foundation
import KsApi

public enum Navigation {
  case checkout(Int, Navigation.Checkout)
  case signup
  case tab(Tab)
  case project(Param, Navigation.Project, refTag: RefTag?)

  public enum Checkout {
    case payments(Navigation.Checkout.Payment)

    public enum Payment {
      case new
      case root
      case useStoredCard
    }
  }

  public enum Tab {
    case discovery(DiscoveryParams, Navigation.Discovery)
    case search
    case activity
    case dashboard(project: Param)
    case login
    case me
  }

  public enum Discovery {
    case root
    case advanced
    case category(category: Param, subcategory: Param?)
  }

  public enum Project {
    case checkout(Int, Navigation.Project.Checkout)
    case root
    case comments
    case creatorBio
    case friends
    case messageCreator
    case pledge(Navigation.Project.Pledge)
    case updates
    case update(Int, Navigation.Project.Update)
    case survey(Int)

    public enum Checkout {
      case thanks
    }

    public enum Pledge {
      case bigPrint
      case destroy
      case edit
      case new
      case root
    }

    public enum Update {
      case root
      case comments
    }
  }
}

extension Navigation: Equatable {}
public func == (lhs: Navigation, rhs: Navigation) -> Bool {
  switch (lhs, rhs) {
  case let (.checkout(lhsId, lhsCheckout), .checkout(rhsId, rhsCheckout)):
    return lhsId == rhsId && lhsCheckout == rhsCheckout
  case (.signup, .signup):
    return true
  case let (.tab(lhs), .tab(rhs)):
    return lhs == rhs
  case let (.project(lhsParam, lhsProject, lhsRefTag), .project(rhsParam, rhsProject, rhsRefTag)):
    return lhsParam == rhsParam && lhsProject == rhsProject && lhsRefTag == rhsRefTag
  default:
    return false
  }
}

extension Navigation.Checkout: Equatable {}
public func == (lhs: Navigation.Checkout, rhs: Navigation.Checkout) -> Bool {
  switch (lhs, rhs) {
  case let (.payments(lhsPayment), .payments(rhsPayment)):
    return lhsPayment == rhsPayment
  }
}

extension Navigation.Checkout.Payment: Equatable {}
public func == (lhs: Navigation.Checkout.Payment, rhs: Navigation.Checkout.Payment) -> Bool {
  switch (lhs, rhs) {
  case (.new, .new), (.root, .root), (.useStoredCard, .useStoredCard):
    return true
  default:
    return false
  }
}

// swiftlint:disable cyclomatic_complexity
extension Navigation.Project: Equatable {}
public func == (lhs: Navigation.Project, rhs: Navigation.Project) -> Bool {
  switch (lhs, rhs) {
  case let (.checkout(lhsId, lhsCheckout), .checkout(rhsId, rhsCheckout)):
    return lhsId == rhsId && lhsCheckout == rhsCheckout
  case (.root, .root):
    return true
  case (.comments, .comments):
    return true
  case (.creatorBio, .creatorBio):
    return true
  case (.friends, .friends):
    return true
  case (.messageCreator, .messageCreator):
    return true
  case let (.pledge(lhsPledge), .pledge(rhsPledge)):
    return lhsPledge == rhsPledge
  case (.updates, .updates):
    return true
  case let (.update(lhsId, lhsUpdate), .update(rhsId, rhsUpdate)):
    return lhsId == rhsId && lhsUpdate == rhsUpdate
  case let (.survey(lhsId), .survey(rhsId)):
    return lhsId == rhsId
  default:
    return false
  }
}
// swiftlint:enable cyclomatic_complexity

extension Navigation.Project.Checkout: Equatable {}
public func == (lhs: Navigation.Project.Checkout, rhs: Navigation.Project.Checkout) -> Bool {
  switch (lhs, rhs) {
  case (.thanks, .thanks):
    return true
  }
}

extension Navigation.Project.Pledge: Equatable {}
public func == (lhs: Navigation.Project.Pledge, rhs: Navigation.Project.Pledge) -> Bool {
  switch (lhs, rhs) {
  case (.bigPrint, .bigPrint), (.destroy, .destroy), (.edit, .edit), (.new, .new), (.root, .root):
    return true
  default:
    return false
  }
}

extension Navigation.Project.Update {}
public func == (lhs: Navigation.Project.Update, rhs: Navigation.Project.Update) -> Bool {
  switch (lhs, rhs) {
  case (.root, .root):
    return true
  case (.comments, .comments):
    return true
  default:
    return false
  }
}

extension Navigation.Discovery: Equatable {}
public func == (lhs: Navigation.Discovery, rhs: Navigation.Discovery) -> Bool {
  switch (lhs, rhs) {
  case (.root, .root):
    return true
  case (.advanced, .advanced):
    return true
  case let (.category(lhsCatParam, lhsSubCatParam), .category(rhsCatParam, rhsSubCatParam)):
    return lhsCatParam == rhsCatParam && lhsSubCatParam == rhsSubCatParam
  default:
    return false
  }
}

extension Navigation.Tab: Equatable {}
public func == (lhs: Navigation.Tab, rhs: Navigation.Tab) -> Bool {
  switch (lhs, rhs) {
  case let (.discovery(lhsParams, lhsDiscovery), .discovery(rhsParams, rhsDiscovery)):
    return lhsParams == rhsParams && lhsDiscovery == rhsDiscovery
  case (.search, .search):
    return true
  case (.activity, .activity):
    return true
  case let (.dashboard(lhsParam), .dashboard(rhsParam)):
    return lhsParam == rhsParam
  case (.login, .login):
    return true
  case (.me, .me):
    return true
  default:
    return false
  }
}

extension Navigation {
  public static func match(url: NSURL) -> Navigation? {
    return routes.reduce(nil) { accum, templateAndRoute in
      let (template, route) = templateAndRoute
      return accum ?? parsedParams(url: url, fromTemplate: template).flatMap(route)?.value
    }
  }

  public static func match(request: NSURLRequest) -> Navigation? {
    return request.URL.flatMap(match)
  }
}

private let routes = [
  "/activity": activity,
  "/authorize": authorize,
  "/checkouts/:checkout_param/payments": paymentsRoot,
  "/checkouts/:checkout_param/payments/new": paymentsNew,
  "/checkouts/:checkout_param/payments/use_stored_card": paymentsUseStoredCard,
  "/discover": discovery,
  "/discover/advanced": discoveryAdvanced,
  "/discover/categories/:category_param": category,
  "/discover/categories/:category_param/:subcategory_param": category,
  "/profile/:user_param": me,
  "/search": search,
  "/signup": signup,
  "/projects/:creator_param/:project_param": project,
  "/projects/:creator_param/:project_param/checkouts/:checkout_param/thanks": thanks,
  "/projects/:creator_param/:project_param/comments": projectComments,
  "/projects/:creator_param/:project_param/creator_bio": creatorBio,
  "/projects/:creator_param/:project_param/dashboard": dashboard,
  "/projects/:creator_param/:project_param/description": project,
  "/projects/:creator_param/:project_param/friends": friends,
  "/projects/:creator_param/:project_param/messages/new": messageCreator,
  "/projects/:creator_param/:project_param/pledge": pledgeRoot,
  "/projects/:creator_param/:project_param/pledge/big_print": pledgeBigPrint,
  "/projects/:creator_param/:project_param/pledge/destroy": pledgeDestroy,
  "/projects/:creator_param/:project_param/pledge/edit": pledgeEdit,
  "/projects/:creator_param/:project_param/pledge/new": pledgeNew,
  "/projects/:creator_param/:project_param/posts": posts,
  "/projects/:creator_param/:project_param/posts/:update_param": update,
  "/projects/:creator_param/:project_param/posts/:update_param/comments": updateComments,
  "/projects/:creator_param/:project_param/surveys/:survey_param": survey,
]

extension Navigation.Project {
  // swiftlint:disable conditional_binding_cascade
  public static func withRequest(request: NSURLRequest) -> (Param, RefTag?)? {
    guard let nav = Navigation.match(request), case let .project(project, .root, refTag) = nav
      else { return nil }
    return (project, refTag)
  }

  public static func updateWithRequest(request: NSURLRequest) -> (Param, Int)? {
    guard let nav = Navigation.match(request), case let .project(project, .update(update, .root), _) = nav
      else { return nil }
    return (project, update)
  }

  public static func updateCommentsWithRequest(request: NSURLRequest) -> (Param, Int)? {
    guard let nav = Navigation.match(request), case let .project(project, .update(update, .comments), _) = nav
      else { return nil }
    return (project, update)
  }
  // swiftlint:enable conditional_binding_cascade
}

// MARK: Router

// Argo calls their nebulous data blob `JSON`, but we will interpret it as route params.
public typealias RouteParams = JSON

private func activity(_: RouteParams) -> Decoded<Navigation> {
  return .Success(.tab(.activity))
}

private func authorize(_: RouteParams) -> Decoded<Navigation> {
  return .Success(.tab(.login))
}

private func paymentsNew(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.checkout)
    <^> (params <| "checkout_param" >>- stringToInt)
    <*> .Success(.payments(.new))
}

private func paymentsRoot(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.checkout)
    <^> (params <| "checkout_param" >>- stringToInt)
    <*> .Success(.payments(.root))
}

private func paymentsUseStoredCard(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.checkout)
    <^> (params <| "checkout_param" >>- stringToInt)
    <*> .Success(.payments(.useStoredCard))
}

private func discovery(params: RouteParams) -> Decoded<Navigation> {
  guard let discoveryParams = DiscoveryParams.decode(params).value
    else { return .Failure(.Custom("Failed to extact discovery params")) }
  return .Success(.tab(.discovery(discoveryParams, .root)))
}

private func discoveryAdvanced(params: RouteParams) -> Decoded<Navigation> {
  guard let discoveryParams = DiscoveryParams.decode(params).value
    else { return .Failure(.Custom("Failed to extact discovery params")) }
  return .Success(.tab(.discovery(discoveryParams, .advanced)))
}

private func category(params: RouteParams) -> Decoded<Navigation> {
  guard let discoveryParams = DiscoveryParams.decode(params).value
    else { return .Failure(.Custom("Failed to extact discovery params")) }

  let categoryMatch = curry(Navigation.Discovery.category)
    <^> params <| "category_param"
    <*> params <|? "subcategory_param"

  guard let category = categoryMatch.value else { return .Failure(.Custom("Failed to route category")) }

  return .Success(.tab(.discovery(discoveryParams, category)))
}

private func me(_: RouteParams) -> Decoded<Navigation> {
  return .Success(.tab(.me))
}

private func search(_: RouteParams) -> Decoded<Navigation> {
  return .Success(.tab(.search))
}

private func signup(_: RouteParams) -> Decoded<Navigation> {
  return .Success(.signup)
}

private func project(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .Success(.root)
    <*> params <|? "ref_tag"
}

private func thanks(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> (curry(Navigation.Project.checkout)
      <^> (params <| "checkout_param" >>- stringToInt)
      <*> .Success(.thanks))
    <*> params <|? "ref_tag"
}

private func projectComments(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .Success(.comments)
    <*> params <|? "ref_tag"
}

private func creatorBio(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .Success(.creatorBio)
    <*> params <|? "ref_tag"
}

private func dashboard(params: RouteParams) -> Decoded<Navigation> {
  guard let dashboard = (Navigation.Tab.dashboard <^> params <| "project_param").value
    else { return .Failure(.Custom("Failed to extract project param")) }

  return .Success(.tab(dashboard))
}

private func friends(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .Success(.friends)
    <*> params <|? "ref_tag"
}

private func messageCreator(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .Success(.messageCreator)
    <*> params <|? "ref_tag"
}

private func pledgeBigPrint(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .Success(.pledge(.bigPrint))
    <*> params <|? "ref_tag"
}

private func pledgeDestroy(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .Success(.pledge(.destroy))
    <*> params <|? "ref_tag"
}

private func pledgeEdit(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .Success(.pledge(.edit))
    <*> params <|? "ref_tag"
}

private func pledgeNew(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .Success(.pledge(.new))
    <*> params <|? "ref_tag"
}

private func pledgeRoot(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .Success(.pledge(.root))
    <*> params <|? "ref_tag"
}

private func posts(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> .Success(Navigation.Project.updates)
    <*> params <|? "ref_tag"
}

private func update(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> (curry(Navigation.Project.update)
      <^> (params <| "update_param" >>- stringToInt)
      <*> .Success(.root))
    <*> params <|? "ref_tag"
}

private func updateComments(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> (curry(Navigation.Project.update)
      <^> (params <| "update_param" >>- stringToInt)
      <*> .Success(.comments))
    <*> params <|? "ref_tag"
}

private func survey(params: RouteParams) -> Decoded<Navigation> {
  return curry(Navigation.project)
    <^> params <| "project_param"
    <*> (Navigation.Project.survey <^> (params <| "survey_param" >>- stringToInt))
    <*> params <|? "ref_tag"
}

// MARK: Helpers

private func parsedParams(url url: NSURL, fromTemplate template: String) -> RouteParams? {

  // early out on URL's that are not recognized as kickstarter URL's
  let isApiURL = url.absoluteString
    .hasPrefix(AppEnvironment.current.apiService.serverConfig.apiBaseUrl.absoluteString)
  let isWebURL = url.absoluteString
    .hasPrefix(AppEnvironment.current.apiService.serverConfig.webBaseUrl.absoluteString)
  guard isApiURL || isWebURL else { return nil }

  let templateComponents = template
    .componentsSeparatedByString("/")
    .filter { $0 != "" }
  let urlComponents = url
    .path?
    .componentsSeparatedByString("/")
    .filter { $0 != "" && !$0.hasPrefix("?") } ?? []

  guard templateComponents.count == urlComponents.count else { return nil }

  var params: [String:String] = [:]

  for (templateComponent, urlComponent) in zip(templateComponents, urlComponents) {
    if templateComponent.hasPrefix(":") {
      // matched a token
      let paramName = String(templateComponent.characters.dropFirst())
      params[paramName] = urlComponent
    } else if templateComponent != urlComponent {
      return nil
    }
  }

  NSURLComponents(URL: url, resolvingAgainstBaseURL: false)?
    .queryItems?
    .forEach { item in
      params[item.name] = item.value
  }

  var object: [String:RouteParams] = [:]
  params.forEach { key, value in
    object[key] = .String(value)
  }

  return .Object(object)
}

private func stringToInt(string: String) -> Decoded<Int> {
  return Int(string).map(Decoded.Success) ?? .Failure(.Custom("Could not parse string into int."))
}