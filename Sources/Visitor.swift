//
//  Visitor.swift
//  MiniDOM
//
//  Copyright 2017 Anodized Software, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

// MARK: - Visitor Protocol

/**
 The [Visitor Design Pattern](https://en.wikipedia.org/wiki/Visitor_pattern) is
 used throughout the MiniDOM library to implement algorithms that involve
 traversing the DOM tree. It provides a convenient mechanism to separate an
 algorithm from the object structure on which it operates. It allows operations
 to be added to the DOM structure without modifying the structures themselves.

 A `Visitor` object is provided to `Node.accept(_:)` to start the traversal. The
 `Node` object calls the appropriate methods on the `Visitor` object before
 calling `Node.accept(_:)` on its child nodes, performing the recursive
 traversal.

 The `Visitor` protocol defines methods that correspond to each of the `Node`
 types in the DOM. Types implementing the `Visitor` protocol do not need to
 deal with the actual traversal; its methods are called by the traversal
 algorithm provided by the DOM classes.

 For a simple example of a visitor, see the `ElementSearch` class in
 `Search.swift`. For a more complex example of a visitor, see the 
 `PrettyPrinter` class in `Formatter.swift`.
 */
public protocol Visitor {

    /**
     Called when the traversal algorithm encounters a `Document` object before
     its `children` are traversed.

     Visiting a `Document` object is split into a begin and end method to
     allow implementing operations before and after the `children` of the
     `Document` object are visited.
     */
    func beginVisit(_ document: Document)

    /**
     Called when the traversal algorithm encounters a `Document` object after
     its `children` are traversed.

     Visiting a `Document` object is split into a begin and end method to
     allow implementing operations before and after the `children` of the
     `Document` object are visited.
     */
    func endVisit(_ document: Document)

    /**
     Called when the traversal algorithm encounters an `Element` object before
     its `children` are traversed.

     Visiting an `Element` object is split into a begin and end method to
     allow implementing operations before and after the `children` of the
     `Element` object are visited.
     */
    func beginVisit(_ element: Element)

    /**
     Called when the traversal algorithm encounters an `Element` object after
     its `children` are traversed.

     Visiting an `Element` object is split into a begin and end method to
     allow implementing operations before and after the `children` of the
     `Element` object are visited.
     */
    func endVisit(_ element: Element)

    /**
     Called when the traversal algorithm encounters a `Text` object.
     */
    func visit(_ text: Text)

    /**
     Called when the traversal algorithm encounters a `ProcessingInstruction`
     object.
     */
    func visit(_ processingInstruction: ProcessingInstruction)

    /**
     Called when the traversal algorithm encounters a `Comment` object.
     */
    func visit(_ comment: Comment)

    /**
     Called when the traversal algorithm encounters an `CDATASection` object.
     */
    func visit(_ cdataSection: CDATASection)
}

/**
 Instead of making the `Visitor` protocol functions optional or requiring
 implementing types to define all of the functions (including ones that may be
 unnecessary for the implementing type's purpose), a default empty
 implementation of each of the functions is provided.
 */
public extension Visitor {

    /// Default implementation does nothing.
    func beginVisit(_ document: Document) {}

    /// Default implementation does nothing.
    func endVisit(_ document: Document) {}

    /// Default implementation does nothing.
    func beginVisit(_ element: Element) {}

    /// Default implementation does nothing.
    func endVisit(_ element: Element) {}

    /// Default implementation does nothing.
    func visit(_ text: Text) {}

    /// Default implementation does nothing.
    func visit(_ processingInstruction: ProcessingInstruction) {}

    /// Default implementation does nothing.
    func visit(_ comment: Comment) {}

    /// Default implementation does nothing.
    func visit(_ cdataSection: CDATASection) {}
}

// MARK: - Visitable Protocol

/**
 The `Visitable` protocol is used to indicate a node can accept a visitor.
 */
public protocol Visitable {
    /**
     Called to begin traversing the sub-tree rooted at this node.

     - parameter visitor: The `Visitor` object whose functions will be invoked
     during the traversal of the sub-tree rooted at this node.
     */
    func accept(_ visitor: Visitor)
}

extension Document: Visitable {
    /**
     A document node first calls `beginVisit(self)` on the visitor. It then
     calls `accept` on each of the nodes in the `children` array, passing the
     visitor object. Finally, it calls `endVisit(self)` on the visitor.
     */
    public func accept(_ visitor: Visitor) {
        visitor.beginVisit(self)

        for child in children {
            child.accept(visitor)
        }

        visitor.endVisit(self)
    }
}

extension Element: Visitable {
    /**
     An element node first calls `beginVisit(self)` on the visitor. It then
     calls `accept` on each of the nodes in the `children` array, passing the
     visitor object. Finally, it calls `endVisit(self)` on the visitor.
     */
    public func accept(_ visitor: Visitor) {
        visitor.beginVisit(self)

        for child in children {
            child.accept(visitor)
        }

        visitor.endVisit(self)
    }
}

extension Text: Visitable {
    /**
     A text node calls `visit(self)` on the visitor.
     */
    public func accept(_ visitor: Visitor) {
        visitor.visit(self)
    }
}

extension ProcessingInstruction: Visitable {
    /**
     A processing instruction node calls `visit(self)` on the visitor.
     */
    public func accept(_ visitor: Visitor) {
        visitor.visit(self)
    }
}

extension Comment: Visitable {
    /**
     A comment node calls `visit(self)` on the visitor.
     */
    public func accept(_ visitor: Visitor) {
        visitor.visit(self)
    }
}

extension CDATASection: Visitable {
    /**
     A CDATA section node calls `visit(self)` on the visitor.
     */
    public func accept(_ visitor: Visitor) {
        visitor.visit(self)
    }
}
