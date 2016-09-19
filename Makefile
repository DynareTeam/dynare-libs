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

clean-boost:
	rm -fr sources/Boost

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

sources/Lapack: lapack-${LAPACK_VERSION}.tgz
	rm -rf sources/Lapack
	tar -zxf lapack-${LAPACK_VERSION}.tgz
	mkdir -p sources/Lapack
	mv lapack-${LAPACK_VERSION}/* sources/Lapack
	rm -r lapack-${LAPACK_VERSION}

lapack-${LAPACK_VERSION}.tgz: versions/lapack.version
	rm -f lapack-${LAPACK_VERSION}.tgz
	wget http://www.netlib.org/lapack/lapack-${LAPACK_VERSION}.tgz
	touch lapack-${LAPACK_VERSION}.tgz

clean-lapack:
	rm -rf sources/Lapack

clean-lapack-tar:
	rm -f lapack-${LAPACK_VERSION}.tgz

cleanall-lapack: clean-lapack clean-lapack-tar

lib32/Lapack/liblapack.a: sources/Lapack
	cp sources/Lapack/make.inc.example sources/Lapack/make.inc
	patch sources/Lapack/make.inc < patch/lapack-w32.patch
	make -C sources/Lapack/SRC
	i686-w64-mingw32-strip --strip-debug sources/Lapack/liblapack.a
	mkdir -p lib32/Lapack
	mv sources/Lapack/liblapack.a lib32/Lapack/liblapack.a

lib64/Lapack/liblapack.a: sources/Lapack
	cp sources/Lapack/make.inc.example sources/Lapack/make.inc
	patch sources/Lapack/make.inc < patch/lapack-w64.patch
	make -C sources/Lapack/SRC
	x86_64-w64-mingw32-strip --strip-debug sources/Lapack/liblapack.a
	mkdir -p lib64/Lapack
	mv sources/Lapack/liblapack.a lib64/Lapack/liblapack.a

clean-lapack-32:
	rm -rf lib32/Lapack

clean-lapack-64:
	rm -rf lib64/Lapack

#
# matIO
#

sources/matIO: matio-${MATIO_VERSION}.tar.gz
	rm -rf sources/matIO
	tar -zxf matio-${MATIO_VERSION}.tar.gz
	mkdir -p sources/matIO
	mv matio-${MATIO_VERSION}/* sources/matIO
	rm -r matio-${MATIO_VERSION}

matio-${MATIO_VERSION}.tar.gz: versions/matio.version
	rm -f matio-${MATIO_VERSION}.tar.gz
	wget https://sourceforge.net/projects/matio/files/matio/${MATIO_VERSION}/matio-${MATIO_VERSION}.tar.gz/download -O matio-${MATIO_VERSION}.tar.gz
	touch matio-${MATIO_VERSION}.tar.gz

clean-matio:
	rm -r sources/matIO

clean-matio-tar:
	rm -f matio-${MATIO_VERSION}.tar.gz

cleanall-matio: clean-matio clean-matio-tar

lib32/matIO/lib/libmatio.a: sources/matIO lib32/Zlib/lib/libz.a
	cd sources/matIO && CROSS_PREFIX=i686-w64-mingw32- ./configure --disable-shared --with-zlib=${ROOT_PATH}/lib32/Zlib --prefix=${ROOT_PATH}/lib32/matIO && make install

lib64/matIO/lib/libmatio.a: sources/matIO lib64/Zlib/lib/libz.a
	cd sources/matIO && CROSS_PREFIX=x86_64-w64-mingw32- ./configure --disable-shared --with-zlib=${ROOT_PATH}/lib64/Zlib --prefix=${ROOT_PATH}/lib64/matIO && make install

clean-matio-32:
	rm -rf lib32/matIO

clean-matio-64:
	rm -rf lib64/matIO

#
# Slicot
#

sources/Slicot: slicot45.tar.gz
	rm -rf sources/Slicot
	tar -zxf slicot45.tar.gz
	mkdir -p sources/Slicot
	mv slicot/* sources/Slicot
	rm -r slicot

slicot45.tar.gz:
	rm -f slicot45.tar.gz
	wget --user-agent="User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:10.0) Gecko/20100101 Firefox/10.0" -c http://slicot.org/objects/software/shared/slicot45.tar.gz
	touch slicot45.tar.gz

clean-slicot:
	rm -rf sources/Slicot

clean-slicot-tar:
	rm -f slicot45.tar.gz

cleanall-slicot: clean-slicot clean-slicot-tar

lib32/Slicot/without-underscore/libslicot_pic.a:
	patch sources/Slicot/make.inc < patch/slicot-32-without-underscore.patch
	make -C sources/Slicot lib
	i686-w64-mingw32-strip --strip-debug sources/Slicot/libslicot_pic.a
	mkdir -p lib32/Slicot/without-underscore
	mv sources/Slicot/libslicot_pic.a lib32/Slicot/without-underscore/libslicot_pic.a

lib32/Slicot/with-underscore/libslicot_pic.a:
	patch sources/Slicot/make.inc < patch/slicot-32-with-underscore.patch
	make -C sources/Slicot lib
	i686-w64-mingw32-strip --strip-debug sources/Slicot/libslicot_pic.a
	mkdir -p lib32/Slicot/with-underscore
	mv sources/Slicot/libslicot_pic.a lib32/Slicot/with-underscore/libslicot_pic.a

lib64/Slicot/libslicot_pic.a:
	patch sources/Slicot/make.inc < patch/slicot-64-with-32bit-integer.patch
	make -C sources/Slicot lib
	x86_64-w64-mingw32-strip --strip-debug sources/Slicot/libslicot_pic.a
	mkdir -p lib64/Slicot
	mv sources/Slicot/libslicot_pic.a lib64/Slicot/libslicot_pic.a

lib64/Slicot/libslicot64_pic.a:
	patch sources/Slicot/make.inc < patch/slicot-64-with-64bit-integer.patch
	make -C sources/Slicot lib
	x86_64-w64-mingw32-strip --strip-debug sources/Slicot/libslicot64_pic.a
	mkdir -p lib64/Slicot
	mv sources/Slicot/libslicot64_pic.a lib64/Slicot/libslicot64_pic.a

clean-slicot-32:
	rm -rf lib32/Slicot

clean-slicot-64:
	rm -rf lib64/Slicot

#
# Zlib
#

sources/Zlib: zlib-${ZLIB_VERSION}.tar.xz
	rm -rf sources/Zlib
	tar -xJf zlib-${ZLIB_VERSION}.tar.xz
	mkdir -p sources/Zlib
	mv zlib-${ZLIB_VERSION}/* sources/Zlib
	rm -r zlib-${ZLIB_VERSION}

zlib-${ZLIB_VERSION}.tar.xz: versions/zlib.version
	rm -f zlib-${ZLIB_VERSION}.tar.xz
	wget https://sourceforge.net/projects/libpng/files/zlib/${ZLIB_VERSION}/zlib-${ZLIB_VERSION}.tar.xz/download -O zlib-${ZLIB_VERSION}.tar.xz
	touch zlib-${ZLIB_VERSION}.tar.xz

clean-zlib:
	rm -r sources/Zlib

clean-zlib-tar:
	rm -f zlib-${ZLIB_VERSION}.tar.xz

cleanall-zlib: clean-zlib clean-zlib-tar

lib32/Zlib/lib/libz.a: sources/Zlib
	cd sources/Zlib && CROSS_PREFIX=i686-w64-mingw32- ./configure --static --prefix=${ROOT_PATH}/lib32/Zlib && make install

lib64/Zlib/lib/libz.a: sources/Zlib
	cd sources/Zlib && CROSS_PREFIX=x86_64-w64-mingw32- ./configure --static --prefix=${ROOT_PATH}/lib64/Zlib && make install

clean-zlib-32:
	rm -rf lib32/Zlib

clean-zlib-64:
	rm -rf lib64/Zlib
