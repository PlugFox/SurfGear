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

import 'package:flutter/widgets.dart' as flutter;
import 'package:relation/src/relation/action/action.dart';

/// Action for scroll
class ScrollOffsetAction extends Action<double> {
  ScrollOffsetAction([void Function(double? data)? onChanged])
      : super(onChanged) {
    controller.addListener(() {
      accept(controller.offset);
    });
  }

  /// Scroll controller of some list
  final flutter.ScrollController controller = flutter.ScrollController();

  @override
  Future<void> dispose() {
    controller.dispose();

    return super.dispose();
  }
}
