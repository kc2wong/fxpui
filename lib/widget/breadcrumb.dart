import 'package:flutter/material.dart';

import '../widget/base_widget.dart';

typedef BreadcrumbItemTap = void Function(BreadcrumbItem itemTap);
typedef CaptionProvider = String Function();

class BreadcrumbItem<T> {
  final T? metaData;
  final CaptionProvider captionProvider;
  final BreadcrumbItemTap? onItemTap;

  BreadcrumbItem(
    this.captionProvider,
    this.metaData, {
    this.onItemTap,
  });
}

class BreadCrumb extends StatelessWidget with BaseWidget {
  final List<BreadcrumbItem> items;

  const BreadCrumb({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final elements = <Widget>[];
    for (var i = 0; i < items.length - 1; i++) {
      final item = items[i];
      elements.add(
          _buildBreadCrumbLink(item, false)
      );
      elements.add(
        const Padding(
          padding: EdgeInsets.only(top: 2.0),
          child: Icon(
            Icons.arrow_forward_ios_outlined,
            size: 12,
          ),
        ),
      );
    }
    elements.add(
      _buildBreadCrumbLink(items[items.length - 1], true),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: elements,
    );
  }

  Widget _buildBreadCrumbLink(BreadcrumbItem item, bool lastItem) {
    final text = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Text(
        item.captionProvider(),
        style: defaultTextStyle(
          fontSize: BaseWidget.fontSize + 1,
          fontWeight: lastItem ? FontWeight.bold : null,
        ),
      ),
    );
    if (lastItem) {
      // no padding and no gesture
      return text;
    }
    else {
      if (item.onItemTap != null) {
        return GestureDetector(
          child: InkWell(
            child: text,
            onTap: () => item.onItemTap!(item),
          ),
        );
      } else {
        return text;
      }
    }
  }
}
