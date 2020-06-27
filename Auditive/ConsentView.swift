//// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI
import WebKit

//MARK:- Checkbox Field
struct CheckboxField: View {
  let label: String
  let callback: (Bool)->()
  @Binding var isMarked:Bool

  let size : CGFloat = 14
  let color = Color.black


  var body: some View {
    Button(action:{
      self.isMarked.toggle()
      self.callback(self.isMarked)
    }) {
      HStack(alignment: .center, spacing: 10) {
        Image(systemName: self.isMarked ? "checkmark.square" : "square")
          .renderingMode(.original)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: self.size, height: self.size)
        Text(label)
          .font(Font.system(size: self.size))
        Spacer()
      }.foregroundColor(self.color)
    }.background(Color.white).padding(10)
  }
}

struct ConsentView : View {
  @State private var webViewHeight : CGFloat = .zero
  @State var participate : Bool = false
  @State var dontParticipate : Bool = false
  @Binding var needsRefresh : Bool

  let buttonHeight : CGFloat = 60

  var body : some View {
    let consentFile = Bundle.main.url(forResource: "consent", withExtension: "html")
    let consent = try? String(contentsOf: consentFile!)
    return
      GeometryReader { g in
        ScrollView(.vertical, showsIndicators: true) {
          VStack(alignment: .center) {

            HTMLStringView( height: self.$webViewHeight, htmlContent: consent!).frame(height: self.webViewHeight)
            CheckboxField(
              label: "I agree to participate in this research study",
            callback: { z in
              print("agreed \(z)")
            }, isMarked: Binding(get: {self.participate}, set: {
              print("particpating \($0)")
                self.participate = $0
              self.dontParticipate = !$0
            }
            ) )
            CheckboxField(
              label:"I do not agree to participate",
            callback: { z in
              print("failed to agree \(z)")
            }, isMarked: Binding(get: {self.dontParticipate}, set: {
              print("particpating \($0)")
                self.participate = !$0
              self.dontParticipate = $0
            }
            ))

            if self.participate {
            Button(action: {
              if self.participate {
                uploadConsent()
                 self.needsRefresh = true

              }}) {
                VStack { Spacer()
                Text("Submit")
            .disabled( (!self.participate) )
                .foregroundColor(Color.black)
                  .frame(width: g.size.width)
                  Spacer()
                }.background( (!self.participate) && !self.dontParticipate ? Color.red : Color.green)

            }
              .frame(height: self.buttonHeight)
            } else {
              Spacer(minLength: self.buttonHeight)
            }
          }
        }
    }
  }
}

import WebKit
import SwiftUI

struct HTMLStringView: UIViewRepresentable {
  @Binding var height : CGFloat
  var webView: WKWebView = WKWebView()

  let htmlContent: String

  class Coordinator : NSObject, WKNavigationDelegate {
    var parent: HTMLStringView

    init(_ parent : HTMLStringView) {
      self.parent = parent
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      webView.evaluateJavaScript("document.documentElement.scrollHeight") {
        (height, error) in
        DispatchQueue.main.async {
          // print(height)
          //          let j = self.parent.frame
          //          let k = CGRect(origin: j.origin, size: CGSize(width: j.width, height: height as! CGFloat))
          self.parent.height = height as! CGFloat
        }
      }
    }

  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  func makeUIView(context: Context) -> WKWebView {
    webView.scrollView.bounces = false
    webView.navigationDelegate = context.coordinator
    return webView
  }

  func updateUIView(_ uiView: WKWebView, context: Context) {
    uiView.loadHTMLString(htmlContent, baseURL: nil)
  }
}

struct ConsentView_Previews: PreviewProvider {
  @State static var needsRefresh = false
  static var previews: some View {
    ConsentView(needsRefresh: $needsRefresh)
  }
}
