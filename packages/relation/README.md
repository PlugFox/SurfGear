# Relation

[![Pub Version](https://img.shields.io/pub/v/relation)](https://pub.dev/packages/relation)
[![Pub Version (including pre-releases)](https://img.shields.io/pub/v/relation?include_prereleases)](https://pub.dev/packages/relation)
[![Pub Likes](https://badgen.net/pub/likes/relation)](https://pub.dev/packages/relation)

This package is part of the [SurfGear](https://github.com/surfstudio/SurfGear) toolset made by [Surf](https://surf.ru/).

![Relation Cover](https://i.ibb.co/f1yC8d5/relation-logo.png)

## About

Two-way communication channels for transferring data between different architectural layers of a Flutter application.

## Currently supported features

- Notify your app's presentation layer about every user input or UI event (button tap, focus change, gesture detection, etc.) using `Action` and implement a reaction to them;
- Write less code with *Actions* that are customized for specific use cases (scrolling, text changing, `ValueNotifier` value changing).
- React to the data state changes and redraw UI using `StreamedState` together with `StreamedStateBuilder` and its variations;
- Manage the screen state in an easy way with a special stream that handles three predefined states: data, loading, error.

## Warning

> :warning: You may run into naming collisions when using this package.

We are using `Action` class, but there is already a class with the exact same name in the Flutter SDK, which leads to naming collisions. We recommend you to use one of 2 workarounds to avoid this issue. In the near future this class will be renamed.

### Preferred solution

The preferable solution is specifying a prefix for relation library and use it for accessing Action class.

```dart
import 'package:relation/relation.dart' as r;
```

In that case it would be necessary to use your prefix to specify the right class while reffering to it.

```dart
final action = r.Action();
```

### Optional solution

Another option is hiding Action class from Flutter SDK.

```dart
import 'package:flutter/material.dart' hide Action;
import 'package:flutter/widgets.dart' hide Action;
```

This solution provides you an ability to call `Action` class from `relation` library without any additional preffixes, but deprives you of the opportunity to reffer *Action* class from the SDK.

```dart
final action = Action();
```

We will resolve this collision in one of the upcoming releases.

## Usage

### Notify and react

#### Action

`Action` is a good way to notify consumers about every event coming from the UI.

Create an `Action` class instance. You can pass data with `Action`'s events, so you need to specify the concrete type of `Action` while declaring it.

```dart
final logoutAction = Action<void>();

final addItemToCartAction = Action<Item>();
```

Find the place where you're going to handle events triggered by your `Action`. Subscribe to the event stream, which you can access through the `stream` property.

```dart
logoutAction.stream.listen(
  (_) => logout()
);

addItemToCartAction.stream.listen(
  (item) => addItemToCart(item)
);
```

Now you can trigger an event through an `Action` instance from anywhere this way:

```dart
logoutAction.accept();

addItemToCartAction.accept(item);
```

Or even easier:

```dart
TextButton(
  onPressed: logoutAction,
  ...
),
```

#### StreamedState

With `StreamedState` you can notify consumers of data changes.

Create a `StreamedState` class instance. `StreamedState` constructor allows you to set the initial value that the consumer will receive as soon as it subscribes to the `StreamedState`. You need to specify the specific data type that your `StreamedState` will handle.

```dart
final userBalanceState = StreamedState<int>(0);

final itemsInCartState = StreamedState<List<Item>>();
```

You can subscribe to `StreamedState` changes in the same way as with `Action`.

```dart
userBalanceState.stream.listen(
  (balance) => showUserBalance(balance)
);
```

To notify all consumers of data changes, you can emit the actual data to the `StreamedState` via the `accept()` function.

```dart
userBalanceState.accept(100);
```

In fact, you can use `Action`s and `StreamedState`s to communicate between any objects in your application. However, we recommend using them to connect the UI and presentation layers.

### Update UI

#### StreamStateBuilder

`StreamStateBuilder` is a widget that builds itself based on the latest snapshot of interaction with a `StreamedState`. The `StreamStateBuilder`'s behavior is almost the same as the standard `StreamBuilder` with the difference that it accepts `StreamedState` instead of the usual `Stream`, thus simplifying the initial data setup.

`StreamStateBuilder` rebuilds its widget subtree each time as its associated `StreamedState` emits a new value. This is the recommended way to organize your UI layer. It can save you from multiple `setState()` function calls.

```dart
Container(
  child: StreamedStateBuilder(
    streamedState: userBalanceState,
    builder: (ctx, balance) => _buildUserBalanceWidget(balance),
  ),
)
```

### State Management

You can build state management solution for your Flutter app using all of the above components.

We recommend using **Relation** package in conjunction with [MWWM architecture](https://pub.dev/packages/mwwm).

- Use `Action` to notify the presentation layer about all the UI events (button taps, pull-to-refresh triggers, swipes, or other gestures detections);
- Use `StreamedState` to report any data changes to the UI layer;
- Let `StreamedStateBuilder` manage the UI state for you. It will rebuild all its child widgets right after it detects any newly emitted data in the associated `StreamedState`.

## Extra units

The **Relation** package provides you not only some basic components for common use-cases, but even more highly specialized classes for solving specific problems.

### Extra Actions

#### ScrollOffsetActon

You can use special `ScrollOffsetAction` to track the scroll offset of a scrollable widget. This is possible thanks to the built-in `ScrollController`.

```dart
final scrollOffsetAction = ScrollOffsetAction();

scrollOffsetAction.stream.listen((offset) {
  print("Current scroll offset = $offset");
});

SingleChildScrollView(
  controller: scrollOffsetAction.controller,
)
```

#### TextEditingActon

`TextEditingAction` is the special type of **Action** to track the text changes in the text field. The built-in `TextEditingController` makes it possible.

```dart
final textEditingAction = TextEditingAction();

textEditingAction.stream.listen((text) {
    print("Typed text = $text");
});

TextField(
    controller: textEditingAction.controller,
    onChanged: textEditingAction,
),
```

#### ControllerActon

`ControllerAction` is more common than two previous variations. During the `ControllerAction` instantiation you can pass a [`ValueNotifier`](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html) inheritor into it.

This means that you can work with the `ClipboardStatusNotifier`, `TextEditingController` or `TransformationController` through the `ControllerAction`.

### Extra StreamedStates

#### EntityStreamedState + EntityStateBuilder

`EntityStreamedState` is an extended version of `StreamedState` designed to make it easier to implement typical dynamic data screens.

We have noticed that most screens in mobile applications are quite simple and have several typical states:

- data;
- loading;
- error.

`EntityStreamedState` provides you a handy interface for the data stream to handle these states properly.

Create a `EntityStreamedState` class instance. Actually, it has the same abilities as `StreamedState`: the initial value setup and the specific data type declaration. Notice that `EntityStreamedState` accepts not a raw piece of data but an `EntityState` wrapper around your data.

```dart
final userProfileState = EntityStreamedState<UserProfile>(EntityState(isLoading: true));
```

Now you can switch your `EntityStreamedState`'s state with just a simple function call. A typical workflow for a query providing some data would look like this:

```dart
userProfileState.loading();
try {
  final result = await _loadUserProfile();
  userProfileState.content(result);
} on Exception catch (error) {
  userProfileState.error(error);
}
```

But what all these functions actually do? The answer is on the other side. Using `EntityStateBuilder` instead of simple `StreamedStateBuilder` you can set widgets for all three states in a declarative way and switch between them easily.

Pass `EntityStreamedState` instance to the `streamedState` argument first. Right after that you can specify a set of widgets for displaying data (`child`), load state (`loadingChild`) and error state (`errorChild`).

```dart
EntityStateBuilder<UserProfile>(
  streamedState: userProfileState,
  child: (ctx, data) => UserProfileWidget(data),
  loadingChild: CircularProgressIndicator(),
  errorChild: ErrorWidget('Something went wrong. Please, try again'),
),
```

Another way to deal with `EntityStateBuilder` is to use `loadingBuilder` and `errorBuilder`. This allows you to customize the error state widgets because you can account for the type of error and the last registered data value from the data stream received by the `errorBuilder`. The same with `loadingBuilder`.

```dart
EntityStateBuilder<UserProfile>(
  streamedState: userProfileState,
  child: (ctx, data) => UserProfileWidget(data),
  loadingBuilder: (context, data) {
    return LoadingWidget(data);
  },
  errorBuilder: (context, data, error) {
    return ErrorWidget(error);
  },
),
```

To summarize, every time someone calls an `EntityStateBuilder`'s functions (`loading()`, `content()` or `error()`), the builder redraws its widget subtree and displays the state that corresponds to the last call.

#### TextFieldStreamedState + TextFieldStateBuilder

The idea of `TextFieldStreamedState` and `TextFieldStateBuilder` technically the same with the difference that `TextFieldStreamedState` is designed to work with text widgets (`Text`, `TextField`, etc.).

`TextFieldStreamedState` allows you to setup your text field validation rules and some other settings like is the text field enabled or mandatory to be filled.

```dart
final textState = TextFieldStreamedState(
  'initialString',
  validator: '[a-zA-Z]{3,30}',
  canEdit: true,
  incorrectTextMsg: 'Text is invalid',
  mandatory: true,
);
```

`TextFieldStateBuilder` accepts the `TextFieldStreamedState` instance and allows to create text widgets according to all state properties.

```dart
TextFieldStateBuilder(
  state: textState,
  stateBuilder: (context, textStateValue) {
    return Text(textStateValue.data);
  },
),
```

## Installation

Add `relation` to your `pubspec.yaml` file:

```yaml
dependencies:
  relation: any
```

You can use both `stable` and `dev` versions of the package listed above in the badges bar.

## Changelog

All notable changes to this project will be documented in [this file](./CHANGELOG.md).

## Issues

For issues, file directly in the [main SurfGear repo](https://github.com/surfstudio/SurfGear).

## Contribute

If you would like to contribute to the package (e.g. by improving the documentation, solving a bug or adding a cool new feature), please review our [contribution guide](../../CONTRIBUTING.md) first and send us your pull request.

You PRs are always welcome.

## How to reach us

Please feel free to ask any questions about this package. Join our community chat on Telegram. We speak English and Russian.

[![Telegram](https://img.shields.io/badge/chat-on%20Telegram-blue.svg)](https://t.me/SurfGear)

## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)
