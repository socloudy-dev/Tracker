import UIKit

struct OnboardingPageModel {
    let image : UIImage?
    let text : String
}

extension OnboardingPageModel {
    static let aboutTracking = OnboardingPageModel(image: UIImage(resource: .onboarding1),
                                        text: "Отслеживайте только то, что хотите")
    static let aboutWaterAndYoga = OnboardingPageModel(image: UIImage(resource: .onboarding2),
                                             text: "Даже если это \n не литры воды и йога")
}
