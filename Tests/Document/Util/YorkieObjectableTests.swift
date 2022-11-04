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

import Combine
import XCTest
@testable import Yorkie

struct KanbanColumn: YorkieObjectable {
    let title: String
    var cards: [KanbanCard] = []
}

struct KanbanCard: YorkieObjectable {
    let title: String
}

class YorkieObjectableTests: XCTestCase {
    func test_() async {
        let lists: [KanbanColumn] = [
            KanbanColumn(title: "a", cards: [
                KanbanCard(title: "a-1"),
                KanbanCard(title: "a-2")
            ]),
            KanbanColumn(title: "b", cards: [
                KanbanCard(title: "b-1"),
                KanbanCard(title: "b-2")
            ])
        ]

        let doc = Document(key: "test")
        await doc.update { root in
            root.lists = lists.toYorkieArray

            XCTAssertEqual(root.debugDescription,
                           """
                           {"lists":[{"title":"a","cards":[{"title":"a-1"},{"title":"a-2"}]},{"cards":[{"title":"b-1"},{"title":"b-2"}],"title":"b"}]}
                           """)
        }
    }
}
