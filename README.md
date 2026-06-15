# ▤ SideMenu

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg?style=flat-square)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2013%20%7C%20tvOS%2013%20%7C%20macCatalyst%2013-blue.svg?style=flat-square)](https://developer.apple.com)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?style=flat-square)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat-square)](LICENSE)

> 这是 [jonkykong/SideMenu](https://github.com/jonkykong/SideMenu) 的一个维护性 fork，主要面向 Swift Package Manager + 现代 Swift Concurrency（`@MainActor` / Strict Concurrency）。原仓库已不再活跃维护，本仓库聚焦于：
> - 升级 Swift 工具链至 **5.9+**，开启 `StrictConcurrency` / `InferSendableFromCaptures`。
> - 抬升最低部署版本至 **iOS 13 / tvOS 13 / macCatalyst 13**。
> - 仅以 **Swift Package Manager** 形式分发（不再维护 CocoaPods / Carthage）。
> - 修复在新工具链下的若干编译与运行时崩溃问题。

* **[概览](#概览)**
  * [效果预览](#效果预览)
* **[环境要求](#环境要求)**
* **[安装](#安装)**
  * [Swift Package Manager](#swift-package-manager)
* **[使用](#使用)**
  * [Storyboard 零代码接入](#storyboard-零代码接入)
  * [代码接入](#代码接入)
* **[自定义](#自定义)**
  * [SideMenuManager](#sidemenumanager)
  * [SideMenuNavigationController](#sidemenunavigationcontroller)
  * [SideMenuPresentationStyle](#sidemenupresentationstyle)
  * [SideMenuNavigationControllerDelegate](#sidemenunavigationcontrollerdelegate)
  * [进阶](#进阶)
* [已知问题](#已知问题)
* [License](#license)

## 概览

SideMenu 是一个用 Swift 编写的、轻量且高度可定制的侧边菜单控件。

- [x] 支持 [纯 Storyboard 零代码接入](#storyboard-零代码接入)。
- [x] 内置 8 种预设动画样式（包含视差效果），并支持自定义。
- [x] 高度可定制，无需编写大量样板代码。
- [x] 支持单次手势在左右两个菜单之间连续滑动切换。
- [x] 全局菜单配置：一次设置，全局生效。
- [x] 基于 [自定义转场](https://developer.apple.com/library/content/featuredarticles/ViewControllerPGforiPhoneOS/CustomizingtheTransitionAnimations.html)，可像普通控制器一样 `present` / `dismiss`。
- [x] 动画作用于真实的视图控制器，而非快照。
- [x] 正确处理屏幕旋转和通话状态栏高度变化。
- [x] 全面适配 Swift Concurrency（[`@MainActor`](Sources/SideMenu/SideMenuNavigationController.swift:124) 隔离）。

### 效果预览

| Slide Out | Slide In | Dissolve | Slide In + Out |
| --- | --- | --- | --- |
| ![](etc/SlideOut.gif) | ![](etc/SlideIn.gif) | ![](etc/Dissolve.gif) | ![](etc/InOut.gif) |

## 环境要求

- [x] Xcode 15 或更高版本
- [x] Swift 5.9+
- [x] iOS 13 / tvOS 13 / macCatalyst 13 或更高版本

## 安装

### Swift Package Manager

[Swift Package Manager](https://swift.org/package-manager/) 是 Apple 官方的依赖管理工具，已集成进 Swift 编译器。

#### 通过 Xcode

`File` → `Add Packages…` 中输入仓库地址：

```
https://github.com/okferret/SideMenu.git
```

#### 通过 [`Package.swift`](Package.swift:1)

```swift
dependencies: [
    .package(url: "https://github.com/okferret/SideMenu.git", branch: "master")
]
```

然后在目标依赖中加入：

```swift
.target(
    name: "YourApp",
    dependencies: ["SideMenu"]
)
```

> ⚠️ 本 fork 不再维护 CocoaPods 与 Carthage 集成方式。如需通过 CocoaPods/Carthage 引入，请使用上游 [jonkykong/SideMenu](https://github.com/jonkykong/SideMenu)。

## 使用

### Storyboard 零代码接入

1. 创建一个用于侧边菜单的 `UINavigationController`。在 **Identity Inspector** 中将其 `Custom Class` 设为 `SideMenuNavigationController`，`Module` 设为 `SideMenu`。为它设置一个根视图控制器（如下图为 `UITableViewController`），并在其上配置 `Triggered Segues`。
   ![](etc/Screenshot1.png)
2. 将 `SideMenuNavigationController` 的 `Left Side` 属性设为 On 表示从左侧弹出，关闭则从右侧弹出。
   ![](etc/Screenshot2.png)
3. 在希望唤起菜单的页面上添加 `UIButton` 或 `UIBarButtonItem`，将其 `Triggered Segues` 设置为以 modal 方式 present 第 1 步创建的 navigation controller。
   ![](etc/Screenshot3.png)

完成。*注：手势仍需通过代码方式启用。*

### 代码接入

```swift
import SideMenu
```

从一个按钮事件中弹出菜单：

```swift
// 定义菜单
let menu = SideMenuNavigationController(rootViewController: YourViewController())
// SideMenuNavigationController 是 UINavigationController 的子类，
// 这里可以做任意附加的配置，例如 setViewControllers 等。
// 若使用 storyboard:
// let menu = storyboard!.instantiateViewController(withIdentifier: "RightMenu") as! SideMenuNavigationController
present(menu, animated: true, completion: nil)
```

以编程方式关闭菜单：

```swift
dismiss(animated: true, completion: nil)
```

若需要使用手势，则要借助 [`SideMenuManager`](Sources/SideMenu/SideMenuManager.swift:12)。在 `AppDelegate` / `SceneDelegate` 中：

```swift
// 定义菜单
let leftMenuNavigationController = SideMenuNavigationController(rootViewController: YourViewController())
SideMenuManager.default.leftMenuNavigationController = leftMenuNavigationController

let rightMenuNavigationController = SideMenuNavigationController(rootViewController: YourViewController())
SideMenuManager.default.rightMenuNavigationController = rightMenuNavigationController

// 注册手势：左右菜单需先设置（同上）
// 这些手势会绑定到 navigation controller 上，与其当前展示的 view controller 无关
SideMenuManager.default.addPanGestureToPresent(toView: navigationController!.navigationBar)
SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: navigationController!.view)

// （可选）防止菜单出现时状态栏区域变黑
leftMenuNavigationController.statusBarEndAlpha = 0
// 将左菜单的所有设置复制到右菜单
rightMenuNavigationController.settings = leftMenuNavigationController.settings
```

完成。

## 自定义

### SideMenuManager

[`SideMenuManager`](Sources/SideMenu/SideMenuManager.swift:12) 提供以下能力：

```swift
/// 左侧菜单
open var leftMenuNavigationController: SideMenuNavigationController?
/// 右侧菜单
open var rightMenuNavigationController: SideMenuNavigationController?

/// 同时为左右两侧添加屏幕边缘手势
@discardableResult
public func addScreenEdgePanGesturesToPresent(toView view: UIView) -> [UIScreenEdgePanGestureRecognizer]

/// 仅为指定一侧添加屏幕边缘手势
@discardableResult
public func addScreenEdgePanGesturesToPresent(toView view: UIView, forMenu side: PresentDirection) -> UIScreenEdgePanGestureRecognizer

/// 添加 Pan 手势用以唤起菜单（自动判定左右）
@discardableResult
public func addPanGestureToPresent(toView view: UIView) -> UIPanGestureRecognizer
```

### SideMenuNavigationController

[`SideMenuNavigationController`](Sources/SideMenu/SideMenuNavigationController.swift:126) 暴露的可配置属性（来自 [`SideMenuSettings`](Sources/SideMenu/SideMenuNavigationController.swift:86)）：

```swift
/// 同一个类的 view controller 是否允许重复 push。默认 true。
var allowPushOfSameClassTwice: Bool = true
/// 即便被 push 的 view controller 不带动画，也强制菜单转场带动画。
var alwaysAnimate: Bool = true
/// 通过非手势方式展示菜单时使用的动画曲线。
var animationOptions: UIView.AnimationOptions = .curveEaseInOut
/// 当菜单根视图控制器是 UITableViewController / UICollectionViewController 时的毛玻璃样式。
/// 若希望 cell 拥有 vibrancy 效果，请继承 `UITableViewVibrantCell`。
var blurEffectStyle: UIBlurEffect.Style? = nil
/// 手势导致菜单部分关闭时，剩余动画的时长。默认 0.35s。
var completeGestureDuration: Double = 0.35
/// 手势导致菜单部分关闭时，剩余动画的曲线。默认 .easeIn。
var completionCurve: UIView.AnimationCurve = .easeIn
/// 非手势 dismiss 时的动画时长。默认 0.35s。
var dismissDuration: Double = 0.35
/// 当从菜单中 present 其他控制器时，自动关闭菜单。
var dismissOnPresent: Bool = true
/// 当从菜单中 push 其他控制器时，自动关闭菜单。
var dismissOnPush: Bool = true
/// 屏幕旋转时自动关闭菜单。
var dismissOnRotation: Bool = true
/// 进入后台时自动关闭菜单。
var dismissWhenBackgrounded: Bool = true
/// 是否启用滑动关闭手势（`presentingViewControllerUserInteractionEnabled = true` 时无效）。
var enableSwipeToDismissGesture: Bool = true
/// 是否启用点击外部关闭手势（`presentingViewControllerUserInteractionEnabled = true` 时无效）。
var enableTapToDismissGesture: Bool = true
/// 弹簧动画初始速度。
var initialSpringVelocity: CGFloat = 1
/// 菜单出现的方向。true = 左侧；false（默认）= 右侧。**菜单加载后不可变更**。
var leftSide: Bool = false
/// 菜单宽度，剩余区域显示原 view controller。
var menuWidth: CGFloat = 240
/// 非手势 present 的动画时长。默认 0.35s。
var presentDuration: Double = 0.35
/// 菜单显示期间，原 presenting view controller 是否可交互。
/// 开启可能导致难以关闭菜单或重复 present 的异常。需同时关闭 `presentingViewControllerUseSnapshot`。
var presentingViewControllerUserInteractionEnabled: Bool = false
/// 菜单显示期间，是否对 presenting view controller 使用快照。
/// 适用于转场期间布局发生变化的场景；不建议在支持旋转的 App 中使用。
var presentingViewControllerUseSnapshot: Bool = false
/// 菜单的展示样式。
var presentationStyle: SideMenuPresentationStyle = .viewSlideOut
/// 菜单内 push 行为，详见 `SideMenuPushStyle`。
var pushStyle: SideMenuPushStyle = .default
/// 在状态栏下绘制 `presentationStyle.backgroundColor`。
var statusBarEndAlpha: CGFloat = 0
/// 弹簧动画阻尼。
var usingSpringWithDamping: CGFloat = 1
/// 菜单是否仍存在于视图层级中（即便被其它 view controller 覆盖）。
var isHidden: Bool { get }
```

> 注意：原仓库的 `MenuPushStyle` 与 `SideMenuPresentStyle` 在本 fork 中已分别更名为 [`SideMenuPushStyle`](Sources/SideMenu/SideMenuNavigationController.swift:10) 与 [`SideMenuPresentationStyle`](Sources/SideMenu/SideMenuPresentationStyle.swift:1)。

[`SideMenuPushStyle`](Sources/SideMenu/SideMenuNavigationController.swift:10) 包含 6 种模式：

- `default`：常规 push 进入栈。
- `popWhenPossible`：若栈中已存在同类 view controller，则回退到该实例。
- `preserve`：若栈中已存在同类 view controller，则将其移动到栈顶（类似 `UITabBarController`）。
- `preserveAndHideBackButton`：同 `preserve`，并隐藏返回按钮。
- `replace`：清空原栈并替换为新的 view controller，自动隐藏返回按钮。
- `subMenu`：在菜单内部 push（而非通过 presenting view controller），用于实现多级子菜单。

### SideMenuPresentationStyle

内置 8 种预设的 [`SideMenuPresentationStyle`](Sources/SideMenu/SideMenuPresentationStyle.swift:1)：

```swift
/// 菜单从一侧滑入，覆盖在原视图之上。
static let menuSlideIn: SideMenuPresentationStyle
/// 原视图向一侧滑出，露出底部菜单。
static let viewSlideOut: SideMenuPresentationStyle
/// 原视图滑出的同时菜单滑入。
static let viewSlideOutMenuIn: SideMenuPresentationStyle
/// 菜单淡入覆盖在原视图之上。
static let menuDissolveIn: SideMenuPresentationStyle
/// 原视图滑出，菜单部分滑入。
static let viewSlideOutMenuPartialIn: SideMenuPresentationStyle
/// 原视图滑出的同时菜单也向同方向滑出。
static let viewSlideOutMenuOut: SideMenuPresentationStyle
/// 原视图滑出，菜单部分向同方向滑出。
static let viewSlideOutMenuPartialOut: SideMenuPresentationStyle
/// 原视图滑出并缩放，露出底部菜单。
static let viewSlideOutMenuZoom: SideMenuPresentationStyle
```

如需自定义，只需继承 `SideMenuPresentationStyle` 并设置到 `presentationStyle`：

```swift
final class MyPresentStyle: SideMenuPresentationStyle {

    override init() {
        super.init()
        /// 视图与状态栏背后的背景色
        backgroundColor = .black
        /// 菜单出现前的初始 alpha
        menuStartAlpha = 1
        /// 菜单是否在最上层；为 false 时 presenting view 在最上层。阴影应用在最上层视图上。
        menuOnTop = false
        /// 菜单沿 x 轴的位移。0 不动；负值表示移出屏幕；正值表示进入屏幕。
        menuTranslateFactor = 0
        /// 菜单缩放系数；< 1 缩小；> 1 放大。
        menuScaleFactor = 1
        /// 最上层视图的阴影颜色。
        onTopShadowColor = .black
        /// 最上层视图的阴影半径。
        onTopShadowRadius = 5
        /// 最上层视图的阴影透明度。
        onTopShadowOpacity = 0
        /// 最上层视图的阴影偏移。
        onTopShadowOffset = .zero
        /// 菜单完全展示时，presenting view 的最终 alpha。
        presentingEndAlpha = 1
        /// presenting view 沿 x 轴的位移。
        presentingTranslateFactor = 0
        /// presenting view 的缩放系数。
        presentingScaleFactor = 1
        /// presenting view 的视差强度。
        presentingParallaxStrength = .zero
    }

    override func presentationTransitionWillBegin(to presentedViewController: UIViewController, from presentingViewController: UIViewController) {}
    override func presentationTransition(to presentedViewController: UIViewController, from presentingViewController: UIViewController) {}
    override func presentationTransitionDidEnd(to presentedViewController: UIViewController, from presentingViewController: UIViewController, _ completed: Bool) {}
    override func dismissalTransitionWillBegin(to presentedViewController: UIViewController, from presentingViewController: UIViewController) {}
    override func dismissalTransition(to presentedViewController: UIViewController, from presentingViewController: UIViewController) {}
    override func dismissalTransitionDidEnd(to presentedViewController: UIViewController, from presentingViewController: UIViewController, _ completed: Bool) {}
}
```

### SideMenuNavigationControllerDelegate

让目标控制器遵循 [`SideMenuNavigationControllerDelegate`](Sources/SideMenu/SideMenuNavigationController.swift:71) 即可接收菜单显示/隐藏事件：

```swift
extension MyViewController: SideMenuNavigationControllerDelegate {

    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Appearing! (animated: \(animated))")
    }

    func sideMenuDidAppear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Appeared! (animated: \(animated))")
    }

    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappearing! (animated: \(animated))")
    }

    func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappeared! (animated: \(animated))")
    }
}
```

> `SideMenuNavigationController.sideMenuDelegate` 属性是可选的——若 presenting view controller 已遵循该协议，则会自动接收回调。

### 进阶

<details>
<summary>点击展开</summary>

#### 多个 SideMenuManager

为简化常见用法，[`SideMenuManager.default`](Sources/SideMenu/SideMenuManager.swift:46) 作为全局共享实例。如果你需要在不同场景下展示不同的 SideMenu（例如从一个由 SideMenu 弹出的 modal 控制器中再次展示菜单），可以这样做：

1. 创建自定义 `SideMenuManager` 实例（建议在 AppDelegate / SceneDelegate 中以全局变量形式持有）：

```swift
let customSideMenuManager = SideMenuManager()
```

2. 用与 `default` 相同的方式来配置和展示菜单。
3. 若使用 Storyboard，需要继承 `SideMenuNavigationController` 并在 `awakeFromNib` 中设置 `sideMenuManager`（必须早于 `viewDidLoad`）：

```swift
final class MySideMenuNavigationController: SideMenuNavigationController {

    let customSideMenuManager = SideMenuManager()

    override func awakeFromNib() {
        super.awakeFromNib()
        sideMenuManager = customSideMenuManager
    }
}
```

或者在 segue 中赋值：

```swift
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let sideMenuNavigationController = segue.destination as? SideMenuNavigationController {
        sideMenuNavigationController.sideMenuManager = customSideMenuManager
    }
}
```

> ⚠️ 不支持将多个 SideMenu 直接叠加展示。需要多级菜单时请使用 `pushStyle = .subMenu`。

</details>

## 已知问题

* 详见上游 issue [#258](https://github.com/jonkykong/SideMenu/issues/258)。开启 `presentingViewControllerUseSnapshot` 可在一定程度上缓解。

## License

SideMenu 基于 MIT 协议开源，详见 [LICENSE](LICENSE)。

原作者：Jon Kent ([jonkykong/SideMenu](https://github.com/jonkykong/SideMenu))。
