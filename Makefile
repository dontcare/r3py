.PHONY: compile release clean

compile:
	cython r3py/r3.pyx;
	python setup.py build_ext --inplace;

all: clean compile

release: compile
	python setup.py sdist upload

clean:
	rm -rf build/;
	rm -f r3py/*.c;
	rm -f r3py/*.h;
	rm -f r3py/*.so;
