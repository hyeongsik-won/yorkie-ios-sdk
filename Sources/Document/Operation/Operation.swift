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
 * `Operation` represents an operation to be executed on a document.
 */
protocol Operation: AnyObject {
    /// `parentCreatedAt` returns the creation time of the target element to
    var parentCreatedAt: TimeTicket { get }
    /// `executedAt` returns execution time of this operation.
    var executedAt: TimeTicket { get set }

    /**
     * `effectedCreatedAt` returns the time of the effected element.
     */
    var effectedCreatedAt: TimeTicket { get }

    /**
     * `structureAsString` returns a string containing the meta data.
     */
    var structureAsString: String { get }

    /**
     * `execute` executes this operation on the given document(`root`).
     */
    func execute(root: CRDTRoot) throws
}

extension Operation {
    /**
     * `setActor` sets the given actor to this operation.
     */
    func setActor(_ actorID: ActorID) {
        self.executedAt.setActor(actorID)
    }
}
