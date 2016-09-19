include versions/openblas.version
include versions/lapack.version
include versions/gsl.version
include versions/boost.version
include versions/matio.version
include versions/zlib.version

ROOT_PATH = $(realpath .)

.PHONY: clean-openblas clean-openblas-tar cleanall-openblas \
	clean-boost clean-boost-tar cleanall-boost \
	clean-gsl clean-gsl-tar cleanall-gsl \
	clean-matio clean-matio-tar cleanall-matio \
	clean-zlib clean-zlib-tar cleanall-zlib \
	clean-lapack clean-lapack-tar cleanall-lapack \
	download

download: sources/OpenBLAS/32 sources/OpenBLAS/64 sources/Boost sources/Gsl sources/Lapack sources/matIO sources/Slicot sources/Zlib

build: build-openblas

clean: clean-openblas clean-boost clean-gsl clean-lapack clean-matio clean-slicot clean-zlib

cleanall: cleanall-openblas cleanall-boost cleanall-gsl cleanall-lapack cleanall-matio cleanall-slicot cleanall-zlib

#
# OpenBLAS library
#

sources/OpenBLAS/32: v${OPENBLAS_VERSION}.tar.gz
	mkdir -p tmp-openblas-32
	tar -zxf v${OPENBLAS_VERSION}.tar.gz --directory tmp-openblas-32
	mkdir -p sources/OpenBLAS/32
	mv tmp-openblas-32/OpenBLAS-${OPENBLAS_VERSION}/* sources/OpenBLAS/32
	rm -rf tmp-openblas-32

sources/OpenBLAS/64: v${OPENBLAS_VERSION}.tar.gz
	mkdir -p tmp-openblas-64
	tar -zxf v${OPENBLAS_VERSION}.tar.gz --directory tmp-openblas-64
	mkdir -p sources/OpenBLAS/64
	mv tmp-openblas-64/OpenBLAS-${OPENBLAS_VERSION}/* sources/OpenBLAS/64
	rm -rf tmp-openblas-64

v${OPENBLAS_VERSION}.tar.gz: versions/openblas.version
	wget http://github.com/xianyi/OpenBLAS/archive/v${OPENBLAS_VERSION}.tar.gz
	touch v${OPENBLAS_VERSION}.tar.gz

clean-openblas: clean-openblas-32 clean-openblas-64

clean-openblas-tar:
	rm -f v${OPENBLAS_VERSION}.tar.gz

cleanall-openblas: clean-openblas clean-openblas-tar

clean-openblas-32:
	rm -rf sources/OpenBLAS/32

clean-openblas-64:
	rm -rf sources/OpenBLAS/64

lib32/OpenBLAS/libopenblas.a: sources/OpenBLAS/32
	patch sources/OpenBLAS/32/Makefile.rule < patch/openblas-w32.patch
	make -C sources/OpenBLAS/32
	i686-w64-mingw32-strip --strip-debug sources/OpenBLAS/32/libopenblasp-r${OPENBLAS_VERSION}.a
	mkdir -p lib32/OpenBLAS
	cp sources/OpenBLAS/32/libopenblasp-r${OPENBLAS_VERSION}.a lib32/OpenBLAS/libopenblas.a

lib64/OpenBLAS/libopenblas.a: sources/OpenBLAS/64
	patch sources/OpenBLAS/64/Makefile.rule < patch/openblas-w64.patch
	make -C sources/OpenBLAS/64
	x86_64-w64-mingw32-strip --strip-debug sources/OpenBLAS/64/libopenblasp-r${OPENBLAS_VERSION}.a
	mkdir -p lib64/OpenBLAS
	cp sources/OpenBLAS/64/libopenblasp-r${OPENBLAS_VERSION}.a lib64/OpenBLAS/libopenblas.a

clean-libopenblas: clean-libopenblas-32 clean-libopenblas-64

clean-libopenblas-32:
	rm -rf lib32/OpenBLAS

clean-libopenblas-64:
	rm -rf lib64/OpenBLAS

build-openblas: lib32/OpenBLAS/libopenblas.a lib64/OpenBLAS/libopenblas.a

#
# Boost library
#

sources/Boost: boost_${BOOST_VERSION}.tar.bz2
	rm -rf sources/Boost
	tar xjf boost_${BOOST_VERSION}.tar.bz2
	mkdir sources/Boost
	mv boost_${BOOST_VERSION}/* sources/Boost
	rm -r boost_${BOOST_VERSION}

boost_${BOOST_VERSION}.tar.bz2: versions/boost.version
	rm -f boost_${BOOST_VERSION}.tar.bz2
	wget https://sourceforge.net/projects/boost/files/boost/`echo "${BOOST_VERSION}" | sed -e 's/_/./g'`/boost_${BOOST_VERSION}.tar.bz2/download -O boost_${BOOST_VERSION}.tar.bz2
	touch boost_${BOOST_VERSION}.tar.bz2

build-boost: sources/Boost
	mkdir -p lib32/Boost/include
	mkdir -p lib64/Boost/include
	ln -s ${ROOT_PATH}/sources/Boost/boost ${ROOT_PATH}/lib32/Boost/include/boost
	ln -s ${ROOT_PATH}/sources/Boost/boost ${ROOT_PATH}/lib64/Boost/include/boost

clean-boost:
	rm -fr sources/Boost

clean-libboost:
	rm -fr lib32/Boost
	rm -fr lib64/Boost

clean-boost-tar:
	rm -f boost_${BOOST_VERSION}.tar.bz2

cleanall-boost: clean-boost clean-boost-tar

#
# Gsl
#

sources/Gsl/32: gsl-${GSL_VERSION}.tar.gz
	mkdir -p tmp-gsl-32 
	tar -zxf gsl-${GSL_VERSION}.tar.gz --directory tmp-gsl-32
	mkdir -p sources/Gsl/32
	mv tmp-gsl-32/gsl-${GSL_VERSION}/* sources/Gsl/32
	rm -rf tmp-gsl-32

sources/Gsl/64: gsl-${GSL_VERSION}.tar.gz
	mkdir -p tmp-gsl-64 
	tar -zxf gsl-${GSL_VERSION}.tar.gz --directory tmp-gsl-64
	mkdir -p sources/Gsl/64
	mv tmp-gsl-64/gsl-${GSL_VERSION}/* sources/Gsl/64
	rm -rf tmp-gsl-64

gsl-${GSL_VERSION}.tar.gz: versions/gsl.version
	wget http://fr.mirror.babylon.network/gnu/gsl/gsl-${GSL_VERSION}.tar.gz
	touch gsl-${GSL_VERSION}.tar.gz

lib32/Gsl/lib/libgsl.a: sources/Gsl/32
	cd sources/Gsl/32 && ./configure --host=i686-w64-mingw32 --prefix=${ROOT_PATH}/lib32/Gsl --disable-shared --enable-static && make && make install

lib64/Gsl/lib/libgsl.a: sources/Gsl/64
	cd sources/Gsl/64 && ./configure --host=x86_64-w64-mingw32 --prefix=${ROOT_PATH}/lib64/Gsl --disable-shared --enable-static && make && make install

build-gsl: lib32/Gsl/lib/libgsl.a lib64/Gsl/lib/libgsl.a

clean-gsl: clean-gsl-32 clean-64

clean-libgsl: clean-libgsl-32 clean-libgsl-64

clean-gsl-tar:
	rm -f gsl-${GSL_VERSION}.tar.gz

cleanall-gsl: clean-gsl clean-gsl-tar

clean-gsl-32:
	rm -rf sources/Gsl/32

clean-gsl-64:
	rm -rf sources/Gsl/64

clean-libgsl-32:
	rm -rf lib32/Gsl

clean-libgsl-64:
	rm -rf lib64/Gsl

#
# Lapack
#

sources/Lapack/32: lapack-${LAPACK_VERSION}.tgz
	mkdir -p tmp-lapack-32
	tar -zxf lapack-${LAPACK_VERSION}.tgz --directory tmp-lapack-32
	mkdir -p sources/Lapack/32
	mv tmp-lapack-32/lapack-${LAPACK_VERSION}/* sources/Lapack/32
	rm -rf tmp-lapack-32

sources/Lapack/64: lapack-${LAPACK_VERSION}.tgz
	mkdir -p tmp-lapack-64
	tar -zxf lapack-${LAPACK_VERSION}.tgz --directory tmp-lapack-64
	mkdir -p sources/Lapack/64
	mv tmp-lapack-64/lapack-${LAPACK_VERSION}/* sources/Lapack/64
	rm -rf tmp-lapack-64

lapack-${LAPACK_VERSION}.tgz: versions/lapack.version
	wget http://www.netlib.org/lapack/lapack-${LAPACK_VERSION}.tgz
	touch lapack-${LAPACK_VERSION}.tgz

lib32/Lapack/liblapack.a: sources/Lapack/32
	cp sources/Lapack/32/make.inc.example sources/Lapack/32/make.inc
	patch sources/Lapack/32/make.inc < patch/lapack-w32.patch
	make -C sources/Lapack/32/SRC
	i686-w64-mingw32-strip --strip-debug sources/Lapack/32/liblapack.a
	mkdir -p lib32/Lapack
	mv sources/Lapack/32/liblapack.a lib32/Lapack/liblapack.a

lib64/Lapack/liblapack.a: sources/Lapack/64
	cp sources/Lapack/64/make.inc.example sources/Lapack/64/make.inc
	patch sources/Lapack/64/make.inc < patch/lapack-w64.patch
	make -C sources/Lapack/64/SRC
	x86_64-w64-mingw32-strip --strip-debug sources/Lapack/64/liblapack.a
	mkdir -p lib64/Lapack
	mv sources/Lapack/64/liblapack.a lib64/Lapack/liblapack.a

build-lapack: lib32/Lapack/liblapack.a lib64/Lapack/liblapack.a

clean-lapack: clean-lapack-32 clean-lapack-64

clean-liblapack: clean-liblapack-32 clean-liblapack-64

clean-lapack-tar:
	rm -f lapack-${LAPACK_VERSION}.tgz

cleanall-lapack: clean-lapack clean-lapack-tar

clean-liblapack-32:
	rm -rf lib32/Lapack

clean-liblapack-64:
	rm -rf lib64/Lapack

clean-lapack-32:
	rm -rf sources/Lapack/32

clean-lapack-64:
	rm -rf sources/Lapack/64

#
# matIO
#

sources/matIO/32: matio-${MATIO_VERSION}.tar.gz
	mkdir -p tmp-matio-32
	tar -zxf matio-${MATIO_VERSION}.tar.gz --directory tmp-matio-32
	mkdir -p sources/matIO/32
	mv tmp-matio-32/matio-${MATIO_VERSION}/* sources/matIO/32
	rm -rf tmp-matio-32

sources/matIO/64: matio-${MATIO_VERSION}.tar.gz
	mkdir -p tmp-matio-64
	tar -zxf matio-${MATIO_VERSION}.tar.gz --directory tmp-matio-64
	mkdir -p sources/matIO/64
	mv tmp-matio-64/matio-${MATIO_VERSION}/* sources/matIO/64
	rm -rf tmp-matio-64

matio-${MATIO_VERSION}.tar.gz: versions/matio.version
	wget https://sourceforge.net/projects/matio/files/matio/${MATIO_VERSION}/matio-${MATIO_VERSION}.tar.gz/download -O matio-${MATIO_VERSION}.tar.gz
	touch matio-${MATIO_VERSION}.tar.gz

lib32/matIO/lib/libmatio.a: sources/matIO/32 lib32/Zlib/lib/libz.a
	cd sources/matIO/32 && CROSS_PREFIX=i686-w64-mingw32- ./configure --disable-shared --with-zlib=${ROOT_PATH}/lib32/Zlib --prefix=${ROOT_PATH}/lib32/matIO && make install

lib64/matIO/lib/libmatio.a: sources/matIO/64 lib64/Zlib/lib/libz.a
	cd sources/matIO/64 && CROSS_PREFIX=x86_64-w64-mingw32- ./configure --disable-shared --with-zlib=${ROOT_PATH}/lib64/Zlib --prefix=${ROOT_PATH}/lib64/matIO && make install

build-matio: build-zlib lib32/matIO/lib/libmatio.a lib64/matIO/lib/libmatio.a

clean-matio: clean-matio-32 clean-matio-64

clean-libmatio: clean-libmatio-32 clean-libmatio-64

clean-matio-tar:
	rm -f matio-${MATIO_VERSION}.tar.gz

cleanall-matio: clean-matio clean-matio-tar

clean-matio-32:
	rm -rf sources/matIO/32

clean-matio-64:
	rm -rf sources/matIO/64

clean-libmatio-32:
	rm -rf lib32/matIO

clean-libmatio-64:
	rm -rf lib64/matIO

#
# Slicot
#

sources/Slicot/32/without-underscore: slicot45.tar.gz
	mkdir -p tmp-slicot-32-without-underscore
	tar -zxf slicot45.tar.gz --directory tmp-slicot-32-without-underscore
	mkdir -p sources/Slicot/32/without-underscore
	mv tmp-slicot-32-without-underscore/slicot/* sources/Slicot/32/without-underscore
	rm -r tmp-slicot-32-without-underscore

sources/Slicot/32/with-underscore: slicot45.tar.gz
	mkdir -p tmp-slicot-32-with-underscore
	tar -zxf slicot45.tar.gz --directory tmp-slicot-32-with-underscore
	mkdir -p sources/Slicot/32/with-underscore
	mv tmp-slicot-32-with-underscore/slicot/* sources/Slicot/32/with-underscore
	rm -r tmp-slicot-32-with-underscore

sources/Slicot/64/with-32bit-integer: slicot45.tar.gz
	mkdir -p tmp-slicot-64-with-32bit-integer
	tar -zxf slicot45.tar.gz --directory tmp-slicot-64-with-32bit-integer
	mkdir -p sources/Slicot/64/with-32bit-integer
	mv tmp-slicot-64-with-32bit-integer/slicot/* sources/Slicot/64/with-32bit-integer
	rm -r tmp-slicot-64-with-32bit-integer

sources/Slicot/64/with-64bit-integer: slicot45.tar.gz
	mkdir -p tmp-slicot-64-with-64bit-integer
	tar -zxf slicot45.tar.gz --directory tmp-slicot-64-with-64bit-integer
	mkdir -p sources/Slicot/64/with-64bit-integer
	mv tmp-slicot-64-with-64bit-integer/slicot/* sources/Slicot/64/with-64bit-integer
	rm -r tmp-slicot-64-with-64bit-integer

slicot45.tar.gz:
	wget --user-agent="User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:10.0) Gecko/20100101 Firefox/10.0" -c http://slicot.org/objects/software/shared/slicot45.tar.gz
	touch slicot45.tar.gz

lib32/Slicot/without-underscore/libslicot_pic.a: sources/Slicot/32/without-underscore
	patch sources/Slicot/32/without-underscore/make.inc < patch/slicot-32-without-underscore.patch
	make -C sources/Slicot/32/without-underscore lib
	i686-w64-mingw32-strip --strip-debug sources/Slicot//32/without-underscore/libslicot_pic.a
	mkdir -p lib32/Slicot/without-underscore
	mv sources/Slicot/32/without-underscore/libslicot_pic.a lib32/Slicot/without-underscore/libslicot_pic.a

lib32/Slicot/with-underscore/libslicot_pic.a: sources/Slicot/32/with-underscore
	patch sources/Slicot/32/with-underscore/make.inc < patch/slicot-32-with-underscore.patch
	make -C sources/Slicot/32/with-underscore lib
	i686-w64-mingw32-strip --strip-debug sources/Slicot/32/with-underscore/libslicot_pic.a
	mkdir -p lib32/Slicot/with-underscore
	mv sources/Slicot/32/with-underscore/libslicot_pic.a lib32/Slicot/with-underscore/libslicot_pic.a

lib64/Slicot/libslicot_pic.a: sources/Slicot/64/with-32bit-integer
	patch sources/Slicot/64/with-32bit-integer/make.inc < patch/slicot-64-with-32bit-integer.patch
	make -C sources/Slicot/64/with-32bit-integer lib
	x86_64-w64-mingw32-strip --strip-debug sources/Slicot/64/with-32bit-integer/libslicot_pic.a
	mkdir -p lib64/Slicot
	mv sources/Slicot/64/with-32bit-integer/libslicot_pic.a lib64/Slicot/libslicot_pic.a

lib64/Slicot/libslicot64_pic.a: sources/Slicot/64/with-64bit-integer
	patch sources/Slicot/64/with-64bit-integer/make.inc < patch/slicot-64-with-64bit-integer.patch
	make -C sources/Slicot/64/with-64bit-integer lib
	x86_64-w64-mingw32-strip --strip-debug sources/Slicot/64/with-64bit-integer/libslicot64_pic.a
	mkdir -p lib64/Slicot
	mv sources/Slicot/64/with-64bit-integer/libslicot64_pic.a lib64/Slicot/libslicot64_pic.a

build-slicot: lib32/Slicot/without-underscore/libslicot_pic.a lib32/Slicot/with-underscore/libslicot_pic.a lib64/Slicot/libslicot_pic.a lib64/Slicot/libslicot64_pic.a

clean-slicot: clean-slicot-32-with-underscore clean-slicot-32-without-underscore clean-slicot-64-with-32bit-integer clean-slicot-64-with-64bit-integer

clean-libslicot: clean-libslicot-32-without-underscore clean-libslicot-32-with-underscore clean-libslicot-64

clean-slicot-tar:
	rm -f slicot45.tar.gz

cleanall-slicot: clean-slicot clean-slicot-tar

clean-slicot-32-with-underscore:
	rm -rf sources/Slicot/32/with-underscore

clean-slicot-32-without-underscore:
	rm -rf sources/Slicot/32/without-underscore

clean-slicot-64-with-32bit-integer:
	rm -rf sources/Slicot/64/with-32bit-integer

clean-slicot-64-with-64bit-integer:
	rm -rf sources/Slicot/64/with-64bit-integer

clean-libslicot-32-without-underscore:
	rm -rf lib32/Slicot/without-underscore

clean-libslicot-32-with-underscore:
	rm -rf lib32/Slicot/with-underscore

clean-libslicot-64:
	rm -rf lib64/Slicot

#
# Zlib
#

sources/Zlib/32: zlib-${ZLIB_VERSION}.tar.xz
	mkdir -p tmp-zlib-32
	tar -xJf zlib-${ZLIB_VERSION}.tar.xz --directory tmp-zlib-32
	mkdir -p sources/Zlib/32
	mv tmp-zlib-32/zlib-${ZLIB_VERSION}/* sources/Zlib/32
	rm -rf tmp-zlib-32

sources/Zlib/64: zlib-${ZLIB_VERSION}.tar.xz
	mkdir -p tmp-zlib-64
	tar -xJf zlib-${ZLIB_VERSION}.tar.xz --directory tmp-zlib-64
	mkdir -p sources/Zlib/64
	mv tmp-zlib-64/zlib-${ZLIB_VERSION}/* sources/Zlib/64
	rm -rf tmp-zlib-64

zlib-${ZLIB_VERSION}.tar.xz: versions/zlib.version
	wget https://sourceforge.net/projects/libpng/files/zlib/${ZLIB_VERSION}/zlib-${ZLIB_VERSION}.tar.xz/download -O zlib-${ZLIB_VERSION}.tar.xz
	touch zlib-${ZLIB_VERSION}.tar.xz

lib32/Zlib/lib/libz.a: sources/Zlib/32
	cd sources/Zlib/32 && CROSS_PREFIX=i686-w64-mingw32- ./configure --static --prefix=${ROOT_PATH}/lib32/Zlib && make install

lib64/Zlib/lib/libz.a: sources/Zlib/64
	cd sources/Zlib/64 && CROSS_PREFIX=x86_64-w64-mingw32- ./configure --static --prefix=${ROOT_PATH}/lib64/Zlib && make install

build-zlib: lib32/Zlib/lib/libz.a lib64/Zlib/lib/libz.a

clean-zlib: clean-zlib-32 clean-zlib-64

clean-libzlib: clean-libzlib-32 clean-libzlib-64

clean-zlib-tar:
	rm -f zlib-${ZLIB_VERSION}.tar.xz

cleanall-zlib: clean-zlib clean-zlib-tar

clean-libzlib-32:
	rm -rf lib32/Zlib

clean-libzlib-64:
	rm -rf lib64/Zlib

clean-zlib-32:
	rm -rf sources/Zlib/32

clean-zlib-64:
	rm -rf sources/Zlib/64
