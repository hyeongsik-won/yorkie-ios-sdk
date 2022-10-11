/*
 * Copyright 2022 The Yorkie Authors. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
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
 * `TimeTicket` is a timestamp of the logical clock. Ticket is immutable.
 * It is created by `ChangeID`.
 */
struct TimeTicket: Comparable {
    private enum InitialValue {
        static let initialDelimiter: UInt32 = 0
        static let maxDelemiter: UInt32 = .max
        static let maxLamport: Int64 = .max
    }

    static let initial = TimeTicket(lamport: 0, delimiter: InitialValue.initialDelimiter, actorID: ActorIds.initialActorID)
    static let max = TimeTicket(lamport: InitialValue.maxLamport, delimiter: InitialValue.maxDelemiter, actorID: ActorIds.maxActorID)

    private var lamport: Int64
    private var delimiter: UInt32
    private var actorID: ActorID?

    init(lamport: Int64, delimiter: UInt32, actorID: ActorID?) {
        self.lamport = lamport
        self.delimiter = delimiter
        self.actorID = actorID
    }

    /**
     * `toIDString` returns the lamport string for this Ticket.
     */
    private func toIDString() -> String {
        guard let actorID = self.actorID else {
            return "\(self.lamport):nil:\(self.delimiter)"
        }
        return "\(self.lamport):\(actorID):\(self.delimiter)"
    }

    /**
     * `getStructureAsString` returns a string containing the meta data of the ticket
     * for debugging purpose.
     */
    func getStructureAsString() -> String {
        guard let actorID = self.actorID else {
            return "\(self.lamport):nil:\(self.delimiter)"
        }
        return "\(self.lamport):\(actorID):\(self.delimiter)"
    }

    /**
     * `setActor` changes actorID
     */
    mutating func setActor(actorID: ActorID) {
        self.actorID = actorID
    }

    /**
     * `getLamportAsString` returns the lamport string.
     */
    func getLamportAsString() -> String {
        return "\(self.lamport)"
    }

    /**
     * `getDelimiter` returns delimiter.
     */
    func getDelimiter() -> UInt32 {
        return self.delimiter
    }

    /**
     * `getActorID` returns actorID.
     */
    func getActorID() -> String? {
        return self.actorID
    }

    /**
     * `after` returns whether the given ticket was created later.
     */
    func after(_ other: TimeTicket) -> Bool {
        return self > other
    }

    static func < (lhs: TimeTicket, rhs: TimeTicket) -> Bool {
        if lhs.lamport != rhs.lamport {
            return lhs.lamport < rhs.lamport
        }

        if let lhsActorID = lhs.actorID, let rhsActorID = rhs.actorID, lhsActorID.localizedCompare(rhsActorID) != .orderedSame {
            return lhsActorID.localizedCompare(rhsActorID) == .orderedAscending
        }

        return lhs.delimiter < rhs.delimiter
    }
}

extension TimeTicket: Hashable {
    static func == (lhs: TimeTicket, rhs: TimeTicket) -> Bool {
        return lhs.toIDString() == rhs.toIDString()
    }
}

extension TimeTicket: CustomStringConvertible {
    var description: String {
        self.toIDString()
    }
}
