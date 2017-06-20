# cython: language_level=3

cdef extern from "pcre.h":

    struct real_pcre
    ctypedef real_pcre pcre

    ctypedef struct pcre_extra:
        unsigned long int flags
        void * study_data
        unsigned long int match_limit
        void * callout_data
        const unsigned char * tables
        unsigned long int match_limit_recursion
        unsigned char ** mark
        void * executable_jit

cdef extern from "r3/r3_define.h":

    ctypedef unsigned char bool


cdef extern from "r3/str_array.h":

    ctypedef struct _str_array:
        char ** tokens
        int len
        int cap

    ctypedef _str_array str_array

cdef extern from "r3/r3.h":

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

    ctypedef _edge edge
    ctypedef _node node
    ctypedef _route route

    cdef struct _edge:
        char * pattern
        node * child
        unsigned int pattern_len
        unsigned int opcode
        unsigned char has_slug

    cdef struct _node:
        edge ** edges
        char * combined_pattern
        pcre * pcre_pattern
        pcre_extra * pcre_extra
        unsigned int edge_len
        unsigned int compare_type
        unsigned char endpoint
        unsigned char ov_cnt
        unsigned char edge_cap
        unsigned char route_len
        unsigned char route_cap
        route ** routes
        void * data

    ctypedef struct _route:
        char * path
        int path_len
        int request_method
        char * host
        int host_len
        void * data
        char * remote_addr_pattern
        int remote_addr_pattern_len

    ctypedef struct match_entry:
        str_array * vars
        const char * path
        int path_len
        int request_method
        void * data
        char * host
        int host_len
        char * remote_addr
        int remote_addr_len

    # Tree
    node * r3_tree_create(int cap)
    void r3_tree_free(node * tree)
    int r3_tree_compile(node * tree, char ** errstr)
    node * r3_tree_insert_path(node * tree, const char * path, void * data)
    node * r3_tree_match(const node * tree, const char * path, match_entry * entry)
    void r3_tree_dump(const node * tree, int level)
    route * r3_tree_insert_route(node * tree, int method, const char * path, void * data)
    route * r3_tree_match_route(const node * n, match_entry * entry)
    void r3_route_free(route * route)
    node * r3_tree_match_entry(const node * tree, match_entry * entry)

    # MatchEntry
    match_entry * match_entry_create(const char * path)
    void match_entry_free(match_entry * entry)


cdef class Methods:

    cdef:
        int GET
        int POST
        int PUT
        int DELETE
        int PATCH
        int HEAD
        int OPTIONS


cdef class MatchEntry(Methods):

    cdef:
        match_entry * _match_entry


cdef class Tree(Methods):

    cdef:
        node * _node

    cdef match_entry * get_match_entry(self, MatchEntry match_entry)
    cpdef compile(self)
    cpdef dump(self, int level)
    cpdef insert_path(self, bytes path, object data)
    cpdef match_entry(self, MatchEntry match_entry)
    cpdef match_route(self, MatchEntry match_entry)
    cpdef match(self, bytes path)
    cpdef insert_route(self, int method, bytes path, object data)
