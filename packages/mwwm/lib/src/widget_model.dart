// Copyright (c) 2019-present,  SurfStudio LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mwwm/mwwm.dart';
import 'package:mwwm/src/dependencies/wm_dependencies.dart';
import 'package:mwwm/src/error/error_handler.dart';
import 'package:mwwm/src/utils/composite_subscription.dart';

/// WidgetModel
/// WM is logical representation of widget and his state.
/// `WidgetModelDependencies` - is pack of dependencies for WidgetModel. Offtenly, it is `ErrorHandler`.
/// `Model` - optionally, but recommended, manager for connection with bussines layer
abstract class WidgetModel {
  WidgetModel(
    WidgetModelDependencies baseDependencies, {
    Model? model,
  })  : _errorHandler = baseDependencies.errorHandler,
        model = model ?? const Model([]);

  final ErrorHandler? _errorHandler;

  @protected
  final Model model;

  final _compositeSubscription = CompositeSubscription();

  /// called when widget ready
  @mustCallSuper
  void onLoad() {}

  /// here need to bind
  @mustCallSuper
  void onBind() {}

  /// subscribe for interactors
  StreamSubscription subscribe<T>(
    Stream<T> stream,
    void Function(T t) onValue, {
    void Function(Object e)? onError,
  }) {
    // ignore: avoid_types_on_closure_parameters
    final subscription = stream.listen(onValue, onError: (Object e) {
      onError?.call(e);
    });

    _compositeSubscription.add(subscription);
    return subscription;
  }

  /// subscribe for interactors with default handle error
  StreamSubscription subscribeHandleError<T>(
    Stream<T> stream,
    void Function(T t) onValue, {
    void Function(Object e)? onError,
  }) {
    // ignore: avoid_types_on_closure_parameters
    final subscription = stream.listen(onValue, onError: (Object e) {
      handleError(e);
      onError?.call(e);
    });

    _compositeSubscription.add(subscription);
    return subscription;
  }

  /// Call a future.
  /// Using Rx wrappers with [subscribe] method is preferable.
  void doFuture<T>(
    Future<T> future,
    void Function(T t) onValue, {
    void Function(Object)? onError,
  }) {
    // ignore: avoid_types_on_closure_parameters
    future.then(onValue).catchError((Object e) {
      onError?.call(e);
    });
  }

  /// Call a future with default error handling
  void doFutureHandleError<T>(
    Future<T> future,
    FutureOr<T> Function(T) onValue, {
    void Function(Object)? onError,
  }) {
    // ignore: avoid_types_on_closure_parameters
    future.then<T>(onValue).catchError((Object e) {
      handleError(e);
      onError?.call(e);
    });
  }

  /// Close streams of WM
  void dispose() {
    _compositeSubscription.dispose();
  }

  /// standard error handling
  @protected
  void handleError(Object e) {
    _errorHandler?.handleError(e);
  }
}
