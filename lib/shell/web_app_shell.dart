import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../bridge/native_bridge_dispatcher.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/dot_mark.dart';

class WebAppShell extends StatefulWidget {
  WebAppShell({
    required this.webAppUri,
    NativeBridgeDispatcher? dispatcher,
    super.key,
  }) : dispatcher = dispatcher ?? NativeBridgeDispatcher.local();

  final Uri webAppUri;
  final NativeBridgeDispatcher dispatcher;

  @override
  State<WebAppShell> createState() => _WebAppShellState();
}

class _WebAppShellState extends State<WebAppShell> {
  late final WebViewController controller;
  bool isLoading = true;
  bool hasLoadError = false;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppTheme.paper)
      ..addJavaScriptChannel(
        'PlaceNoteNative',
        onMessageReceived: _onNativeMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final requestedUri = Uri.tryParse(request.url);
            if (requestedUri == null ||
                requestedUri.origin != widget.webAppUri.origin) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                isLoading = true;
                hasLoadError = false;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => isLoading = false);
            }
          },
          onWebResourceError: (error) {
            if (mounted && (error.isForMainFrame ?? false)) {
              setState(() {
                isLoading = false;
                hasLoadError = true;
              });
            }
          },
        ),
      )
      ..loadRequest(widget.webAppUri);
  }

  Future<void> _onNativeMessage(JavaScriptMessage message) async {
    final response = await widget.dispatcher.handle(message.message);
    final encoded = jsonEncode(response);
    await controller.runJavaScript(
      'window.dispatchEvent(new CustomEvent("place-note:native-response", '
      '{ detail: $encoded }));',
    );
  }

  void _retry() {
    setState(() {
      isLoading = true;
      hasLoadError = false;
    });
    controller.loadRequest(widget.webAppUri);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Place Note',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              if (!hasLoadError) WebViewWidget(controller: controller),
              if (hasLoadError) _LoadErrorView(onRetry: _retry),
              if (isLoading && !hasLoadError) const _LoadingView(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppTheme.paper,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _LoadErrorView extends StatelessWidget {
  const _LoadErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.paper,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const DotMark(size: 50),
              const SizedBox(height: 20),
              const Text(
                '연결이 필요합니다',
                style: TextStyle(
                  color: AppTheme.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '인터넷 연결을 확인한 뒤 다시 시도해주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.muted),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 160,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('다시 시도'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
