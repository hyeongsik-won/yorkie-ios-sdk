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

class JSONObjectTests: XCTestCase {
    func test_can_set() async throws {
        let target = Document(key: "doc1")
        await target.update { root in
            await root.set(key: "boolean", value: true)
            await root.set(key: "integer", value: Int32(111))
            await root.set(key: "long", value: Int64(9_999_999))
            await root.set(key: "double", value: Double(1.2222222))
            await root.set(key: "string", value: "abc")

            await root.set(key: "compB", value: JSONObject())
            let compB = await root.get(key: "compB") as? JSONObject
            await compB?.set(key: "id", value: "b")
            await compB?.set(key: "compC", value: JSONObject())

            let compC = await compB?.get(key: "compC") as? JSONObject
            await compC?.set(key: "id", value: "c")
            await compC?.set(key: "compD", value: JSONObject())
            let compD = await compC?.get(key: "compD") as? JSONObject
            await compD?.set(key: "id", value: "d-1")

            var result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"boolean":"true","compB":{"compC":{"compD":{"id":"d-1"},"id":"c"},"id":"b"},"double":1.2222222,"integer":111,"long":9999999,"string":"abc"}
                           """)

            await compD?.set(key: "id", value: "d-2")

            result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"boolean":"true","compB":{"compC":{"compD":{"id":"d-2"},"id":"c"},"id":"b"},"double":1.2222222,"integer":111,"long":9999999,"string":"abc"}
                           """)
        }
    }

    func test_can_remove() async {
        let target = Document(key: "doc1")
        await target.update { root in
            await root.set(key: "boolean", value: true)
            await root.set(key: "integer", value: Int32(111))
            await root.set(key: "long", value: Int64(9_999_999))
            await root.set(key: "double", value: Double(1.2222222))
            await root.set(key: "string", value: "abc")

            await root.set(key: "compB", value: JSONObject())
            let compB = await root.compB as? JSONObject
            await compB?.set(key: "id", value: "b")
            await compB?.set(key: "compC", value: JSONObject())
            let compC = await compB?.compC as? JSONObject
            await compC?.set(key: "id", value: "c")
            await compC?.set(key: "compD", value: JSONObject())
            let compD = await compC?.compD as? JSONObject
            await compD?.set(key: "id", value: "d-1")

            var result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"boolean":"true","compB":{"compC":{"compD":{"id":"d-1"},"id":"c"},"id":"b"},"double":1.2222222,"integer":111,"long":9999999,"string":"abc"}
                           """)

            await root.remove(key: "string")
            await root.remove(key: "integer")
            await root.remove(key: "compB")

            result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"boolean":"true","double":1.2222222,"long":9999999}
                           """)
        }
    }

    func test_can_set_with_dictionary() async {
        let target = Document(key: "doc1")
        await target.update { root in
            await root.set([
                "boolean": true,
                "integer": Int32(111),
                "long": Int64(9_999_999),
                "double": Double(1.2222222),
                "string": "abc",
                "compB": ["id": "b",
                          "compC": ["id": "c",
                                    "compD": ["id": "d-1"]]]
            ])

            var result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"boolean":"true","compB":{"compC":{"compD":{"id":"d-1"},"id":"c"},"id":"b"},"double":1.2222222,"integer":111,"long":9999999,"string":"abc"}
                           """)

            let compB = await root.compB as? JSONObject
            let compC = await compB?.compC as? JSONObject
            let compD = await compC?.compD as? JSONObject
            await compD?.set(key: "id", value: "d-2")

            result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"boolean":"true","compB":{"compC":{"compD":{"id":"d-2"},"id":"c"},"id":"b"},"double":1.2222222,"integer":111,"long":9999999,"string":"abc"}
                           """)

            let idOfCompD = await compD?.id as? String
            XCTAssertEqual(idOfCompD, "d-2")
        }
    }

    func test_can_set_with_key_and_dictionary() async {
        let target = Document(key: "doc1")
        await target.update { root in
            await root.set(key: "top", value: [
                "boolean": true,
                "integer": Int32(111),
                "long": Int64(9_999_999),
                "double": Double(1.2222222),
                "string": "abc",
                "compB": ["id": "b",
                          "compC": ["id": "c",
                                    "compD": ["id": "d-1"]]]
            ])

            var result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"top":{"boolean":"true","compB":{"compC":{"compD":{"id":"d-1"},"id":"c"},"id":"b"},"double":1.2222222,"integer":111,"long":9999999,"string":"abc"}}
                           """)

            let top = await root.top as? JSONObject
            let compB = await top?.compB as? JSONObject
            let compC = await compB?.compC as? JSONObject
            let compD = await compC?.compD as? JSONObject
            await compD?.set(key: "id", value: "d-2")

            result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"top":{"boolean":"true","compB":{"compC":{"compD":{"id":"d-2"},"id":"c"},"id":"b"},"double":1.2222222,"integer":111,"long":9999999,"string":"abc"}}
                           """)

            let idOfCompD = await compD?.id as? String
            XCTAssertEqual(idOfCompD, "d-2")
        }
    }

    struct JsonObejctTestType: YorkieJSONObjectable {
        var id: Int64 = 100
        var type: String = "struct"
        var serial: Int32 = 1234
        var array: [JsonArrayTestType] = [JsonArrayTestType()]

        var excludedMembers: [String] {
            ["serial"]
        }
    }

    struct JsonArrayTestType: YorkieJSONObjectable {
        var id: Int64 = 200
    }

    func test_can_insert_obejct() async {
        let target = Document(key: "doc1")
        await target.update { root in
            await root.set(key: "object", value: JsonObejctTestType())

            var result = await root.toSortedJSON()
            XCTAssertEqual(result,
                           """
                           {"object":{"array":[{"id":200}],"id":100,"type":"struct"}}
                           """)
        }
    }
}
