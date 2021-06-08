// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI

struct ConsentView : View {
  @State private var webViewHeight : CGFloat = .zero
  @State var participate : Int? = nil
  @State var selection : Int = 1

  let buttonHeight : CGFloat = 60

  var body : some View {
    VStack {
    TabView(selection: $selection) {
      VStack(alignment:.leading, spacing: 10) {
        Image("logo").resizable().scaledToFit().frame(maxWidth: 120).padding(0)
        Text("We are asking you to participate in a research study titled “Urban Noise: Noise Awareness Study”")
        Text("The purpose of this study is to correlate urban sound levels and noises to annoyance levels and incidents of chronic health problems and the awareness of noise. We are trying to obtain large amounts of data in a variety of listening environments and from a variety of listeners to determine the correlations between several key factors which are historically difficult to capture. These parameters include physical health history, mental health history, annoyance, sound level exposure, characteristics of the sound, awareness of noise exposure, and types of sound.")
      }.tag(1)
      VStack(alignment:.leading, spacing: 10) {
      Text("If you volunteer for this study, we will ask you to download the Auditive app to your cell phone.  If you agree to participate in this study you will then be asked a series of medical and mental health history questions.  Once you have completed that survey you will be asked to measure the sound levels throughout your day.  You may make as many sound measurements as you would like.  After each measurement, a short three-question survey asking about your perception and annoyance of the sound will be given.  Once this survey is complete the sound file, as well as your responses, will be sent to a central server the next time your phone is connected to a wifi network.")

      }.tag(2)

      VStack(alignment: .leading, spacing: 10) {
        Text("Risks and confidentiality").fontWeight(.bold)

        Text("The application does not collect any identifiable information. Due to the format of this application, risks in a breach of confidentiality may occur due to a rare case of hacking. Please know that all information you provide will be safely stored and coded. The research team and authorized CUNY staff may have access to research data and records in order to monitor the research. Publications and/or presentations that result from this study will not identify you.")
      }.tag(3)

      VStack(alignment: .leading, spacing: 10) {
        Text("Participant Benefits & Rights").fontWeight(.bold)

        Text("There are no direct benefits to the respondent at this time.  However, information from this study will be used to offer some guidance to urban planners and environmental engineers to focus on particular sounds that cause physical and mental hardships on a community scale.")

        Text("Your participation in this study is voluntary.  You can refuse to participate before the study begins or discontinue your involvement at any time.  You will not be penalized in any way for not participating in this study.")

      }.tag(4)

      VStack(alignment: .leading, spacing: 10) {
        Text("If you have questions").fontWeight(.bold)
        Text("The main researcher conducting this study is Kimberly Riegel, a professor at Queensborough Community College. If you have any questions related to the research you may contact Kimberly Riegel at kriegel@qcc.cuny.edu or at (718) 631-6312.")
        Text("If you have questions about your rights as a research participant, or you have comments or concerns that you would like to discuss with someone other than the researchers, please contact")
        Text("QCC HRPP Coordinator, Anissa Moody,\nat (718) 631-6296 / amoody@qcc.cuny.edu")
          .padding([.leading, .trailing], 15)
          .font(.system(size: 14))

        Text("or call the CUNY Research Compliance Administrator at (646) 664-8918.")

        Text("Alternatively, you can write to:")

        Text("CUNY Office of the Vice Chancellor for Research \nAttn: Research Compliance Administrator \n205 East 42nd Street \nNew York, NY 10017").padding([.leading,.trailing], 15).font(.system(size: 14))
      }.tag(5)

      VStack(alignment: .leading, spacing: 10) {
        Text("Statement of Consent").fontWeight(.bold)
        Text("Please click the 'I approve' box if you have read and understood the above information and have received answers to your questions")

        RadioCheckField(
          label: "I approve and agree to participate in this research study",
          id: 0,
          marked: $participate
          )
        RadioCheckField(
          label:"I do not agree to participate",
          id : 1,
          marked: $participate)

        // if self.participate == 0 {
          Button(action: {
                  if self.participate == 0 {
                    uploadConsent()
                  }}) {
            VStack {
              Spacer()
              Text("Submit")
                .disabled( (self.participate != 0) )
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity)
//                .frame(width: g.size.width)
              Spacer()
            }.background( self.participate == 0 ? Color.green : Color.red)

          }
          .frame(height: self.buttonHeight)
//        } else {
//          Spacer(minLength: self.buttonHeight)
//        }


      }.tag(6)
    }
    .padding(EdgeInsets.init(top: 0, leading: 15, bottom: 0, trailing: 15))
    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    .tabViewStyle(PageTabViewStyle.init(indexDisplayMode: .always))

      HStack {
        Button(action: {
          selection -= 1
        }) {
          if selection > 1 {
            Text("Back")
          } else {
            EmptyView()
          }
        }.frame(maxWidth:.infinity)

      Button(action: {
        selection += 1
      }) {
        if selection < 6 {
          Text("Next")
        } else {
        EmptyView()
        }
      }.frame(maxWidth:.infinity)
    }
    }

    /*
            if self.participate {
              Button(action: {
                      if self.participate {
                        uploadConsent()
                        NotificationCenter.default.post(Notification(name: .savedConsent))
                      }}) {
                VStack { Spacer()
                  Text("Submit")
                    .disabled( (!self.participate) )
                    .foregroundColor(Color.black)
                    .frame(width: g.size.width)
                  Spacer()
                }.background( (!self.participate) && !self.dontParticipate ? Color.red : Color.green)

              }
 */
  }
}
