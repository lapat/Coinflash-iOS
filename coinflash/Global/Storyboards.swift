//
//  Storyboards.swift
//  SimpleFares
//
//  Created by quangpc on 3/1/18.
//  Copyright © 2018 quangpc. All rights reserved.
//

import Foundation
import UIKit

extension StoryboardLoadable {
    static func storyboardInstance<T>()-> T {
        let st = UIStoryboard(name: Self.storyboardName, bundle: nil)
        guard let vc = st.instantiateViewController(withIdentifier: String(describing: self.self)) as? T else {
            fatalError()
        }
        return vc
    }
}

protocol AuthenStoryboardInstance: StoryboardLoadable {}

extension AuthenStoryboardInstance {
    static var storyboardName: String {
        return "Authen"
    }
}

protocol MainStoryboardInstance: StoryboardLoadable {}

extension MainStoryboardInstance {
    static var storyboardName: String {
        return "Main"
    }
}

protocol MainNewStoryboardInstance: StoryboardLoadable {}

extension MainNewStoryboardInstance {
    static var storyboardName: String {
        return "MainNew"
    }
}
