# cython: language_level=3

from cpython.pycapsule cimport PyCapsule_New, PyCapsule_GetPointer


GET = METHOD_GET
POST = METHOD_POST
PUT = METHOD_PUT
DELETE = METHOD_DELETE
PATCH = METHOD_PATCH
HEAD = METHOD_HEAD
OPTIONS= METHOD_OPTIONS
ALL = METHOD_GET | METHOD_POST | METHOD_PUT | METHOD_DELETE | \
      METHOD_PATCH | METHOD_HEAD | METHOD_OPTIONS

cdef class Tree:

    def __cinit__(self, int cap=10):
        self._node = r3_tree_create(cap)

    def __dealloc__(self):
        r3_tree_free(self._node)

    cpdef insert_path(self, bytes path, object data):
        r3_tree_insert_path(self._node, path, < void * >data)

    cpdef insert_route(self, int method, bytes path, object data):
        r3_tree_insert_route(self._node, method, path, < void * >data)

    cpdef compile(self):
        r3_tree_compile(self._node, NULL)

    cpdef dump(self, int level):
        r3_tree_dump(self._node, level)

    cdef match_entry * get_match_entry(self, MatchEntry m):
        return < match_entry * > < void * >PyCapsule_GetPointer(
            m.get_capsule(), 'match_entry'
        )

    cpdef match_route(self, MatchEntry m):
        cdef R3Route * _route
        cdef match_entry * _match_entry
        _match_entry = <match_entry * > self.get_match_entry(m)
        if _match_entry:
            _route = r3_tree_match_route(self._node, _match_entry)
            if not _route:
                return
            return {
                'data': < object > < void * >_route.data
            }
        return


cdef class MatchEntry:

    def __cinit__(self, bytes path):
        self._match_entry = match_entry_create(path)

    property request_method:

        def __get__(self):
            return < int > self._match_entry.request_method

        def __set__(self, int method):
            self._match_entry.request_method = <int > method

        def __del__(self):
            self._match_entry.request_method = 0

    property path:

        def __get__(self):
            return < bytes > self._match_entry.path.base

        def __set__(self, bytes path):
            self._match_entry.path.base = <char * >path
            self._match_entry.path.len = len(self._match_entry.path.base)

    property vars:

        def __get__(self):
            vars = {}
            for i in range(0, self._match_entry.vars.slugs.size):
                vars.update({
                    self._match_entry.vars.slugs.entries[i].base[
                        :self._match_entry.vars.slugs.entries[i].len]:
                    self._match_entry.vars.tokens.entries[i].base[
                        :self._match_entry.vars.tokens.entries[i].len]
                })
            return vars

    cpdef get_capsule(self):
        return PyCapsule_New(self._match_entry, 'match_entry', NULL)

    def __dealloc__(self):
        if self._match_entry:
            match_entry_free(self._match_entry)
