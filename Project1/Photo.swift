//
//  Photo.swift
//  Project1
//
//  Created by Mikhail Strizhenov on 18.04.2020.
//  Copyright © 2020 Mikhail Strizhenov. All rights reserved.
//

import Foundation


struct Photo: Codable {
    let caption: String
    let image: Data?
}
