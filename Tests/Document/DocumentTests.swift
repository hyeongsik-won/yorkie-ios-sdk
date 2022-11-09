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

class DocumentTests: XCTestCase {
    func test_doesnt_return_error_when_trying_to_delete_a_missing_key() async {
        let target = Document(key: "doc-1")
        await target.update { root in
            await root.set(key: "k1", value: "1")
            await root.set(key: "k2", value: "2")
            await root.set(key: "k3", value: [1, 2])
        }

        await target.update { root in
            await root.remove(key: "k1")
            await(root.k3 as? JSONArray)?.remove(index: 0)
            await root.remove(key: "k4") // missing key
            await(root.k3 as? JSONArray)?.remove(index: 2) // missing key
        }
    }

    func test_can_input_nil() async throws {
        let target = Document(key: "test-doc")
        await target.update { root in
            await root.set(key: "data", value: ["": nil, "null": nil])
        }

        let result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":{"":null,"null":null}}
                       """)
    }

    func test_delete_elements_of_array_test() async throws {
        let target = Document(key: "test-doc")
        await target.update { root in
            await root.set(key: "data", value: [Int64(0), Int64(1), Int64(2)])
            let result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"data":[0,1,2]}
                           """)
        }

        var result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[0,1,2]}
                       """)

        var length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 3)

        await target.update { root in
            await(root.data as? JSONArray)?.remove(index: 0)
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[1,2]}
                       """)

        length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 2)

        await target.update { root in
            await(root.data as? JSONArray)?.remove(index: 1)
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[1]}
                       """)

        length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 1)

        await target.update { root in
            await(root.data as? JSONArray)?.remove(index: 0)
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[]}
                       """)

        length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 0)
    }

    func test_splice_array_with_number() async throws {
        let target = Document(key: "test-doc")
        await target.update { root in
            await root.set(key: "list", value: [Int64(0), Int64(1), Int64(2), Int64(3), Int64(4), Int64(5), Int64(6), Int64(7), Int64(8), Int64(9)])
        }

        var result = await target.toSortedJSON()
        XCTAssertEqual(result, "{\"list\":[0,1,2,3,4,5,6,7,8,9]}")

        await target.update { root in
            let removeds = try? await(root.list as? JSONArray)?.splice(start: 1, deleteCount: 1) as? [Int64]
            XCTAssertEqual(removeds, [Int64(1)])
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result, "{\"list\":[0,2,3,4,5,6,7,8,9]}")

        await target.update { root in
            let removeds = try? await(root.list as? JSONArray)?.splice(start: 1, deleteCount: 2) as? [Int64]
            XCTAssertEqual(removeds, [Int64(2), Int64(3)])
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"list":[0,4,5,6,7,8,9]}
                       """)

        await target.update { root in
            let removeds = try? await(root.list as? JSONArray)?.splice(start: 3) as? [Int64]
            XCTAssertEqual(removeds, [Int64(6), Int64(7), Int64(8), Int64(9)])
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"list":[0,4,5]}
                       """)

        await target.update { root in
            let removeds = try? await(root.list as? JSONArray)?.splice(start: 1, deleteCount: 200) as? [Int64]
            XCTAssertEqual(removeds, [Int64(4), Int64(5)])
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"list":[0]}
                       """)

        await target.update { root in
            let removeds = try? await(root.list as? JSONArray)?.splice(start: 0, deleteCount: 0, items: Int64(1), Int64(2), Int64(3)) as? [Int64]
            XCTAssertEqual(removeds, [])
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"list":[1,2,3,0]}
                       """)

        await target.update { root in
            let removeds = try? await(root.list as? JSONArray)?.splice(start: 1, deleteCount: 2, items: Int64(4)) as? [Int64]
            XCTAssertEqual(removeds, [Int64(2), Int64(3)])
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"list":[1,4,0]}
                       """)

        await target.update { root in
            let removeds = try? await(root.list as? JSONArray)?.splice(start: 2, deleteCount: 200, items: Int64(2)) as? [Int64]
            XCTAssertEqual(removeds, [Int64(0)])
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"list":[1,4,2]}
                       """)

        await target.update { root in
            let removeds = try? await(root.list as? JSONArray)?.splice(start: 2, deleteCount: 0, items: Int64(3)) as? [Int64]
            XCTAssertEqual(removeds, [])
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"list":[1,4,3,2]}
                       """)

        await target.update { root in
            let removeds = try? await(root.list as? JSONArray)?.splice(start: 5, deleteCount: 10, items: Int64(1), Int64(2)) as? [Int64]
            XCTAssertEqual(removeds, [])
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"list":[1,4,3,2,1,2]}
                       """)

        await target.update { root in
            let removeds = try? await(root.list as? JSONArray)?.splice(start: 1, deleteCount: -3, items: Int64(5)) as? [Int64]
            XCTAssertEqual(removeds, [])
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"list":[1,5,4,3,2,1,2]}
                       """)

        await target.update { root in
            let removeds = try? await(root.list as? JSONArray)?.splice(start: -2, deleteCount: -11, items: Int64(5), Int64(6)) as? [Int64]
            XCTAssertEqual(removeds, [])
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"list":[1,5,4,3,2,5,6,1,2]}
                       """)

        await target.update { root in
            let removeds = try? await(root.list as? JSONArray)?.splice(start: -11, deleteCount: 2, items: Int64(7), Int64(8)) as? [Int64]
            XCTAssertEqual(removeds, [Int64(1), Int64(5)])
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"list":[7,8,4,3,2,5,6,1,2]}
                       """)
    }

    func test_splice_array_with_string() async throws {
        let target = Document(key: "test-doc")
        await target.update { root in
            await root.set(key: "list", value: ["a", "b", "c"])
        }

        var result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"list":["a","b","c"]}
                       """)

        await target.update { root in
            let removeds = try? await(root.list as? JSONArray)?.splice(start: 1, deleteCount: 1) as? [String]
            XCTAssertEqual(removeds, ["b"])
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result, """
        {"list":["a","c"]}
        """)
    }

    func test_splice_array_with_object() async throws {
        let target = Document(key: "test-doc")
        await target.update { root in
            await root.set(key: "list", value: [["id": Int64(1)], ["id": Int64(2)]])
        }
        var result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"list":[{"id":1},{"id":2}]}
                       """)

        await target.update { root in
            let removeds = try? await(root.list as? JSONArray)?.splice(start: 1, deleteCount: 1) as? [JSONObject]
            let result = await removeds?[0].toSortedJSON()
            XCTAssertEqual(result, "{\"id\":2}")
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"list":[{"id":1}]}
                       """)
    }

    // MARK: - should support standard array read only operations

    func test_concat() async throws {
        let target = Document(key: "test-doc")
        await target.update { root in
            await root.set(key: "list", value: [Int64(1), Int64(2), Int64(3)])
        }

        guard let array = await(target.getRoot().list as? JSONArray)?.toArray as? [Int64] else {
            XCTFail("Failed to convert JSONArray to Array.")
            return
        }

        XCTAssertEqual(array + [Int64(4), Int64(5), Int64(6)], [Int64(1), Int64(2), Int64(3), Int64(4), Int64(5), Int64(6)])
    }

    func test_indexOf() async {
        let target = Document(key: "test-doc")
        await target.update { root in
            await root.set(key: "list", value: [Int64(1), Int64(2), Int64(3), Int64(3)])
        }

        guard let list = await target.getRoot().list as? JSONArray else {
            XCTFail("failed to cast element as JSONArray.")
            return
        }

        var result = await list.indexOf(Int64(3))
        XCTAssertEqual(result, 2)
        result = await list.indexOf(Int64(0))
        XCTAssertEqual(result, -1)
        result = await list.indexOf(Int64(1), fromIndex: 1)
        XCTAssertEqual(result, -1)
        result = await list.indexOf(Int64(3), fromIndex: -3)
        XCTAssertEqual(result, 1)
    }

    func test_indexOf_with_objects() async {
        let target = Document(key: "test-doc")
        await target.update { root in
            await root.set(key: "objects", value: [["id": "first"], ["id": "second"]])
        }

        guard let objects = await target.getRoot().objects as? JSONArray else {
            XCTFail("failed to cast element as JSONArray.")
            return
        }

        let result = await objects.indexOf(objects[1]!)
        XCTAssertEqual(result, 1)
    }

    func test_lastIndexOf() async {
        let target = Document(key: "test-doc")
        await target.update { root in
            await root.set(key: "list", value: [Int64(1), Int64(2), Int64(3), Int64(3)])
        }

        guard let list = await target.getRoot().list as? JSONArray else {
            XCTFail("failed to cast element as JSONArray.")
            return
        }

        var result = await list.lastIndexOf(Int64(3))
        XCTAssertEqual(result, 3)
        result = await list.lastIndexOf(Int64(0))
        XCTAssertEqual(result, -1)
        result = await list.lastIndexOf(Int64(3), fromIndex: 1)
        XCTAssertEqual(result, -1)
        result = await list.lastIndexOf(Int64(3), fromIndex: 2)
        XCTAssertEqual(result, 2)
        result = await list.lastIndexOf(Int64(3), fromIndex: -1)
        XCTAssertEqual(result, 3)
    }

    func test_lastIndexOf_with_objects() async {
        let target = Document(key: "test-doc")
        await target.update { root in
            await root.set(key: "objects", value: [["id": "first"], ["id": "second"]])
        }

        guard let objects = await target.getRoot().objects as? JSONArray else {
            XCTFail("failed to cast element as JSONArray.")
            return
        }

        let result = await objects.lastIndexOf(objects[1]!)
        XCTAssertEqual(result, 1)
    }

    func test_should_allow_mutation_of_objects_returned_from_readonly_list_methods() async {
        let target = Document(key: "test-doc")
        await target.update { root in
            await root.set(key: "objects", value: [["id": "first"], ["id": "second"]])
        }

        await target.update { root in
            await((root.objects as? JSONArray)?[0] as? JSONObject)?.set(key: "id", value: "FIRST")
        }

        let result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"objects":[{"id":"FIRST"},{"id":"second"}]}
                       """)
    }

    func test_move_elements_before_a_specific_node_of_array() async {
        let target = Document(key: "test-doc")
        await target.update { root in
            await root.set(key: "data", value: [Int64(0), Int64(1), Int64(2)])
        }

        var result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[0,1,2]}
                       """)
        var length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 3)

        await target.update { root in
            let data = await root.data as? JSONArray
            let zero = await data?.getElement(byIndex: 0) as? CRDTElement
            let two = await data?.getElement(byIndex: 2) as? CRDTElement
            try? await data?.moveBefore(nextID: two!.getID(), id: zero!.getID())
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[1,0,2]}
                       """)
        length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 3)

        await target.update { root in
            let data = await root.data as? JSONArray
            await data?.append(Int64(3))
            let one = await data?.getElement(byIndex: 1) as? CRDTElement
            let three = await data?.getElement(byIndex: 3) as? CRDTElement
            try? await data?.moveBefore(nextID: one!.getID(), id: three!.getID())
            let result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"data":[1,3,0,2]}
                           """)
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[1,3,0,2]}
                       """)
        length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 4)
    }

    func test_simple_move_elements_before_a_specific_node_of_array() async {
        let target = Document(key: "test-doc")
        await target.update { root in
            await root.set(key: "data", value: [Int64(0), Int64(1), Int64(2)])
        }

        var result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[0,1,2]}
                       """)

        var length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 3)

        await target.update { root in
            let data = await root.data as? JSONArray
            await data?.append(Int64(3))
            let one = await data?.getElement(byIndex: 1) as? CRDTElement
            let three = await data?.getElement(byIndex: 3) as? CRDTElement
            try? await data?.moveBefore(nextID: one!.getID(), id: three!.getID())
            let result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"data":[0,3,1,2]}
                           """)
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[0,3,1,2]}
                       """)
        length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 4)
    }

    func test_move_elements_after_a_specific_node_of_array() async {
        let target = Document(key: "test-doc")
        await target.update { root in
            await root.set(key: "data", value: [Int64(0), Int64(1), Int64(2)])
        }

        var result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[0,1,2]}
                       """)

        var length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 3)

        await target.update { root in
            let data = await root.data as? JSONArray
            let zero = await data?.getElement(byIndex: 0) as? CRDTElement
            let two = await data?.getElement(byIndex: 2) as? CRDTElement
            try? await data?.moveAfter(previousID: two!.getID(), id: zero!.getID())
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[1,2,0]}
                       """)

        length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 3)

        await target.update { root in
            let data = await root.data as? JSONArray
            await data?.append(Int64(3))
            let one = await data?.getElement(byIndex: 1) as? CRDTElement
            let three = await data?.getElement(byIndex: 3) as? CRDTElement
            try? await data?.moveAfter(previousID: one!.getID(), id: three!.getID())
            let result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"data":[1,2,3,0]}
                           """)
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[1,2,3,0]}
                       """)

        length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 4)
    }

    func test_simple_move_elements_after_a_specific_node_of_array() async {
        let target = Document(key: "test-doc")
        await target.update { root in
            await root.set(key: "data", value: [Int64(0), Int64(1), Int64(2)])
        }

        var result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[0,1,2]}
                       """)
        var length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 3)

        await target.update { root in
            let data = await root.data as? JSONArray
            await data?.append(Int64(3))
            let one = await data?.getElement(byIndex: 1) as? CRDTElement
            let three = await data?.getElement(byIndex: 3) as? CRDTElement
            try? await data?.moveAfter(previousID: one!.getID(), id: three!.getID())
            let result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"data":[0,1,3,2]}
                           """)
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[0,1,3,2]}
                       """)
        length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 4)
    }

    func test_move_elements_at_the_first_of_array() async {
        let target = Document(key: "test-doc")
        await target.update { root in
            await root.set(key: "data", value: [Int64(0), Int64(1), Int64(2)])
        }

        var result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[0,1,2]}
                       """)
        var length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 3)

        await target.update { root in
            let data = await root.data as? JSONArray
            let two = await data?.getElement(byIndex: 2) as? CRDTElement
            try? await data?.moveFront(id: two!.getID())
        }
        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[2,0,1]}
                       """)
        length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 3)

        await target.update { root in
            let data = await root.data as? JSONArray
            await data?.append(Int64(3))
            let three = await data?.getElement(byIndex: 3) as? CRDTElement
            try? await data?.moveFront(id: three!.getID())
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[3,2,0,1]}
                       """)
        length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 4)
    }

    func test_simple_move_elements_at_the_first_of_array() async {
        let target = Document(key: "test-doc")
        await target.update { root in
            await root.set(key: "data", value: [Int64(0), Int64(1), Int64(2)])
        }

        var result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[0,1,2]}
                       """)
        var length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 3)

        await target.update { root in
            let data = await root.data as? JSONArray
            await data?.append(Int64(3))
            let one = await data?.getElement(byIndex: 1) as? CRDTElement
            try? await data?.moveFront(id: one!.getID())
            let result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"data":[1,0,2,3]}
                           """)
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[1,0,2,3]}
                       """)
        length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 4)
    }

    func test_move_elements_at_the_last_of_array() async {
        let target = Document(key: "test-doc")
        await target.update { root in
            await root.set(key: "data", value: [Int64(0), Int64(1), Int64(2)])
        }

        var result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[0,1,2]}
                       """)
        var length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 3)

        await target.update { root in
            let data = await root.data as? JSONArray
            let two = await data?.getElement(byIndex: 2) as? CRDTElement
            try? await data?.moveLast(id: two!.getID())
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[0,1,2]}
                       """)
        length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 3)

        await target.update { root in
            let data = await root.data as? JSONArray
            await data?.append(Int64(3))
            let two = await data?.getElement(byIndex: 2) as? CRDTElement
            try? await data?.moveLast(id: two!.getID())
            let result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"data":[0,1,3,2]}
                           """)
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[0,1,3,2]}
                       """)
        length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 4)
    }

    func test_simple_move_elements_at_the_last_of_array() async {
        let target = Document(key: "test-doc")
        await target.update { root in
            await root.set(key: "data", value: [Int64(0), Int64(1), Int64(2)])
        }

        var result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[0,1,2]}
                       """)
        var length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 3)

        await target.update { root in
            let data = await root.data as? JSONArray
            await data?.append(Int64(3))
            let one = await data?.getElement(byIndex: 1) as? CRDTElement
            try? await data?.moveLast(id: one!.getID())
            let result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"data":[0,2,3,1]}
                           """)
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[0,2,3,1]}
                       """)
        length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 4)
    }

    private var cancellables = Set<AnyCancellable>()

    func test_change_paths_test_for_object() async {
        let target = Document(key: "test-doc")

        await target.eventStream.sink { _ in

        } receiveValue: { event in
            XCTAssertEqual(event.type, .localChange)
            XCTAssertEqual((event as? LocalChangeEvent)?.value[0].paths, ["$."])
        }.store(in: &self.cancellables)

        await target.update { root in
            await root.set(key: "", value: [:])

            var result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"":{}}
                           """)

            let emptyKey = await root[""] as? JSONObject
            await emptyKey!.set(key: "obj", value: [:])

            result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"":{"obj":{}}}
                           """)

            let obj = await emptyKey!.obj as? JSONObject
            await obj!.set(key: "a", value: Int64(1))

            result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"":{"obj":{"a":1}}}
                           """)

            await obj!.remove(key: "a")

            result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"":{"obj":{}}}
                           """)

            await obj!.set(key: "$.hello", value: Int64(1))

            result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"":{"obj":{"$.hello":1}}}
                           """)

            await obj!.remove(key: "$.hello")

            result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"":{"obj":{}}}
                           """)

            await emptyKey!.remove(key: "obj")

            result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"":{}}
                           """)
        }
    }

    func test_change_paths_test_for_array() async {
        let target = Document(key: "test-doc")

        await target.eventStream.sink { _ in

        } receiveValue: { event in
            XCTAssertEqual(event.type, .localChange)

            XCTAssertEqual((event as? LocalChangeEvent)?.value[0].paths.sorted(), ["$.arr", "$.\\$\\$\\.\\.\\.hello"].sorted())
        }.store(in: &self.cancellables)

        await target.update { root in
            await root.set(key: "arr", value: [])
            let arr = await root.arr as? JSONArray
            await arr?.append(Int64(0))
            await arr?.append(Int64(1))
            await arr?.remove(index: 1)
            await root.set(key: "$$...hello", value: [])
            let hello = await root["$$...hello"] as? JSONArray
            await hello?.append(Int64(0))

            let result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"$$...hello":[0],"arr":[0]}
                           """)
        }
    }

    func test_insert_elements_before_a_specific_node_of_array() async {
        let target = Document(key: "test-doc")
        await target.update { root in
            await root.set(key: "data", value: [Int64(0), Int64(1), Int64(2)])
        }

        var result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[0,1,2]}
                       """)
        var length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 3)

        await target.update { root in
            let data = await root.data as? JSONArray
            let zero = await data?.getElement(byIndex: 0) as? CRDTElement
            _ = try? await data?.insertBefore(nextID: zero!.getID(), value: Int64(3))
        }
        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[3,0,1,2]}
                       """)
        length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 4)

        await target.update { root in
            let data = await root.data as? JSONArray
            let one = await data?.getElement(byIndex: 2) as? CRDTElement
            _ = try? await data?.insertBefore(nextID: one!.getID(), value: Int64(4))
        }
        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[3,0,4,1,2]}
                       """)
        length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 5)

        await target.update { root in
            let data = await root.data as? JSONArray
            let two = await data?.getElement(byIndex: 4) as? CRDTElement
            _ = try? await data?.insertBefore(nextID: two!.getID(), value: Int64(5))
        }
        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[3,0,4,1,5,2]}
                       """)
        length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 6)
    }

    func test_can_insert_an_element_before_specific_position_after_delete_operation() async {
        let target = Document(key: "test-doc")
        await target.update { root in
            await root.set(key: "data", value: [Int64(0), Int64(1), Int64(2)])
        }

        var result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[0,1,2]}
                       """)
        var length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 3)

        await target.update { root in
            let data = await root.data as? JSONArray
            let zero = await data?.getElement(byIndex: 0) as? CRDTElement
            _ = await data?.remove(byID: zero!.getID())

            let one = await data?.getElement(byIndex: 0) as? CRDTElement
            _ = try? await data?.insertBefore(nextID: one!.getID(), value: Int64(3))
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[3,1,2]}
                       """)
        length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 3)

        await target.update { root in
            let data = await root.data as? JSONArray
            let one = await data?.getElement(byIndex: 1) as? CRDTElement
            _ = await data?.remove(byID: one!.getID())

            let two = await data?.getElement(byIndex: 1) as? CRDTElement
            _ = try? await data?.insertBefore(nextID: two!.getID(), value: Int64(4))
        }

        result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":[3,4,2]}
                       """)
        length = await(target.getRoot().data as? JSONArray)?.length()
        XCTAssertEqual(length, 3)
    }

    func test_should_remove_previously_inserted_elements_in_heap_when_running_GC() async {
        let target = Document(key: "test-doc")
        await target.update { root in
            await root.set(key: "a", value: Int64(1))
            await root.set(key: "a", value: Int64(2))
            await root.remove(key: "a")
        }

        var result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {}
                       """)
        var length = await target.getGarbageLength()
        XCTAssertEqual(length, 1)

        await target.garbageCollect(lessThanOrEqualTo: TimeTicket.max)
        result = await target.toSortedJSON()
        XCTAssertEqual(result, "{}")
        length = await target.getGarbageLength()
        XCTAssertEqual(length, 0)
    }

    func test_escapes_string_for_object() async {
        let target = Document(key: "test-doc")
        await target.update { root in
            await root.set(key: "a", value: "\"hello\"\n\r\t\\")
        }

        let result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"a":"\\"hello\\"\\n\\r\\t\\\\"}
                       """)
    }

    func test_escapes_string_for_elements_in_array() async {
        let target = Document(key: "test-doc")
        await target.update { root in
            await root.set(key: "data", value: ["\"hello\"", "\n", "\u{0008}", "\t", "\u{000C}", "\r", "\\"])
        }

        let result = await target.toSortedJSON()
        XCTAssertEqual(result,
                       """
                       {"data":["\\"hello\\"","\\n","\\b","\\t","\\f","\\r","\\\\"]}
                       """)
    }
}
