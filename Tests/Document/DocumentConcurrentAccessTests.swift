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

import Combine
import XCTest
@testable import Yorkie

class DocumentConcurrentAccessTests: XCTestCase {
    func test_() async throws {
//        let expect = expectation(description: "")
//        expect.expectedFulfillmentCount = 2

        let target = Document(key: "doc-1")
        Task.detached {
            print("##1 start")
            await target.update { root in
                root.k1 = "1"
                sleep(5)
            }
            print("##1 end")
//            expect.fulfill()
        }

        Task.detached {
            print("##2 start")
            await target.update { root in
                root.k1 = "1"
                sleep(5)
            }
            print("##2 end")
//            expect.fulfill()
        }

//        wait(for: [expect], timeout: 100)
    }
}
