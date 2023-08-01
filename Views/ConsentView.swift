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
        Text("You are being asked to participate in a research study conducted by Kimberly Riegel at Farmingdale State College. You must be 18 years of age or older to participate in this research. The purpose of the study is to investigate the relationship between public health, mental health and noise exposure. A secondary purpose is the development of an app designed by the researchers to help investigate this topic. If you consent to participate, you will be asked to download this free app to your I-phone and complete a brief survey regarding some basic medical and mental health information about yourself and your family, and noise sensitivity information. You will also be asked demographic questions.")
      }.tag(1)
    VStack(alignment:.leading, spacing: 10) {
        Text("Additionally, you will be asked to record noise throughout your day for 20 seconds and then answer three questions about your level of control and annoyance. Finally, you will complete a post- survey regarding your experiences using the app. Participation should take 10 minutes to complete the initial survey and 5 minutes to complete the post surveys, and 20 seconds each time you complete a noise measurement.")
      }.tag(2)
      VStack(alignment:.leading, spacing: 10) {
      Text("There are no risks associated with this research beyond what one would experience in everyday life. However, after participating in this study, if you would like to speak with a qualified clinician, please contact your institution’s Campus Mental Health Services office listed below or your Primary Care Physician:")
          HStack(alignment: .top){Text("\u{2022}").font(.title).padding(.horizontal).frame(height: 40.0)
              Text("FSC’s Campus Mental Health Services at 934-420-2006").padding(.horizontal).frame(height: 50.0)}
          HStack(alignment: .top){Text("\u{2022}").font(.title).padding(.horizontal).frame(height: 40.0)
              Text("Queensborough Community College’s Counseling Center at 718-631-6370").padding(.horizontal).frame(height: 70.0)}

      }.tag(3)

      VStack(alignment: .leading, spacing: 10) {

        Text("Benefits of participation in this research include a better awareness of your overall noise exposure. Participants will receive 5 points toward their lowest average this semester in a course taught by Professor Riegel at FSC or Professor Resko at Queensborough Community College. Your participation in this study is voluntary as this assignment is optional, and it will not negatively impact your grade if you choose not to participate in the research. If you would like to earn extra credit but do not want to participate in the research project or if you have an android phone, you can complete the non-research assignment instead. This assignment will not be graded.")
      }.tag(4)

      VStack(alignment: .leading, spacing: 10) {

        Text("Only the post-survey will ask you to provide your name so that you will be awarded extra credit; however, your name will then be removed from the post-survey data. Otherwise, you will not be requested to provide any identifiable information during this study; however, the app used for this study will collect GPS location data when sound recordings are uploaded. These specific GPS locations will not be shared with anyone outside of the research team, and the researchers will not make any attempt to identify participants using this information. Collected GPS locations will only be reported in aggregate (i.e. general geographic locations) in any resulting publications and/or presentations. Additionally, there is a possibility that a participant could be unintentionally identified by the researchers via the collected demographic data; however, the study team will not actively attempt to identify any participants and if indirect identification does occur, the identity of the participant will not be recorded in the data set. Demographic information will also only be reported in aggregate in any resulting publications and/or presentations. You will not be identified in any resulting publications and/or presentations.")
      }.tag(5)

      VStack(alignment: .leading, spacing: 10) {
        Text("You may choose not to participate in the study or to drop out at any time without consequence. If you have any questions about the research, contact the Principal Investigator at riegelk@farmingdale.edu or (934)420-2081 or Farmingdale State College's IRB at 934-420-2687 or IRB@farmingdale.edu.")
      }.tag(6)

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
      }.tag(7)
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
        if selection < 7 {
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
