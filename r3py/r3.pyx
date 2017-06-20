# cython: language_level=3

cimport cython
import numpy
from cpython.pycapsule cimport PyCapsule_New, PyCapsule_GetPointer

from . cimport r3


cdef class Methods:

    property METHOD_GET:

        def __get__(self):
            return < int > r3.METHOD_GET

    property METHOD_POST:

        def __get__(self):
            return < int > r3.METHOD_POST

    property METHOD_PUT:

        def __get__(self):
            return < int > r3.METHOD_PUT

    property METHOD_DELETE:

        def __get__(self):
            return < int > r3.METHOD_DELETE

    property METHOD_PATCH:

        def __get__(self):
            return < int > r3.METHOD_PATCH

    property METHOD_HEAD:

        def __get__(self):
            return < int > r3.METHOD_HEAD

    property METHOD_OPTIONS:

        def __get__(self):
            return < int > r3.METHOD_OPTIONS

    property METHOD_ALL:

        def __get__(self):
            return < int > self.METHOD_GET | self.METHOD_POST | \
                self.METHOD_PUT | self.METHOD_DELETE | self.METHOD_PATCH | \
                self.METHOD_HEAD | self.METHOD_OPTIONS


cdef class MatchEntry(Methods):

    def __cinit__(self, bytes path):
        self._match_entry = r3.match_entry_create(path)

    property request_method:

        def __get__(self):
            return < int > self._match_entry.request_method

        def __set__(self, int method):
            self._match_entry.request_method = <int > method

        def __del__(self):
            self._match_entry.request_method = 573076590

    property path:

        def __get__(self):
            return < bytes > self._match_entry.path

        def __set__(self, bytes path):
            self._match_entry.path = <const char * >path

    property vars:

        def __get__(self):
            vars = []
            for i in range(0, self._match_entry.vars.len):
                vars.append(self._match_entry.vars.tokens[i])
            return vars

    def get_capsule(self):
        return PyCapsule_New(self._match_entry, 'match_entry', NULL)

    def __dealloc__(self):
        if self._match_entry:
            r3.match_entry_free(self._match_entry)


cdef class Tree(Methods):

    def __cinit__(self, int cap=10):
        self._node = r3.r3_tree_create(cap)

    cdef r3.match_entry * get_match_entry(self, MatchEntry match_entry):
        return < r3.match_entry * > < void * >PyCapsule_GetPointer(
            match_entry.get_capsule(), 'match_entry'
        )

    cpdef compile(self):
        r3.r3_tree_compile(self._node, NULL)

    cpdef dump(self, int level):
        r3.r3_tree_dump(self._node, level)

    cpdef insert_path(self, bytes path, object data):
        r3.r3_tree_insert_path(self._node, path, < void * >data)

    cpdef match_entry(self, MatchEntry match_entry):
        cdef r3.node * _node
        cdef r3.match_entry * _match_entry
        _match_entry = <r3.match_entry * > self.get_match_entry(match_entry)
        if _match_entry:
            _node = r3.r3_tree_match_entry(self._node, _match_entry)
            if not _node:
                return
            return {
                'data': < object > < void * >_node.data
            }
        return

    cpdef match_route(self, MatchEntry match_entry):
        cdef r3.route * _route
        cdef r3.match_entry * _match_entry
        _match_entry = <r3.match_entry * > self.get_match_entry(match_entry)
        if _match_entry:
            _route = r3.r3_tree_match_route(self._node, _match_entry)
            if not _route:
                return
            return {
                'data': < object > < void * >_route.data
            }
        return

    cpdef match(self, bytes path):
        cdef r3.node * _node
        _node = r3.r3_tree_match(self._node, path, NULL)
        if not _node:
            return
        return {
            'data': < object > < void * >_node.data
        }

    cpdef insert_route(self, int method, bytes path, object data):
        r3.r3_tree_insert_route(self._node, method, path, < void * >data)

    def __dealloc__(self):
        r3.r3_tree_free(self._node)
