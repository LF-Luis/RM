//
//  AppOnboarding.swift
//  TestingOnboard
//
//  Created by Luis Fernandez on 8/5/17.
//  Copyright © 2017 Luis Fernandez. All rights reserved.
//

import UIKit
import Onboard

class AppOnboarding: OnboardingViewController {
    
    func onboardingViewController(skipAllowed: Bool, skipHandle: (() -> ())?, logInHandle: (() -> ())?) {
        
        /*
         This class function returns an OnboardingViewController that can be used at any time. However, the purpose of use is only when the User is not logged in and when the User wants to get more information on how the app works.
         When skipAllowed is false, the logInHandle should lead the user to LogIn (skipHandle should be nil).
         When skipAllowed is true, the skipHandle should exit onboarding (logInHandle should be nil).
         */
        
        let backgroundImg = UIImage(named: "whiteBackground")
        
        let firstPageImg = UIImage(named: "MainDisplay")
        
        let secondPageImg = UIImage(named: "AddRoom")
        let thirdPageImg = UIImage(named: "AddEvent")
        let lastPageImg = UIImage(named: "EditRoom")
        
        let firstPage = OnboardingContentViewController(title: "RM:Study\nWelcome!", body: "A new way for students to study on campus while exploring their surroundings.", image: firstPageImg, buttonText: nil, action: nil)
        
        firstPage.iconImageView.clipsToBounds = true
        firstPage.iconImageView.contentMode = .scaleAspectFill
        
        let secondPage = OnboardingContentViewController(title: "Live Crowdsourced Data", body: "Up-to-date Information About Available Study Rooms And School Events Around You.", image: secondPageImg, buttonText: nil, action: nil)
        
        secondPage.iconImageView.clipsToBounds = true
        secondPage.iconImageView.contentMode = .scaleAspectFill
        
        let thirdPage = OnboardingContentViewController(title: "Add A Rooms Or Events", body: "RM Relies On User Input To Grow. Help Us Help You Have More Information.", image: thirdPageImg, buttonText: nil, action: nil)
        
        thirdPage.iconImageView.clipsToBounds = true
        thirdPage.iconImageView.contentMode = .scaleAspectFill
        
        var lastPage = OnboardingContentViewController()
        
        if skipAllowed {
            lastPage = OnboardingContentViewController(title: "Edit A Rooms Or Event", body: "Quickly View And/Or Edit.", image: lastPageImg, buttonText: "Done") {
                if skipHandle != nil {
                    skipHandle!()
                }
                else {
                    print("LF ERROR: AppOnboarding skip allowed but no handle was passed")
                }
            }
        }
        else {
            lastPage = OnboardingContentViewController(title: "Edit A Room Or Event", body: "Quickly View And/Or Edit.", image: lastPageImg, buttonText: "Log In") {
                if logInHandle != nil {
                    logInHandle!()
                }
                else {
                    print("LF ERROR: AppOnboarding skip allowed but no handle was passed")
                }
            }
        }
        
        lastPage.iconImageView.clipsToBounds = true
        lastPage.iconImageView.contentMode = .scaleAspectFill
        
        let iconWidth = AppSize.screenWidth * 0.7
        let iconHeight = AppSize.screenHeight * 0.65
        let a = AppSize.screenHeight * (1.25/40)
        let b = AppSize.screenHeight * (2/40)
        let c = AppSize.screenHeight * (3/40)
        let topPadding = a + (1.8*b)
        let underTitlePadding = iconHeight + c
        let underIconPadding = -(iconHeight) - (b) - a
        let titleTextSize = AppSize.screenHeight * (24/568)
        let bodyTextSize = AppSize.screenHeight * (20/568)
        let titleLabelFont = UIFont(name: "AppleSDGothicNeo-Bold", size: titleTextSize)
        
        let bodyLabelFont = UIFont(name: "AppleSDGothicNeo-Regular", size: bodyTextSize)
        
        firstPage.iconWidth = iconWidth
        firstPage.iconHeight = iconHeight
        firstPage.titleLabel.font = titleLabelFont
        firstPage.bodyLabel.font = bodyLabelFont
        firstPage.titleLabel.textColor = .black
        firstPage.bodyLabel.textColor = .black
        firstPage.topPadding = topPadding + a
//        firstPage.bottomPadding = bottomPadding
        firstPage.underTitlePadding = underTitlePadding - (1.8 * a)
        firstPage.underIconPadding = underIconPadding - (a)
        
        secondPage.iconWidth = iconWidth
        secondPage.iconHeight = iconHeight
        secondPage.titleLabel.font = titleLabelFont
        secondPage.bodyLabel.font = bodyLabelFont
        secondPage.titleLabel.textColor = .black
        secondPage.bodyLabel.textColor = .black
        secondPage.topPadding = topPadding
//        secondPage.bottomPadding = bottomPadding
        secondPage.underTitlePadding = underTitlePadding
        secondPage.underIconPadding = underIconPadding
        
        thirdPage.iconWidth = iconWidth
        thirdPage.iconHeight = iconHeight
        thirdPage.titleLabel.font = titleLabelFont
        thirdPage.bodyLabel.font = bodyLabelFont
        thirdPage.titleLabel.textColor = .black
        thirdPage.bodyLabel.textColor = .black
        thirdPage.topPadding = topPadding
//        thirdPage.bottomPadding = bottomPadding
        thirdPage.underTitlePadding = underTitlePadding
        thirdPage.underIconPadding = underIconPadding
        
        lastPage.iconWidth = iconWidth
        lastPage.iconHeight = iconHeight
        lastPage.titleLabel.font = titleLabelFont
        lastPage.bodyLabel.font = bodyLabelFont
        lastPage.titleLabel.textColor = .black
        lastPage.bodyLabel.textColor = .black
        lastPage.topPadding = topPadding
//        lastPage.bottomPadding = bottomPadding
        lastPage.underTitlePadding = underTitlePadding
        lastPage.underIconPadding = underIconPadding
        lastPage.actionButton.backgroundColor = .black
        
        // Default (edited)
        self.swipingEnabled = true
//        self.shouldMaskBackground = true
        self.backgroundImage = backgroundImg
        self.shouldBlurBackground = false
        self.shouldMaskBackground = false
        self.shouldFadeTransitions = true
        self.viewControllers = [firstPage, secondPage, thirdPage, lastPage]
        
        // - FIXME: Cannot get superclass' skip button 
        if skipAllowed {
            
            // allow exit button in every page
            self.allowSkipping = true
//            self.skipButton = UIButton()
//            skipButtonHandler = skipHandle!
//            self.skipButton = self.skipButton!
            self.fadeSkipButtonOnLastPage = true
//            skipButton.addTarget(self, action: #selector(buttonAction(stringgg:"newI")), for: .touchUpInside)
            
//            skipButton.
//            self.skipHandler = {
//                if skipHandle != nil {
//                    skipHandle!()
//                }
//                else {
//                    print("LF ERROR: AppOnboarding skip allowed but no handle was passed")
//                }
//            }
//            self.skipButton.setTitle("Exit", for: .normal)
//            self.skipButton.backgroundColor = .black
        }
        else {
            // user is not allowed to skip pages
            self.allowSkipping = false
        }

    }
    
}



