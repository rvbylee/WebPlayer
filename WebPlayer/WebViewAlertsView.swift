import SwiftUI
@preconcurrency import WebKit

// MARK: - Main SwiftUI View
struct WebViewWithAlerts: View {
  let url: URL
  @State private var showAlert = false
  @State private var showConfirm = false
  @State private var showPrompt = false
  @State private var alertMessage = ""
  @State private var promptText = ""
  @State private var promptDefaultText = ""
  
  // Completion handlers stored as state
  @State private var alertCompletion: (() -> Void)?
  @State private var confirmCompletion: ((Bool) -> Void)?
  @State private var promptCompletion: ((String?) -> Void)?
  
  var body: some View {
    WebViewWithHTML(
      htmlContent: TestHTMLGenerator.generateTestHTML(),
      onAlert: handleAlert,
      onConfirm: handleConfirm,
      onPrompt: handlePrompt
    )
    .alert("Alert", isPresented: $showAlert) {
      Button("OK") {
        alertCompletion?()
      }
    } message: {
      Text(alertMessage)
    }
    .alert("Confirm", isPresented: $showConfirm) {
      Button("OK") {
        confirmCompletion?(true)
      }
      Button("Cancel", role: .cancel) {
        confirmCompletion?(false)
      }
    } message: {
      Text(alertMessage)
    }
    .alert("Input Required", isPresented: $showPrompt) {
      TextField("Enter text", text: $promptText)
      Button("OK") {
        promptCompletion?(promptText)
      }
      Button("Cancel", role: .cancel) {
        promptCompletion?(nil)
      }
    } message: {
      Text(alertMessage)
    }
  }
  
  private func handleAlert(message: String, completion: @escaping () -> Void) {
    alertMessage = message
    alertCompletion = completion
    showAlert = true
  }
  
  private func handleConfirm(message: String, completion: @escaping (Bool) -> Void) {
    alertMessage = message
    confirmCompletion = completion
    showConfirm = true
  }
  
  private func handlePrompt(message: String, defaultText: String?, completion: @escaping (String?) -> Void) {
    alertMessage = message
    promptText = defaultText ?? ""
    promptDefaultText = defaultText ?? ""
    promptCompletion = completion
    showPrompt = true
  }
}

// MARK: - UIViewRepresentable WebView
struct WebView: UIViewRepresentable {
  let url: URL
  let onAlert: (String, @escaping () -> Void) -> Void
  let onConfirm: (String, @escaping (Bool) -> Void) -> Void
  let onPrompt: (String, String?, @escaping (String?) -> Void) -> Void
  
  func makeUIView(context: Context) -> WKWebView {
    let webView = WKWebView()
    webView.uiDelegate = context.coordinator
    return webView
  }
  
  func updateUIView(_ webView: WKWebView, context: Context) {
    let request = URLRequest(url: url)
    webView.load(request)
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(
      onAlert: onAlert,
      onConfirm: onConfirm,
      onPrompt: onPrompt
    )
  }
  
  class Coordinator: NSObject, WKUIDelegate {
    let onAlert: (String, @escaping () -> Void) -> Void
    let onConfirm: (String, @escaping (Bool) -> Void) -> Void
    let onPrompt: (String, String?, @escaping (String?) -> Void) -> Void
    
    init(
      onAlert: @escaping (String, @escaping () -> Void) -> Void,
      onConfirm: @escaping (String, @escaping (Bool) -> Void) -> Void,
      onPrompt: @escaping (String, String?, @escaping (String?) -> Void) -> Void
    ) {
      self.onAlert = onAlert
      self.onConfirm = onConfirm
      self.onPrompt = onPrompt
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
      onAlert(message, completionHandler)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
      onConfirm(message, completionHandler)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
      onPrompt(prompt, defaultText, completionHandler)
    }
  }
}

// MARK: - Enhanced Version with Custom Styling
struct StyledWebViewWithAlerts: View {
  let url: URL
  @State private var alertData: AlertData?
  
  var body: some View {
    WebViewWithHTML(
      htmlContent: TestHTMLGenerator.generateTestHTML(),
      onAlert: { message, completion in
        alertData = AlertData(
          type: .alert,
          message: message,
          alertCompletion: completion
        )
      },
      onConfirm: { message, completion in
        alertData = AlertData(
          type: .confirm,
          message: message,
          confirmCompletion: completion
        )
      },
      onPrompt: { message, defaultText, completion in
        alertData = AlertData(
          type: .prompt,
          message: message,
          defaultText: defaultText,
          promptCompletion: completion
        )
      }
    )
    .customAlert(alertData: $alertData)
  }
}

// MARK: - WebView with HTML Content
struct WebViewWithHTML: UIViewRepresentable {
  let htmlContent: String
  let onAlert: (String, @escaping () -> Void) -> Void
  let onConfirm: (String, @escaping (Bool) -> Void) -> Void
  let onPrompt: (String, String?, @escaping (String?) -> Void) -> Void
  
  func makeUIView(context: Context) -> WKWebView {
    let webView = WKWebView()
    webView.uiDelegate = context.coordinator
    return webView
  }
  
  func updateUIView(_ webView: WKWebView, context: Context) {
    webView.loadHTMLString(htmlContent, baseURL: nil)
  }
  
  func makeCoordinator() -> WebView.Coordinator {
    WebView.Coordinator(
      onAlert: onAlert,
      onConfirm: onConfirm,
      onPrompt: onPrompt
    )
  }
}

// MARK: - Alert Data Model
struct AlertData: Equatable {
  enum AlertType: Equatable {
    case alert, confirm, prompt
  }
  
  let id = UUID() // Add unique identifier
  let type: AlertType
  let message: String
  let defaultText: String?
  let alertCompletion: (() -> Void)?
  let confirmCompletion: ((Bool) -> Void)?
  let promptCompletion: ((String?) -> Void)?
  
  init(
    type: AlertType,
    message: String,
    defaultText: String? = nil,
    alertCompletion: (() -> Void)? = nil,
    confirmCompletion: ((Bool) -> Void)? = nil,
    promptCompletion: ((String?) -> Void)? = nil
  ) {
    self.type = type
    self.message = message
    self.defaultText = defaultText
    self.alertCompletion = alertCompletion
    self.confirmCompletion = confirmCompletion
    self.promptCompletion = promptCompletion
  }
  
  // Equatable conformance - compare only data properties, not closures
  static func == (lhs: AlertData, rhs: AlertData) -> Bool {
    return lhs.id == rhs.id &&
    lhs.type == rhs.type &&
    lhs.message == rhs.message &&
    lhs.defaultText == rhs.defaultText
  }
}

// MARK: - Custom Alert Modifier
struct CustomAlertModifier: ViewModifier {
  @Binding var alertData: AlertData?
  @State private var textInput: String = ""
  
  func body(content: Content) -> some View {
    content
      .sheet(item: Binding<AlertItem?>(
        get: { alertData.map(AlertItem.init) },
        set: { _ in alertData = nil }
      )) { item in
        CustomAlertView(
          alertData: item.data,
          textInput: $textInput,
          onDismiss: { alertData = nil }
        )
      }
      .onChange(of: alertData) { newValue in
        if let data = newValue {
          textInput = data.defaultText ?? ""
        }
      }
  }
}

struct AlertItem: Identifiable {
  let id = UUID()
  let data: AlertData
}

extension View {
  func customAlert(alertData: Binding<AlertData?>) -> some View {
    modifier(CustomAlertModifier(alertData: alertData))
  }
}

// MARK: - Custom Alert View
struct CustomAlertView: View {
  let alertData: AlertData
  @Binding var textInput: String
  let onDismiss: () -> Void
  
  var body: some View {
    VStack(spacing: 20) {
      Text("Website Message")
        .font(.headline)
        .padding(.top)
      
      Text(alertData.message)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
      
      if alertData.type == .prompt {
        TextField("Enter text", text: $textInput)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .padding(.horizontal)
      }
      
      HStack(spacing: 15) {
        if alertData.type == .confirm || alertData.type == .prompt {
          Button("Cancel") {
            alertData.confirmCompletion?(false)
            alertData.promptCompletion?(nil)
            onDismiss()
          }
          .foregroundColor(.red)
        }
        
        Button("OK") {
          switch alertData.type {
          case .alert:
            alertData.alertCompletion?()
          case .confirm:
            alertData.confirmCompletion?(true)
          case .prompt:
            alertData.promptCompletion?(textInput)
          }
          onDismiss()
        }
        .foregroundColor(.blue)
      }
      .padding(.bottom)
    }
    .frame(maxWidth: 300)
    .background(Color(.systemBackground))
    .cornerRadius(12)
    .shadow(radius: 10)
    .padding()
  }
}

// MARK: - Test HTML Generator
class TestHTMLGenerator {
  static func generateTestHTML() -> String {
    return """
        <!DOCTYPE html>
        <html>
        <head>
            <title>WebView Alert Test</title>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                    padding: 20px;
                    background-color: #f5f5f5;
                }
                .container {
                    max-width: 400px;
                    margin: 0 auto;
                    background: white;
                    padding: 20px;
                    border-radius: 10px;
                    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                }
                button {
                    display: block;
                    width: 100%;
                    padding: 15px;
                    margin: 10px 0;
                    font-size: 16px;
                    border: none;
                    border-radius: 8px;
                    cursor: pointer;
                    transition: background-color 0.3s;
                }
                .alert-btn { background-color: #007AFF; color: white; }
                .confirm-btn { background-color: #FF9500; color: white; }
                .prompt-btn { background-color: #34C759; color: white; }
                button:hover { opacity: 0.8; }
                .result { 
                    margin-top: 20px; 
                    padding: 10px; 
                    background-color: #f0f0f0; 
                    border-radius: 5px;
                    min-height: 20px;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h2>WebView Alert Test Page</h2>
                <p>Click the buttons below to test different JavaScript dialogs:</p>
                
                <button class="alert-btn" onclick="testAlert()">
                    Test Alert Dialog
                </button>
                
                <button class="confirm-btn" onclick="testConfirm()">
                    Test Confirm Dialog
                </button>
                
                <button class="prompt-btn" onclick="testPrompt()">
                    Test Prompt Dialog
                </button>
                
                <button class="alert-btn" onclick="testMultiple()">
                    Test Multiple Alerts
                </button>
                
                <div id="result" class="result">
                    Results will appear here...
                </div>
            </div>
            
            <script>
                function testAlert() {
                    alert('This is a JavaScript alert!\\n\\nIt should be handled by your WKWebView delegate.');
                    document.getElementById('result').innerHTML = 'Alert dialog was shown';
                }
                
                function testConfirm() {
                    const result = confirm('Do you want to proceed?\\n\\nClick OK or Cancel to test the confirm dialog.');
                    document.getElementById('result').innerHTML = `Confirm result: ${result ? 'OK was clicked' : 'Cancel was clicked'}`;
                }
                
                function testPrompt() {
                    const result = prompt('Please enter your name:', 'Default Name');
                    document.getElementById('result').innerHTML = `Prompt result: ${result !== null ? `"${result}"` : 'Cancelled'}`;
                }
                
                function testMultiple() {
                    alert('First alert');
                    if (confirm('Show second alert?')) {
                        const name = prompt('Enter your name:');
                        alert(`Hello, ${name || 'Anonymous'}!`);
                    }
                    document.getElementById('result').innerHTML = 'Multiple dialog sequence completed';
                }
                
                // Auto-run a test alert after 2 seconds
                setTimeout(() => {
                    if (confirm('Welcome! This page will test JavaScript dialogs.\\n\\nClick OK to continue or Cancel to skip auto-tests.')) {
                        document.getElementById('result').innerHTML = 'Welcome dialog completed - try the buttons above!';
                    }
                }, 2000);
            </script>
        </body>
        </html>
        """
  }
}

// MARK: - Usage Examples
struct WebViewAlertsView: View {
  var body: some View {
    NavigationView {
      VStack(spacing: 20) {
        NavigationLink("Basic Alert Handling") {
          TestWebView(useCustomStyling: false)
            .navigationTitle("Basic Alerts")
        }
        
        NavigationLink("Custom Styled Alerts") {
          TestWebView(useCustomStyling: true)
            .navigationTitle("Custom Alerts")
        }
      }
      .navigationTitle("WebView Alerts")
    }
  }
}

// MARK: - Test WebView with Local HTML
struct TestWebView: View {
  let useCustomStyling: Bool
  @State private var webView: WKWebView?
  
  var body: some View {
    VStack {
      if useCustomStyling {
        StyledWebViewWithAlerts(url: URL(string: "about:blank")!)
          .onAppear {
            loadTestHTML()
          }
      } else {
        WebViewWithAlerts(url: URL(string: "about:blank")!)
          .onAppear {
            loadTestHTML()
          }
      }
    }
    .navigationBarTitleDisplayMode(.inline)
  }
  
  private func loadTestHTML() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      // Find the webview and load HTML
      if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
         let window = windowScene.windows.first {
        loadHTMLInWebView(in: window.rootViewController)
      }
    }
  }
  
  private func loadHTMLInWebView(in viewController: UIViewController?) {
    guard let vc = viewController else { return }
    
    // Recursively find WKWebView
    func findWebView(in view: UIView) -> WKWebView? {
      if let webView = view as? WKWebView {
        return webView
      }
      for subview in view.subviews {
        if let webView = findWebView(in: subview) {
          return webView
        }
      }
      return nil
    }
    
    if let webView = findWebView(in: vc.view) {
      let html = TestHTMLGenerator.generateTestHTML()
      webView.loadHTMLString(html, baseURL: nil)
    } else {
      // Try in child view controllers
      for child in vc.children {
        loadHTMLInWebView(in: child)
      }
    }
  }
}

#Preview {
  WebViewAlertsView()
}
