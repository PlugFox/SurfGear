import 'package:flutter/material.dart';
import 'package:flutter_template/di/base/component.dart';
import 'package:flutter_template/di/base/module.dart';
import 'package:flutter_template/interactor/counter/counter_interactor.dart';
import 'package:flutter_template/interactor/user/user_interactor.dart';
import 'package:flutter_template/ui/base/impl/default_error_handler.dart';
import 'package:flutter_template/ui/screen/homepage/homepage_wm.dart';

/// Component for dependencies for HomePage
class HomePageComponent extends Component {
  final CounterInteractor _counterInteractor;
  final UserInteractor _userInteractor;
  final GlobalKey<ScaffoldState> _scaffoldState;

  HomePageComponent(this._counterInteractor, this._userInteractor, this._scaffoldState);

  @override
  List<Module> getModules() {
    return [HomePageModule(_counterInteractor, _userInteractor, _scaffoldState)];
  }
}

/// модуль, создающий модель главной страницы
/// а так же пробрасывающий в нее зависимости
class HomePageModule extends Module<HomePageModel> {
  final CounterInteractor _counterInteractor;
  final UserInteractor _userInteractor;
  final GlobalKey<ScaffoldState> _scaffoldState;

  HomePageModule(this._counterInteractor, this._userInteractor, this._scaffoldState);

  @override
  provides() {
    return HomePageModel(_counterInteractor, _userInteractor, MaterialErrorHandler(_scaffoldState));
  }
}
