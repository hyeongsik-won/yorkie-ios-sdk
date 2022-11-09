/*
 * Copyright 2022 The Yorkie Authors. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License")
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation

/**
 * `MoveOperation` is an operation representing moving an element to an Array.
 */
class MoveOperation: Operation {
    let parentCreatedAt: TimeTicket
    var executedAt: TimeTicket
    /// The creation time of previous element.
    let previousCreatedAt: TimeTicket
    let createdAt: TimeTicket

    init(parentCreatedAt: TimeTicket, previousCreatedAt: TimeTicket, createdAt: TimeTicket, executedAt: TimeTicket) {
        self.parentCreatedAt = parentCreatedAt
        self.executedAt = executedAt
        self.previousCreatedAt = previousCreatedAt
        self.createdAt = createdAt
    }

    /**
     * `execute` executes this operation on the given document(`root`).
     */
    func execute(root: CRDTRoot) throws {
        let parent = root.find(createdAt: self.parentCreatedAt)
        guard let array = parent as? CRDTArray else {
            let log: String
            if parent == nil {
                log = "fail to find \(self.parentCreatedAt)"
            } else {
                log = "fail to execute, only array can execute add"
            }
            Logger.fatal(log)
            throw YorkieError.unexpected(message: log)
        }

        try array.move(createdAt: self.createdAt, afterCreatedAt: self.previousCreatedAt, executedAt: self.executedAt)
    }

    /**
     * `effectedCreatedAt` returns the time of the effected element.
     */
    var effectedCreatedAt: TimeTicket {
        return self.createdAt
    }

    /**
     * `structureAsString` returns a string containing the meta data.
     */
    var structureAsString: String {
        return "\(self.parentCreatedAt.structureAsString).MOV"
    }
}
