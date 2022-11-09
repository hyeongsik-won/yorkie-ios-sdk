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

import XCTest
@testable import Yorkie

class JSONArrayTests: XCTestCase {
    func test_can_append() async {
        let target = Document(key: "doc1")
        await target.update { root in
            await root.set(key: "array", value: JSONArray())
            let array = await root.get(key: "array") as? JSONArray

            let resultID = await array?.getID()
            XCTAssertNotNil(resultID)

            let int64Index = (await array?.append(Int64(1)) ?? 0) - 1

            let value = await array?[int64Index] as? Int64
            XCTAssertEqual(value, 1)

            await array?.append(Int32(2))
            await array?.append("a")
            await array?.append(Double(1.2345))
            await array?.append(true)
            let arrayValueIndex = (await array?.append([Int32(11), Int32(12), Int32(13)]) ?? 0) - 1
            let arrayValue = await array?[arrayValueIndex] as? JSONArray
            await arrayValue?.append(values: [Int32(21), Int32(22), Int32(23)])

            let result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"array":[1,2,"a",1.2345,"true",[11,12,13,21,22,23]]}
                           """)
        }
    }

    func test_can_append_with_array() async {
        let target = Document(key: "doc1")
        await target.update { root in
            await root.set(key: "array", value: [Int32(1), Int32(2), Int32(3)])
            let array = await root.array as? JSONArray
            await array?.append(Int32(4))
            await array?.append(values: [Int32(5), Int32(6)])
            let result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"array":[1,2,3,4,5,6]}
                           """)
        }
    }

    func test_can_get_element_by_id_and_index() async {
        let target = Document(key: "doc1")
        await target.update { root in
            await root.set(key: "array", value: [Int32(1), Int32(2), Int32(3)])
            let array = await root.array as? JSONArray
            let element = await array?.getElement(byIndex: 0) as? Primitive
            XCTAssertNotNil(element)

            let elementById = await array?.getElement(byID: element!.getCreatedAt())
            XCTAssertNotNil(elementById)
        }
    }

    func test_can_get_last() async {
        let target = Document(key: "doc1")
        await target.update { root in
            await root.set(key: "array", value: [Int32(1), Int32(2), Int32(3)])
            let array = await root.array as? JSONArray
            guard let primitive = await array?.getLast() as? Primitive else {
                XCTFail("primitive is nil.")
                return
            }
            switch primitive.value {
            case .integer(let value):
                XCTAssertEqual(value, 3)
            default:
                XCTFail("value is not equal.")
            }
        }
    }

    func test_can_insert_into_after() async {
        let target = Document(key: "doc1")
        await target.update { root in
            await root.set(key: "array", value: [Int32(1), Int32(2), Int32(3)])
            let array = await root.array as? JSONArray
            guard let firstElement = await array?.getElement(byIndex: 0) as? Primitive else {
                XCTFail("getElement(byIndex:) is nil.")
                return
            }

            let insertedElement = try? await array?.insertAfter(previousID: firstElement.getCreatedAt(), value: [Int32(11), Int32(12), Int32(13)])
            XCTAssertNotNil(insertedElement)

            let result = await root.toSortedJSON()
            XCTAssertEqual(result, "{\"array\":[1,[11,12,13],2,3]}")
        }
    }

    func test_can_insert_into_before() async {
        let target = Document(key: "doc1")
        await target.update { root in
            await root.set(key: "array", value: [Int32(1), Int32(2), Int32(3)])
            let array = await root.array as? JSONArray
            guard let thirdElement = await array?.getElement(byIndex: 2) as? Primitive else {
                XCTFail("getElement(byIndex:) is nil.")
                return
            }

            let insertedElement = try? await array?.insertBefore(nextID: thirdElement.getCreatedAt(), value: [Int32(11), Int32(12), Int32(13)])
            XCTAssertNotNil(insertedElement)

            let result = await root.toSortedJSON()
            XCTAssertEqual(result, "{\"array\":[1,2,[11,12,13],3]}")
        }
    }

    func test_can_move_to_before() async {
        let target = Document(key: "doc1")
        await target.update { root in
            await root.set(key: "array", value: [Int32(1), Int32(2), Int32(3)])
            let array = await root.array as? JSONArray
            guard let firstElement = await array?.getElement(byIndex: 0) as? Primitive else {
                XCTFail("getElement(byIndex:) is nil.")
                return
            }

            guard let lastElement = await array?.getElement(byIndex: 2) as? Primitive else {
                XCTFail("getElement(byIndex:) is nil.")
                return
            }

            try? await array?.moveBefore(nextID: lastElement.getCreatedAt(), id: firstElement.getCreatedAt())

            let result = await root.toSortedJSON()
            XCTAssertEqual(result, "{\"array\":[2,1,3]}")
        }
    }

    func test_can_move_to_after() async {
        let target = Document(key: "doc1")
        await target.update { root in
            await root.set(key: "array", value: [Int32(1), Int32(2), Int32(3)])
            let array = await root.array as? JSONArray
            guard let firstElement = await array?.getElement(byIndex: 0) as? Primitive else {
                XCTFail("getElement(byIndex:) is nil.")
                return
            }

            guard let lastElement = await array?.getElement(byIndex: 2) as? Primitive else {
                XCTFail("getElement(byIndex:) is nil.")
                return
            }

            try? await array?.moveAfter(previousID: lastElement.getCreatedAt(), id: firstElement.getCreatedAt())

            let result = await root.toSortedJSON()
            XCTAssertEqual(result, "{\"array\":[2,3,1]}")
        }
    }

    func test_can_move_to_front() async {
        let target = Document(key: "doc1")
        await target.update { root in
            await root.set(key: "array", value: [Int32(1), Int32(2), Int32(3)])
            let array = await root.array as? JSONArray

            guard let lastElement = await array?.getElement(byIndex: 2) as? Primitive else {
                XCTFail("getElement(byIndex:) is nil.")
                return
            }

            try? await array?.moveFront(id: lastElement.getCreatedAt())

            let result = await root.toSortedJSON()
            XCTAssertEqual(result, "{\"array\":[3,1,2]}")
        }
    }

    func test_can_move_to_last() async {
        let target = Document(key: "doc1")
        await target.update { root in
            await root.set(key: "array", value: [Int32(1), Int32(2), Int32(3)])
            let array = await root.array as? JSONArray
            guard let firstElement = await array?.getElement(byIndex: 0) as? Primitive else {
                XCTFail("getElement(byIndex:) is nil.")
                return
            }

            try? await array?.moveLast(id: firstElement.getCreatedAt())

            let result = await root.toSortedJSON()
            XCTAssertEqual(result, "{\"array\":[2,3,1]}")
        }
    }

    func test_can_remove() async {
        let target = Document(key: "doc1")
        await target.update { root in
            await root.set(key: "array", value: [Int32(1), Int32(2), Int32(3)])
            let array = await root.array as? JSONArray
            guard let firstElement = await array?.getElement(byIndex: 0) as? Primitive else {
                XCTFail("getElement(byIndex:) is nil.")
                return
            }

            let removedByID = await array?.remove(byID: firstElement.getCreatedAt())
            XCTAssertNotNil(removedByID)

            var result = await root.toSortedJSON()
            XCTAssertEqual(result, "{\"array\":[2,3]}")

            let removedByIndex = await array?.remove(index: 0)
            XCTAssertNotNil(removedByIndex)

            result = await root.toSortedJSON()
            XCTAssertEqual(result, "{\"array\":[3]}")
        }
    }

    func test_can_get_length() async {
        let target = Document(key: "doc1")
        await target.update { root in
            await root.set(key: "array", value: [Int32(1), Int32(2), Int32(3)])
            let array = await root.array as? JSONArray

            let result = await array?.length()
            XCTAssertEqual(result, 3)
        }
    }

    func test_can_remove_partial_elements() async {
        let target = Document(key: "doc1")
        await target.update { root in
            await root.set(key: "array", value: [Int32(1), Int32(2), Int32(3), Int32(4), Int32(5)])
            let array = await root.array as? JSONArray

            let removed = try? await array?.splice(start: 1, deleteCount: 3) as? [Int32]
            XCTAssertEqual(removed?.count, 3)

            XCTAssertEqual(removed, [Int32(2), Int32(3), Int32(4)])
            let result = await root.toSortedJSON()
            XCTAssertEqual(result, "{\"array\":[1,5]}")
        }
    }

    func test_can_replace_partial_elements() async {
        let target = Document(key: "doc1")
        await target.update { root in
            await root.set(key: "array", value: [Int32(1), Int32(2), Int32(3), Int32(4), Int32(5)])
            let array = await root.array as? JSONArray

            let removed = try? await array?.splice(start: 1, deleteCount: 3, items: Int32(12), Int32(13), Int32(14)) as? [Int32]
            XCTAssertEqual(removed?.count, 3)

            let result = await root.toSortedJSON()
            XCTAssertEqual(result, "{\"array\":[1,12,13,14,5]}")
        }
    }

    func test_can_check_to_include() async {
        let target = Document(key: "doc1")
        await target.update { root in
            await root.set(key: "array", value: [Int32(1), Int32(2), Int32(3), Int32(4), Int32(5)])
            let array = await root.array as? JSONArray

            var result = await array?.includes(searchElement: Int32(2))
            XCTAssertEqual(result, true)
            result = await array?.includes(searchElement: Int32(2), fromIndex: 0)
            XCTAssertEqual(result, true)
            result = await array?.includes(searchElement: Int32(2), fromIndex: 2)
            XCTAssertEqual(result, false)
            result = await array?.includes(searchElement: Int32(100), fromIndex: 2)
            XCTAssertEqual(result, false)
        }
    }

    func test_can_get_index() async {
        let target = Document(key: "doc1")
        await target.update { root in
            await root.set(key: "array", value: [Int32(1), Int32(2), Int32(3), Int32(4), Int32(5)])
            let array = await root.array as? JSONArray

            var result = await array?.indexOf(Int32(2))
            XCTAssertEqual(result, 1)
            result = await array?.indexOf(Int32(2), fromIndex: 0)
            XCTAssertEqual(result, 1)
            result = await array?.indexOf(Int32(2), fromIndex: 2)
            XCTAssertEqual(result, JSONArray.notFound)
            result = await array?.indexOf(Int32(100), fromIndex: 2)
            XCTAssertEqual(result, JSONArray.notFound)
        }
    }

    func test_can_get_last_index() async {
        let target = Document(key: "doc1")
        await target.update { root in
            await root.set(key: "array", value: [Int32(1), Int32(2), Int32(3), Int32(4), Int32(5)])
            let array = await root.array as? JSONArray
            var result = await array?.lastIndexOf(Int32(2))
            XCTAssertEqual(result, 1)
            result = await array?.lastIndexOf(Int32(2), fromIndex: 0)
            XCTAssertEqual(result, JSONArray.notFound)
            result = await array?.lastIndexOf(Int32(2), fromIndex: 2)
            XCTAssertEqual(result, 1)
            result = await array?.lastIndexOf(Int32(100), fromIndex: 2)
            XCTAssertEqual(result, JSONArray.notFound)
        }
    }

    func test_can_insert_jsonObject() async {
        let target = Document(key: "doc1")
        await target.update { root in
            await root.set(key: "top", value: JSONObject())
            let object = await root.top as? JSONObject

            await object?.set(key: "a", value: "a")

            let result = await root.toSortedJSON()
            XCTAssertEqual(result, "{\"top\":{\"a\":\"a\"}}")
        }
    }

    func test_can_insert_jsonArray() async {
        let target = Document(key: "doc1")
        await target.update { root in
            await root.set(key: "array", value: JSONArray())
            let array = await root.array as? JSONArray

            await array?.append(Int32(1))

            let result = await root.toSortedJSON()
            XCTAssertEqual(result, "{\"array\":[1]}")
        }
    }
}
