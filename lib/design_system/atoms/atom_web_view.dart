import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class AtomWebView extends StatefulWidget {
  const AtomWebView({required this.url, super.key});

  final String url;

  @override
  State<AtomWebView> createState() => _AtomWebViewState();
}

class _AtomWebViewState extends State<AtomWebView> {
  late final WebViewController _controller;
  bool isLoading = true;
  bool showEventsList = false;
  final List<Map<String, dynamic>> _events = [];
  int _eventCounter = 0;
  bool canGoBack = false;

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              isLoading = progress < 100;
            });
            _logEvent('Navigation', 'Loading progress: $progress%');
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            _logEvent('Navigation', 'Page started: $url');
            debugPrint('Page started loading: $url');
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            _logEvent('Navigation', 'Page finished: $url');
            debugPrint('Page finished loading: $url');
            setState(() {
              isLoading = false;
            });
            _updateBackButtonState();
            _injectEventListeners();
          },
          onWebResourceError: (WebResourceError error) {
            _logEvent('Error', 'Resource error: ${error.description} (Code: ${error.errorCode})');
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            _logEvent('Navigation', 'Navigation request: ${request.url}');
            if (request.url.startsWith('https://www.youtube.com/')) {
              _logEvent('Navigation', 'Blocked navigation to YouTube: ${request.url}');
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            _logEvent('Navigation', 'Allowed navigation to: ${request.url}');
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onHttpError: (HttpResponseError error) {
            _logEvent('HTTP Error', 'Status code: ${error.response?.statusCode}');
            debugPrint('Error occurred on page: ${error.response?.statusCode}');
          },
          onUrlChange: (UrlChange change) {
            _logEvent('URL Change', 'New URL: ${change.url}');
            debugPrint('url change to ${change.url}');
            _updateBackButtonState();
          },
          onHttpAuthRequest: (HttpAuthRequest request) {
            _logEvent('Auth', 'HTTP Auth request for: ${request.host}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          _logEvent('JS Channel', 'Toaster message: ${message.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..addJavaScriptChannel(
        'EventChannel',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final eventData = jsonDecode(message.message);
            _logEvent('JS Event', '${eventData['type']}: ${eventData['data'].toString()}');
          } catch (e) {
            _logEvent('JS Message', message.message);
          }
        },
      )
      ..loadRequest(Uri.parse(widget.url));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  Future<void> _updateBackButtonState() async {
    final canGoBack = await _controller.canGoBack();
    setState(() {
      this.canGoBack = canGoBack;
    });
  }

  Future<void> _handlePopInvoked(bool didPop, dynamic val) async {
    if (didPop) return;

    if (canGoBack) {
      await _controller.goBack();
      _logEvent('Navigation', 'Navigated back in WebView history');
    } else {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _logEvent(String type, String data) {
    setState(() {
      _eventCounter++;
      _events.add({
        'id': _eventCounter,
        'type': type,
        'data': data,
        'timestamp': DateTime.now().toString(),
      });
      if (_events.length > 500) {
        _events.removeAt(0);
      }
    });
    debugPrint('[$type] $data');
  }

  void _injectEventListeners() {
    _controller.runJavaScript('''
      (function() {
        if (window.eventListenersInjected) return;
        window.eventListenersInjected = true;
        
        console.log('Injecting event listeners...');
        
        function sendEvent(type, data) {
          try {
            EventChannel.postMessage(JSON.stringify({
              type: type,
              data: data,
              timestamp: new Date().toISOString()
            }));
          } catch(e) {
            console.error('Error sending event:', e);
          }
        }
        
        document.addEventListener('click', function(e) {
          sendEvent('click', {
            target: e.target.tagName,
            id: e.target.id || 'no-id',
            className: e.target.className || 'no-class',
            x: e.clientX,
            y: e.clientY,
            text: (e.target.textContent || '').substring(0, 50)
          });
        }, true);
        
        document.addEventListener('dblclick', function(e) {
          sendEvent('dblclick', {
            target: e.target.tagName,
            x: e.clientX,
            y: e.clientY
          });
        }, true);
        
        document.addEventListener('input', function(e) {
          sendEvent('input', {
            target: e.target.tagName,
            type: e.target.type || 'unknown',
            name: e.target.name || 'no-name',
            valueLength: (e.target.value || '').length
          });
        }, true);
        
        document.addEventListener('change', function(e) {
          sendEvent('change', {
            target: e.target.tagName,
            type: e.target.type || 'unknown',
            name: e.target.name || 'no-name'
          });
        }, true);
        
        document.addEventListener('submit', function(e) {
          sendEvent('submit', {
            target: e.target.tagName,
            action: e.target.action || 'no-action',
            method: e.target.method || 'GET'
          });
        }, true);
        
        document.addEventListener('focus', function(e) {
          sendEvent('focus', {
            target: e.target.tagName,
            id: e.target.id || 'no-id',
            type: e.target.type || 'unknown'
          });
        }, true);
        
        document.addEventListener('blur', function(e) {
          sendEvent('blur', {
            target: e.target.tagName,
            id: e.target.id || 'no-id'
          });
        }, true);
        
        let scrollTimeout;
        window.addEventListener('scroll', function(e) {
          clearTimeout(scrollTimeout);
          scrollTimeout = setTimeout(() => {
            sendEvent('scroll', {
              scrollX: Math.round(window.scrollX),
              scrollY: Math.round(window.scrollY),
              scrollPercentage: Math.round((window.scrollY / (document.body.scrollHeight - window.innerHeight)) * 100)
            });
          }, 150);
        });
        
        document.addEventListener('keydown', function(e) {
          sendEvent('keydown', {
            key: e.key,
            code: e.code,
            ctrlKey: e.ctrlKey,
            shiftKey: e.shiftKey,
            altKey: e.altKey,
            metaKey: e.metaKey
          });
        }, true);
        
        document.addEventListener('keyup', function(e) {
          sendEvent('keyup', {
            key: e.key,
            code: e.code
          });
        }, true);
        
        document.addEventListener('touchstart', function(e) {
          sendEvent('touchstart', {
            target: e.target.tagName,
            touches: e.touches.length,
            x: e.touches[0] ? Math.round(e.touches[0].clientX) : 0,
            y: e.touches[0] ? Math.round(e.touches[0].clientY) : 0
          });
        }, true);
        
        document.addEventListener('touchend', function(e) {
          sendEvent('touchend', {
            target: e.target.tagName,
            changedTouches: e.changedTouches.length
          });
        }, true);
        
        document.addEventListener('touchmove', function(e) {
          sendEvent('touchmove', {
            target: e.target.tagName,
            touches: e.touches.length
          });
        }, true);
        
        document.addEventListener('mouseenter', function(e) {
          sendEvent('mouseenter', {
            target: e.target.tagName,
            id: e.target.id || 'no-id'
          });
        }, true);
        
        document.addEventListener('mouseleave', function(e) {
          sendEvent('mouseleave', {
            target: e.target.tagName,
            id: e.target.id || 'no-id'
          });
        }, true);
        
        document.addEventListener('contextmenu', function(e) {
          sendEvent('contextmenu', {
            target: e.target.tagName,
            x: e.clientX,
            y: e.clientY
          });
        }, true);
        
        document.addEventListener('selectionchange', function(e) {
          const selection = window.getSelection();
          if (selection && selection.toString().length > 0) {
            sendEvent('textselection', {
              text: selection.toString().substring(0, 100),
              length: selection.toString().length
            });
          }
        });
        
        window.addEventListener('resize', function(e) {
          sendEvent('resize', {
            innerWidth: window.innerWidth,
            innerHeight: window.innerHeight
          });
        });
        
        document.addEventListener('visibilitychange', function(e) {
          sendEvent('visibilitychange', {
            hidden: document.hidden,
            visibilityState: document.visibilityState
          });
        });
        
        window.addEventListener('online', function(e) {
          sendEvent('network', { status: 'online' });
        });
        
        window.addEventListener('offline', function(e) {
          sendEvent('network', { status: 'offline' });
        });
        
        document.addEventListener('load', function(e) {
          if (e.target.tagName === 'IMG') {
            sendEvent('imageload', {
              src: e.target.src.substring(0, 100),
              width: e.target.naturalWidth,
              height: e.target.naturalHeight
            });
          }
        }, true);
        
        document.addEventListener('error', function(e) {
          if (e.target.tagName === 'IMG') {
            sendEvent('imageerror', {
              src: e.target.src.substring(0, 100)
            });
          }
        }, true);
        
        console.log('Event listeners injected successfully');
        sendEvent('system', { message: 'Event listeners initialized' });
      })();
    ''');
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    bottom: false,
    child: PopScope(
      canPop: !canGoBack,
      onPopInvokedWithResult: _handlePopInvoked,
      child: Scaffold(
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            Positioned(
              top: 50,
              right: 30,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFe7dff8).withOpacity(0.6),
                  ),
                  padding: const EdgeInsets.all(5),
                  child: const Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
