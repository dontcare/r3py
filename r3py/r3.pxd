# cython: language_level=3


cdef extern from "../vendors/r3/include/memory.h":

    ctypedef struct st_r3_iovec_t:
        char *base
        unsigned int len

    ctypedef st_r3_iovec_t r3_iovec_t

    cdef struct _r3_iovec_t:
        r3_iovec_t *entries
        unsigned int size
        unsigned int capacity


cdef extern from "../vendors/r3/include/r3.h":

    cdef struct _str_array:
         _r3_iovec_t slugs
         _r3_iovec_t tokens

    ctypedef _str_array str_array

    cdef int METHOD_GET
    cdef int METHOD_POST
    cdef int METHOD_PUT
    cdef int METHOD_DELETE
    cdef int METHOD_PATCH
    cdef int METHOD_HEAD
    cdef int METHOD_OPTIONS

    cdef struct edge
    cdef struct node
    cdef struct route

    ctypedef _edge R3Edge
    ctypedef _node R3Node
    ctypedef _R3Route R3Route
    ctypedef _R3Entry match_entry

    cdef struct _edge:
        pass

    cdef struct _node:
        void * data

    ctypedef struct _R3Route:
        int request_method
        #r3_iovec_t path
        void * data

    ctypedef struct _R3Entry:
        int request_method
        r3_iovec_t path
        str_array vars
        void * data


    # Tree
    R3Node * r3_tree_create(int cap)
    void r3_tree_free(R3Node * tree)
    R3Node * r3_tree_insert_path(R3Node *tree, const char *path, void * data)
    R3Route * r3_tree_insert_route(R3Node * tree, int method, const char *path, void *data)
    int r3_tree_compile(R3Node *n, char** errstr)
    void r3_tree_dump(const R3Node * n, int level)
    R3Route * r3_tree_match_route(const R3Node *n, match_entry * entry)

    # MatchEntry
    match_entry * match_entry_create(const char * path)
    void match_entry_free(match_entry * entry)


cdef class Tree:

    cdef:
        R3Node * _node

    cpdef insert_path(self, bytes path, object data)
    cpdef insert_route(self, int method, bytes path, object data)
    cpdef compile(self)
    cpdef dump(self, int level)
    cpdef match_route(self, MatchEntry match_entry)
    cdef match_entry * get_match_entry(self, MatchEntry match_entry)


cdef class MatchEntry:

    cdef:
        match_entry * _match_entry

    cpdef get_capsule(self)
