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

// It will be implemented soon.
protocol JsonArrayable: AnyObject {
    var target: CRDTArray { get set }
    var context: ChangeContext { get set }
}

class JsonArray<T>: JsonArrayable {
    var target: CRDTArray
    var context: ChangeContext

    init(target: CRDTArray, changeContext: ChangeContext) {
        self.target = target
        self.context = changeContext
    }

    func getID() -> TimeTicket {
        return self.target.getCreatedAt()
    }
//
//    //TODO: fix
    ////    func getElementByID(createdAt: TimeTicket) -> T {
    ////    return (createdAt: TimeTicket): WrappedElement | undefined => {
    ////                return toWrappedElement(context, target.get(createdAt));
    ////              };
    ////    }
//
    ////    func getElementByIndex(_ index: Int) -> T {
    ////    return (index: number): WrappedElement | undefined => {
    ////                const elem = target.getByIndex(index);
    ////                return toWrappedElement(context, elem);
    ////              };
    ////    }
//
    ////    func getLast() {
    ////    return (): WrappedElement | undefined => {
    ////                return toWrappedElement(context, target.getLast());
    ////              };
    ////    }
//
//    func deleteByID(createdAt: TimeTicket) {
//
//    }
//
//
//    //TODO: to implement
//    // eslint-disable-next-line jsdoc/require-jsdoc
    ////    func iteratorInternal(change: ChangeContext, target: CRDTArray): IterableIterator<WrappedElement> {
    ////      for elem in target {
    ////        yield toWrappedElement(change, elem)!;
    ////      }
    ////    }
//
//    /**
//     * `pushInternal` pushes the value to the target array.
//     */
//    func pushInternal(context: ChangeContext,target: CRDTArray,value: unknown) Int {
//      ArrayProxy.insertAfterInternal(
//        context,
//        target,
//        target.getLastCreatedAt(),
//        value,
//      );
//      return target.length;
//    }
//
//    /**
//     * `moveBeforeInternal` moves the given `createdAt` element
//     * after the previously created element.
//     */
//    public static moveBeforeInternal(
//      context: ChangeContext,
//      target: CRDTArray,
//      nextCreatedAt: TimeTicket,
//      createdAt: TimeTicket,
//    ): void {
//      const ticket = context.issueTimeTicket();
//      const prevCreatedAt = target.getPrevCreatedAt(nextCreatedAt);
//      target.moveAfter(prevCreatedAt, createdAt, ticket);
//      context.push(
//        MoveOperation.create(
//          target.getCreatedAt(),
//          prevCreatedAt,
//          createdAt,
//          ticket,
//        ),
//      );
//    }
//
//    /**
//     * `moveAfterInternal` moves the given `createdAt` element
//     * after the specific element.
//     */
//    public static moveAfterInternal(
//      context: ChangeContext,
//      target: CRDTArray,
//      prevCreatedAt: TimeTicket,
//      createdAt: TimeTicket,
//    ): void {
//      const ticket = context.issueTimeTicket();
//      target.moveAfter(prevCreatedAt, createdAt, ticket);
//      context.push(
//        MoveOperation.create(
//          target.getCreatedAt(),
//          prevCreatedAt,
//          createdAt,
//          ticket,
//        ),
//      );
//    }
//
//    /**
//     * `moveFrontInternal` moves the given `createdAt` element
//     * at the first of array.
//     */
//    public static moveFrontInternal(
//      context: ChangeContext,
//      target: CRDTArray,
//      createdAt: TimeTicket,
//    ): void {
//      const ticket = context.issueTimeTicket();
//      const head = target.getHead();
//      target.moveAfter(head.getCreatedAt(), createdAt, ticket);
//      context.push(
//        MoveOperation.create(
//          target.getCreatedAt(),
//          head.getCreatedAt(),
//          createdAt,
//          ticket,
//        ),
//      );
//    }
//
//    /**
//     * `moveAfterInternal` moves the given `createdAt` element
//     * at the last of array.
//     */
//    public static moveLastInternal(
//      context: ChangeContext,
//      target: CRDTArray,
//      createdAt: TimeTicket,
//    ): void {
//      const ticket = context.issueTimeTicket();
//      const last = target.getLastCreatedAt();
//      target.moveAfter(last, createdAt, ticket);
//      context.push(
//        MoveOperation.create(target.getCreatedAt(), last, createdAt, ticket),
//      );
//    }
//
//    /**
//     * `insertAfterInternal` inserts the value after the previously created element.
//     */
//    func insertAfterInternal(context: ChangeContext,target: CRDTArray,prevCreatedAt: TimeTicket,value: unknown): CRDTElement {
//      const ticket = context.issueTimeTicket();
//      if (Primitive.isSupport(value)) {
//        const primitive = Primitive.of(value as PrimitiveValue, ticket);
//        const clone = primitive.deepcopy();
//        target.insertAfter(prevCreatedAt, clone);
//        context.registerElement(clone, target);
//        context.push(
//          AddOperation.create(
//            target.getCreatedAt(),
//            prevCreatedAt,
//            primitive,
//            ticket,
//          ),
//        );
//        return primitive;
//      } else if (Array.isArray(value)) {
//        const array = CRDTArray.create(ticket);
//        const clone = array.deepcopy();
//        target.insertAfter(prevCreatedAt, clone);
//        context.registerElement(clone, target);
//        context.push(
//          AddOperation.create(
//            target.getCreatedAt(),
//            prevCreatedAt,
//            array,
//            ticket,
//          ),
//        );
//        for (const element of value) {
//          ArrayProxy.pushInternal(context, clone, element);
//        }
//        return array;
//      } else if (typeof value === 'object') {
//        const obj = CRDTObject.create(ticket);
//        target.insertAfter(prevCreatedAt, obj);
//        context.registerElement(obj, target);
//        context.push(
//          AddOperation.create(target.getCreatedAt(), prevCreatedAt, obj, ticket),
//        );
//
//        for (const [k, v] of Object.entries(value!)) {
//          ObjectProxy.setInternal(context, obj, k, v);
//        }
//        return obj;
//      }
//
//      throw new TypeError(`Unsupported type of value: ${typeof value}`);
//    }
//
//    /**
//     * `insertBeforeInternal` inserts the value before the previously created element.
//     */
//    public static insertBeforeInternal(
//      context: ChangeContext,
//      target: CRDTArray,
//      nextCreatedAt: TimeTicket,
//      value: unknown,
//    ): CRDTElement {
//      return ArrayProxy.insertAfterInternal(
//        context,
//        target,
//        target.getPrevCreatedAt(nextCreatedAt),
//        value,
//      );
//    }
//
//    /**
//     * `deleteInternalByIndex` deletes target element of given index.
//     */
//    public static deleteInternalByIndex(
//      context: ChangeContext,
//      target: CRDTArray,
//      index: number,
//    ): CRDTElement | undefined {
//      const ticket = context.issueTimeTicket();
//      const deleted = target.deleteByIndex(index, ticket);
//      if (!deleted) {
//        return;
//      }
//
//      context.push(
//        RemoveOperation.create(
//          target.getCreatedAt(),
//          deleted.getCreatedAt(),
//          ticket,
//        ),
//      );
//      context.registerRemovedElement(deleted);
//      return deleted;
//    }
//
//    /**
//     * `deleteInternalByID` deletes the element of the given ID.
//     */
//    public static deleteInternalByID(
//      context: ChangeContext,
//      target: CRDTArray,
//      createdAt: TimeTicket,
//    ): CRDTElement {
//      const ticket = context.issueTimeTicket();
//      const deleted = target.delete(createdAt, ticket);
//      context.push(
//        RemoveOperation.create(
//          target.getCreatedAt(),
//          deleted.getCreatedAt(),
//          ticket,
//        ),
//      );
//      context.registerRemovedElement(deleted);
//      return deleted;
//    }
//
//    /**
//     * `splice` is a method to remove elements from the array.
//     */
//    public static splice(
//      context: ChangeContext,
//      target: CRDTArray,
//      start: number,
//      deleteCount?: number,
//      ...items: Array<any>
//    ): JSONArray<JSONElement> {
//      const length = target.length;
//      const from =
//        start >= 0 ? Math.min(start, length) : Math.max(length + start, 0);
//      const to =
//        deleteCount === undefined
//          ? length
//          : deleteCount < 0
//          ? from
//          : Math.min(from + deleteCount, length);
//      const removeds: JSONArray<JSONElement> = [];
//      for (let i = from; i < to; i++) {
//        const removed = ArrayProxy.deleteInternalByIndex(context, target, from);
//        if (removed) {
//          removeds.push(toJSONElement(context, removed)!);
//        }
//      }
//      if (items) {
//        let previousID =
//          from === 0
//            ? target.getHead().getID()
//            : target.getByIndex(from - 1)!.getID();
//        for (const item of items) {
//          const newElem = ArrayProxy.insertAfterInternal(
//            context,
//            target,
//            previousID,
//            item,
//          );
//          previousID = newElem.getID();
//        }
//      }
//      return removeds;
//    }
//
//    /**
//     * `includes` returns true if the given element is in the array.
//     */
//    public static includes(
//      context: ChangeContext,
//      target: CRDTArray,
//      searchElement: JSONElement,
//      fromIndex?: number,
//    ): boolean {
//      const length = target.length;
//      const from =
//        fromIndex === undefined
//          ? 0
//          : fromIndex < 0
//          ? Math.max(fromIndex + length, 0)
//          : fromIndex;
//
//      if (from >= length) return false;
//
//      if (Primitive.isSupport(searchElement)) {
//        const arr = Array.from(target).map((elem) =>
//          toJSONElement(context, elem),
//        );
//        return arr.includes(searchElement, from);
//      }
//
//      for (let i = from; i < length; i++) {
//        if (
//          target.getByIndex(i)?.getID() === (searchElement as CRDTElement).getID()
//        ) {
//          return true;
//        }
//      }
//      return false;
//    }
//
//    /**
//     * `indexOf` returns the index of the given element.
//     */
//    public static indexOf(
//      context: ChangeContext,
//      target: CRDTArray,
//      searchElement: JSONElement,
//      fromIndex?: number,
//    ): number {
//      const length = target.length;
//      const from =
//        fromIndex === undefined
//          ? 0
//          : fromIndex < 0
//          ? Math.max(fromIndex + length, 0)
//          : fromIndex;
//
//      if (from >= length) return -1;
//
//      if (Primitive.isSupport(searchElement)) {
//        const arr = Array.from(target).map((elem) =>
//          toJSONElement(context, elem),
//        );
//        return arr.indexOf(searchElement, from);
//      }
//
//      for (let i = from; i < length; i++) {
//        if (
//          target.getByIndex(i)?.getID() === (searchElement as CRDTElement).getID()
//        ) {
//          return i;
//        }
//      }
//      return -1;
//    }
//
//    /**
//     * `lastIndexOf` returns the last index of the given element.
//     */
//    public static lastIndexOf(
//      context: ChangeContext,
//      target: CRDTArray,
//      searchElement: JSONElement,
//      fromIndex?: number,
//    ): number {
//      const length = target.length;
//      const from =
//        fromIndex === undefined || fromIndex >= length
//          ? length - 1
//          : fromIndex < 0
//          ? fromIndex + length
//          : fromIndex;
//
//      if (from < 0) return -1;
//
//      if (Primitive.isSupport(searchElement)) {
//        const arr = Array.from(target).map((elem) =>
//          toJSONElement(context, elem),
//        );
//        return arr.lastIndexOf(searchElement, from);
//      }
//
//      for (let i = from; i > 0; i--) {
//        if (
//          target.getByIndex(i)?.getID() === (searchElement as CRDTElement).getID()
//        ) {
//          return i;
//        }
//      }
//      return -1;
//    }
//
//    /**
//     * `getHandlers` gets handlers.
//     */
//    public getHandlers(): any {
//      return this.handlers;
//    }
}
