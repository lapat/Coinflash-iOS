//
//  StoryboardLoadable.swift
//  RxWallpaper
//
//  Created by quangpc on 1/23/18.
//  Copyright © 2018 Evolable Asia. All rights reserved.
//

import Foundation
import UIKit

protocol StoryboardLoadable {
    static var storyboardName: String {get}
    static func storyboardInstance<T>()-> T
}

