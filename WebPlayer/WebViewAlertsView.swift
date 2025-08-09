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
    WebView(
      url: url,
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
    WebView(
      url: url,
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
    // !!@ removed _
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

// MARK: - Usage Examples
struct WebViewAlertsView: View {
  var body: some View {
    NavigationView {
      VStack(spacing: 20) {
        NavigationLink("Basic Alert Handling") {
          WebViewWithAlerts(url: URL(string: "https://example.com")!)
            .navigationTitle("Basic Alerts")
        }
        
        NavigationLink("Custom Styled Alerts") {
          StyledWebViewWithAlerts(url: URL(string: "https://example.com")!)
            .navigationTitle("Custom Alerts")
        }
      }
      .navigationTitle("WebView Alerts")
    }
  }
}

#Preview {
  WebViewAlertsView()
}

/*
 
 https://claude.ai/chat/6d205393-3949-4c29-8683-772c677510ca
 handling alert in WKWebView
 convert to swiftUI
 Referencing instance method 'onChange(of:initial:_:)' on 'Optional' requires that 'AlertData' conform to 'Equatable'
 Example url does not trigger alert, confirm or prompt
 


 */
