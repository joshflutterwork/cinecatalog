import 'package:cinecatalog/core/common/media.dart';
import 'package:cinecatalog/core/widgets/toast.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a YouTube [trailer] in the YouTube app, or the browser without it.
Future<void> openTrailer(BuildContext context, Trailer trailer) async {
  final url = Uri.https('www.youtube.com', '/watch', {'v': trailer.key});
  var opened = false;
  try {
    opened = await launchUrl(url, mode: LaunchMode.externalApplication);
  } on PlatformException {
    opened = false;
  }
  if (!opened && context.mounted) {
    showToast(context, 'Could not open the trailer');
  }
}
