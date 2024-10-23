//
//  DataError.swift
//  Libro
//
//  Created by Patryk Danielewicz on 07/10/2024.
//

import Foundation

enum DataError: Error {
    case snapshotNotFound(String)
    case uploadImageError(String)
}
