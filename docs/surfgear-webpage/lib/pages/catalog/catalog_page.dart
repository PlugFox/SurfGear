import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:surfgear_webpage/assets/images.dart';
import 'package:surfgear_webpage/assets/text.dart';
import 'package:surfgear_webpage/common/uikit.dart';
import 'package:surfgear_webpage/common/widgets.dart';
import 'package:surfgear_webpage/components/menu.dart';
import 'package:surfgear_webpage/const.dart';
import 'package:surfgear_webpage/main.dart';
import 'package:surfgear_webpage/modules.dart';
import 'package:surfgear_webpage/pages/main/main_page.dart';
import 'package:url_launcher/url_launcher.dart';

class CatalogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: (_) {},
          child: Column(
            children: <Widget>[
              _Header(),
              _List(),
              SizedBox(height: 630.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logoAndText = <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 56.0,
          vertical: 32.0,
        ),
        child: Clickable(
          onClick: () => Navigator.of(context).pushNamed(Router.main),
          child: Image.network(
            '/$assetsRoot/$svgSurfgearLogo',
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 56.0,
          vertical: 32.0,
        ),
        child: AutoSizeText(
          catalogPageTitle,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: Theme.of(context).textTheme.headline4,
        ),
      ),
    ];

    return ConstrainedBox(
      constraints: BoxConstraints.expand(height: 700.0),
      child: Column(
        children: <Widget>[
          Menu(),
          Expanded(
            child: Center(
              child: MediaQuery.of(context).size.width > MEDIUM_SCREEN_WIDTH
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: logoAndText,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: logoAndText,
                    ),
            ),
          )
        ],
      ),
    );
  }
}

class _List extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Module>>(
      future: modules,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (var i = 0; i < snapshot.data.length; i++)
              _ListTile(
                module: snapshot.data[i],
                isOdd: i.isOdd,
              ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 120.0),
                child: FilledButton(
                  title: catalogPageRepoBtnText,
                  // onPressed: () => launch(packagesUrl),
                  onPressed: () {
                    ScopedModel.of<AppModel>(context).switchTheme();
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ListTile extends StatelessWidget {
  final Module module;
  final bool isOdd;

  _ListTile({
    Key key,
    @required this.module,
    this.isOdd = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: !isOdd
            ? theme.scaffoldBackgroundColor
            : theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Flexible(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(left: 32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Clickable(
                        onClick: () => launch(module.link),
                        child: Text(
                          module.name,
                          textAlign: TextAlign.right,
                          style: theme.textTheme.bodyText1,
                        ),
                      ),
                      if (screenWidth <= SMALL_SCREEN_WIDTH)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: _ModuleStatusBadge(
                            status: module.status,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (screenWidth >= SMALL_SCREEN_WIDTH)
              SizedBox(
                width: screenWidth >= MEDIUM_SCREEN_WIDTH ? 360.0 : 180.0,
                child: Center(
                  child: _ModuleStatusBadge(
                    status: module.status,
                  ),
                ),
              )
            else
              SizedBox(width: 60.0),
            Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(right: 32.0),
                child: SizedBox(
                  width: 630,
                  child: Text(
                    module.description,
                    style: theme.textTheme.bodyText1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleStatusBadge extends StatelessWidget {
  final ModuleStatus status;

  _ModuleStatusBadge({
    Key key,
    @required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;

    if (status == ModuleStatus.alpha) {
      text = 'alpha';
      color = Color(0xFFC61207);
    } else if (status == ModuleStatus.beta) {
      text = 'beta';
      color = Color(0xFFC89000);
    } else if (status == ModuleStatus.release) {
      text = 'release';
      color = Color(0xFF17A700);
    } else {
      text = 'surf';
      color = Color(0xFF00638E);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 2.0,
        ),
        child: Text(
          text,
          style: GoogleFonts.raleway(
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}