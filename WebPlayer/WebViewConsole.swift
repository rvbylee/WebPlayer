//
//  Untitled.swift
//  WebPlayer
//
//  Created by jht2 on 8/11/25.
//


import SwiftUI
import WebKit

// MARK: - SwiftUI View
struct WebViewWithConsoleLogging: View {
  @StateObject private var consoleLogger = ConsoleLogger()
  
  var body: some View {
    VStack {
      // Web View
      WebViewRepresentable(consoleLogger: consoleLogger)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      
      // Optional: Display console logs in UI
      if !consoleLogger.logs.isEmpty {
        Divider()
        
        ScrollView {
          LazyVStack(alignment: .leading, spacing: 4) {
            ForEach(consoleLogger.logs) { log in
              HStack(alignment: .top) {
                Text(log.icon)
                  .font(.caption)
                
                VStack(alignment: .leading, spacing: 2) {
                  Text(log.message)
                    .font(.caption)
                    .foregroundColor(log.color)
                  
                  Text(log.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
              }
              .padding(.horizontal, 8)
              .padding(.vertical, 2)
            }
          }
        }
        .frame(maxHeight: 150)
        .background(Color(.systemGray6))
      }
    }
    .navigationTitle("WebView Console")
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button("Clear") {
          consoleLogger.clearLogs()
        }
        .disabled(consoleLogger.logs.isEmpty)
      }
    }
  }
}

// MARK: - Console Log Model
struct ConsoleLog: Identifiable, Equatable {
  let id = UUID()
  let level: String
  let message: String
  let timestamp: Date
  let url: String?
  
  var icon: String {
    switch level {
    case "error": return "❌"
    case "warn": return "⚠️"
    case "info": return "ℹ️"
    case "debug": return "🐛"
    default: return "📝"
    }
  }
  
  var color: Color {
    switch level {
    case "error": return .red
    case "warn": return .orange
    case "info": return .blue
    case "debug": return .purple
    default: return .primary
    }
  }
}

// MARK: - Console Logger ObservableObject
class ConsoleLogger: ObservableObject {
  @Published var logs: [ConsoleLog] = []
  
  func addLog(level: String, message: String, timestamp: String? = nil, url: String? = nil) {
    let date: Date
    if let timestamp = timestamp, let parsedDate = ISO8601DateFormatter().date(from: timestamp) {
      date = parsedDate
    } else {
      date = Date()
    }
    
    let log = ConsoleLog(level: level, message: message, timestamp: date, url: url)
    
    DispatchQueue.main.async {
      self.logs.append(log)
      // Keep only last 100 logs to prevent memory issues
      if self.logs.count > 100 {
        self.logs.removeFirst(self.logs.count - 100)
      }
    }
  }
  
  func clearLogs() {
    logs.removeAll()
  }
}

// MARK: - UIViewRepresentable
struct WebViewRepresentable: UIViewRepresentable {
  let consoleLogger: ConsoleLogger
  
  func makeUIView(context: Context) -> WKWebView {
    let configuration = WKWebViewConfiguration()
    
    // Add script message handler for console logs
    configuration.userContentController.add(context.coordinator, name: "consoleLog")
    
    // Inject JavaScript to intercept console.log calls
    let consoleScript = """
            // Override console.log to send messages to native code
            (function() {
                // Store original methods
                const originalMethods = {
                    log: console.log,
                    warn: console.warn,
                    error: console.error,
                    info: console.info,
                    debug: console.debug
                };
                
                // Helper function to safely stringify arguments
                function stringifyArgs(args) {
                    return Array.from(args).map(arg => {
                        if (arg === null) return 'null';
                        if (arg === undefined) return 'undefined';
                        if (typeof arg === 'string') return arg;
                        if (typeof arg === 'number' || typeof arg === 'boolean') return String(arg);
                        if (typeof arg === 'function') return arg.toString();
                        
                        try {
                            return JSON.stringify(arg, null, 2);
                        } catch (e) {
                            // Handle circular references and other JSON errors
                            return Object.prototype.toString.call(arg);
                        }
                    }).join(' ');
                }
                
                // Override console methods
                Object.keys(originalMethods).forEach(method => {
                    console[method] = function() {
                        try {
                            const message = stringifyArgs(arguments);
                            
                            // Send to native code
                            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.consoleLog) {
                                window.webkit.messageHandlers.consoleLog.postMessage({
                                    level: method,
                                    message: message,
                                    timestamp: new Date().toISOString(),
                                    url: window.location.href
                                });
                            }
                            
                            // Also call original console method for debugging
                            originalMethods[method].apply(console, arguments);
                        } catch (e) {
                            originalMethods.error.call(console, 'Console override error:', e);
                        }
                    };
                });
                
                // Catch uncaught errors
                window.addEventListener('error', function(e) {
                    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.consoleLog) {
                        window.webkit.messageHandlers.consoleLog.postMessage({
                            level: 'error',
                            message: 'Uncaught Error: ' + e.message + (e.error && e.error.stack ? '\\n' + e.error.stack : ''),
                            timestamp: new Date().toISOString(),
                            url: window.location.href,
                            filename: e.filename,
                            lineno: e.lineno,
                            colno: e.colno
                        });
                    }
                });
                
                // Catch unhandled promise rejections
                window.addEventListener('unhandledrejection', function(e) {
                    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.consoleLog) {
                        window.webkit.messageHandlers.consoleLog.postMessage({
                            level: 'error',
                            message: 'Unhandled Promise Rejection: ' + e.reason,
                            timestamp: new Date().toISOString(),
                            url: window.location.href
                        });
                    }
                });
            })();
        """
    
    let script = WKUserScript(source: consoleScript, injectionTime: .atDocumentStart, forMainFrameOnly: false)
    configuration.userContentController.addUserScript(script)
    
    // Create WKWebView
    let webView = WKWebView(frame: .zero, configuration: configuration)
    
    // Load test HTML
    loadTestHTML(in: webView)
    
    return webView
  }
  
  func updateUIView(_ webView: WKWebView, context: Context) {
    // Update webview if needed
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(consoleLogger: consoleLogger)
  }
  
  private func loadTestHTML(in webView: WKWebView) {
    let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Console Log Test</title>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body { 
                    font-family: -apple-system, BlinkMacSystemFont, sans-serif; 
                    padding: 20px; 
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                    min-height: 100vh;
                    margin: 0;
                }
                .container {
                    max-width: 400px;
                    margin: 0 auto;
                    background: rgba(255,255,255,0.1);
                    padding: 30px;
                    border-radius: 15px;
                    backdrop-filter: blur(10px);
                }
                button {
                    background: rgba(255,255,255,0.2);
                    border: 1px solid rgba(255,255,255,0.3);
                    color: white;
                    padding: 12px 24px;
                    border-radius: 8px;
                    margin: 10px 5px;
                    cursor: pointer;
                    transition: all 0.3s ease;
                }
                button:hover {
                    background: rgba(255,255,255,0.3);
                    transform: translateY(-2px);
                }
                input {
                    width: 100%;
                    padding: 12px;
                    border: 1px solid rgba(255,255,255,0.3);
                    border-radius: 8px;
                    background: rgba(255,255,255,0.1);
                    color: white;
                    margin: 10px 0;
                }
                input::placeholder { color: rgba(255,255,255,0.7); }
                .log-section {
                    margin: 20px 0;
                    padding: 15px;
                    background: rgba(0,0,0,0.2);
                    border-radius: 8px;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>Console Log Test</h1>
                
                <div class="log-section">
                    <h3>Basic Logging</h3>
                    <button onclick="testBasicLogs()">Test Basic Logs</button>
                    <button onclick="testObjectLogs()">Test Object Logs</button>
                </div>
                
                <div class="log-section">
                    <h3>Error Testing</h3>
                    <button onclick="testError()">Test Error</button>
                    <button onclick="testPromiseError()">Test Promise Error</button>
                </div>
                
                <div class="log-section">
                    <h3>Custom Message</h3>
                    <input type="text" id="customMessage" placeholder="Enter custom message">
                    <button onclick="logCustomMessage()">Log Message</button>
                </div>
            </div>
            
            <script>
                console.log('🚀 Page loaded successfully');
                
                function testBasicLogs() {
                    console.log('Basic log message');
                    console.info('This is an info message');
                    console.warn('This is a warning message');
                    console.debug('This is a debug message');
                }
                
                function testObjectLogs() {
                    console.log('Object:', {name: 'John', age: 30, city: 'New York'});
                    console.log('Array:', [1, 2, 3, 'test', true]);
                    console.log('Multiple args:', 'string', 123, true, null, undefined);
                }
                
                function testError() {
                    console.error('This is an error message');
                    throw new Error('Test error for uncaught exception');
                }
                
                function testPromiseError() {
                    Promise.reject('Test promise rejection');
                }
                
                function logCustomMessage() {
                    const message = document.getElementById('customMessage').value;
                    if (message) {
                        console.log('Custom message:', message);
                        document.getElementById('customMessage').value = '';
                    }
                }
                
                // Automatic logging
                let counter = 0;
                setInterval(() => {
                    counter++;
                    console.log(`Automatic log #${counter} at ${new Date().toLocaleTimeString()}`);
                }, 5000);
                
                // Test circular reference handling
                setTimeout(() => {
                    const obj1 = {name: 'obj1'};
                    const obj2 = {name: 'obj2'};
                    obj1.ref = obj2;
                    obj2.ref = obj1;
                    console.log('Circular reference test:', obj1);
                }, 2000);
            </script>
        </body>
        </html>
        """
    
    webView.loadHTMLString(html, baseURL: nil)
  }
}

// MARK: - Coordinator
extension WebViewRepresentable {
  class Coordinator: NSObject, WKScriptMessageHandler {
    private let consoleLogger: ConsoleLogger
    
    init(consoleLogger: ConsoleLogger) {
      self.consoleLogger = consoleLogger
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
      guard message.name == "consoleLog" else { return }
      
      if let body = message.body as? [String: Any],
         let level = body["level"] as? String,
         let logMessage = body["message"] as? String {
        
        let timestamp = body["timestamp"] as? String
        let url = body["url"] as? String
        
        // Add to SwiftUI state
        consoleLogger.addLog(level: level, message: logMessage, timestamp: timestamp, url: url)
        
        // Also print to Xcode console
        let formattedMessage = "WebView \(level.uppercased()): \(logMessage)"
        switch level {
        case "error":
          print("❌ \(formattedMessage)")
        case "warn":
          print("⚠️ \(formattedMessage)")
        case "info":
          print("ℹ️ \(formattedMessage)")
        case "debug":
          print("🐛 \(formattedMessage)")
        default:
          print("📝 \(formattedMessage)")
        }
      }
    }
    
    deinit {
      // Cleanup is handled automatically by WKWebView
    }
  }
}

#Preview() {
  NavigationView {
    WebViewWithConsoleLogging()
  }
}

/*
 https://claude.ai/chat/ee7280f6-724e-4d93-9992-68015f97212a
 in WkWebView handle console.log calls
 convert to swiftui
 */
