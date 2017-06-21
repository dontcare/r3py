R3PY
====

.. image:: https://img.shields.io/pypi/v/r3py.svg
    :target: https://pypi.python.org/pypi/r3py


libr3 is a high-performance path dispatching library. It compiles your route paths into a prefix tree (trie). By using the constructed prefix trie in the start-up time, you may dispatch your routes with efficiency http://c9s.github.com/r3/bench.html


R3py requires Python 2.7, 3.4+, libr3 and is available on PyPI.

Ubuntu
------

``sudo apt-get install libr3-dev libr3-0``

Debian
------


``sudo apt-get install libr3-dev libr3``


Use pip to install it::

    pip install r3py

Using
-----

.. code:: python

    import r3py


    def data1():
        print("Data 2")

    def data2():
        print("Data 3")

    def data3():
        print("Data 4")

    tree = r3py.Tree(10)
    tree.insert_route(tree.METHOD_GET, b"/", data1)
    tree.insert_route(tree.METHOD_GET | tree.METHOD_POST, b"/test", data2)
    tree.insert_route(tree.METHOD_ALL, b"/test/{id}", data3)

    match_entry = r3py.MatchEntry(b"/test")
    match_entry.request_method = match_entry.METHOD_GET

    result = tree.match_route(match_entry)
    result['data']() # Data2
