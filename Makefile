include versions/openblas.version
include versions/lapack.version
include versions/gsl.version
include versions/boost.version
include versions/matio.version
include versions/zlib.version
include versions/octave.version

ROOT_PATH = $(realpath .)

.PHONY: clean-openblas-src clean-openblas-tar clean-openblas-all clean-libopenblas \
	clean-boost-src clean-boost-tar clean-boost-all clean-libboost \
	clean-gsl-src clean-gsl-tar clean-gsl-all clean-libgsl\
	clean-slicot-src clean-slicot-tar clean-slicot-all clean-libslicot \
	clean-matio-src clean-matio-tar clean-matio-all clean-libmatio\
	clean-zlib-src clean-zlib-tar clean-zlib-src clean-libzlib\
	clean-lapack-src clean-lapack-tar clean-lapack-all clean-liblapack\
	clean-dll clean-dll32 clean-dll64 \
	download build clean-src clean-all clean-lib clean-tar \
	dll dll32 dll64 \
	octave-libs \
	install-matlab-files \
	install

all: build octave-libs install-matlab-files dll

build: build-openblas build-lapack build-slicot build-matio build-boost build-gsl

download: sources/OpenBLAS/32 sources/OpenBLAS/64 \
	sources/Boost \
	sources/Gsl \
	sources/Lapack \
	sources/matIO \
	sources/Slicot \
	sources/Zlib \
	octave-libs \
	install-matlab-files

clean-lib: clean-libopenblas clean-liblapack clean-libgsl clean-libzlib clean-libmatio clean-libslicot clean-libboost clean-matlab clean-octave

clean-src: clean-openblas-src clean-boost-src clean-gsl-src clean-lapack-src clean-matio-src clean-slicot-src clean-zlib-src

clean-tar: clean-openblas-tar clean-boost-tar clean-gsl-tar clean-lapack-tar clean-matio-tar clean-slicot-tar clean-zlib-tar

clean-all: clean-lib clean-src clean-tar

install:
	./install-packages.sh

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

build-openblas: lib32/OpenBLAS/libopenblas.a lib64/OpenBLAS/libopenblas.a

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

clean-openblas-src: clean-openblas-32-src clean-openblas-64-src

clean-openblas-tar:
	rm -f v${OPENBLAS_VERSION}.tar.gz

clean-openblas-all: clean-openblas-src clean-openblas-tar clean-libopenblas

clean-openblas-32-src:
	rm -rf sources/OpenBLAS/32

clean-openblas-64-src:
	rm -rf sources/OpenBLAS/64

clean-libopenblas: clean-libopenblas-32 clean-libopenblas-64

clean-libopenblas-32:
	rm -rf lib32/OpenBLAS

clean-libopenblas-64:
	rm -rf lib64/OpenBLAS

#
# Boost library
#

sources/Boost/32: boost_${BOOST_VERSION}.tar.bz2
	mkdir -p tmp-boost-32
	tar xf boost_${BOOST_VERSION}.tar.bz2 --directory tmp-boost-32
	mkdir -p sources/Boost/32
	mv tmp-boost-32/boost_${BOOST_VERSION}/* sources/Boost/32/
	rm -r tmp-boost-32

sources/Boost/64: boost_${BOOST_VERSION}.tar.bz2
	mkdir -p tmp-boost-64
	tar xf boost_${BOOST_VERSION}.tar.bz2 --directory tmp-boost-64
	mkdir -p sources/Boost/64
	mv tmp-boost-64/boost_${BOOST_VERSION}/* sources/Boost/64/
	rm -r tmp-boost-64

boost_${BOOST_VERSION}.tar.bz2: versions/boost.version
	rm -f boost_${BOOST_VERSION}.tar.bz2
	wget https://sourceforge.net/projects/boost/files/boost/`echo "${BOOST_VERSION}" | sed -e 's/_/./g'`/boost_${BOOST_VERSION}.tar.bz2/download -O boost_${BOOST_VERSION}.tar.bz2
	touch boost_${BOOST_VERSION}.tar.bz2
	rm -rf ${ROOT_PATH}/sources/Boost
	rm -rf ${ROOT_PATH}/lib32/Boost
	rm -rf ${ROOT_PATH}/lib64/Boost

build-boost: lib32/Boost lib64/Boost

lib32/Boost: sources/Boost/32
	echo "using gcc : mingw : i686-w64-mingw32-g++ ;" > sources/Boost/32/user-config.jam
	cd sources/Boost/32 && ./bootstrap.sh --with-libraries=system,filesystem --prefix=${ROOT_PATH}/lib32/Boost && ./b2 -a -q --user-config=user-config.jam toolset=gcc-mingw target-os=windows address-model=32 variant=release install

lib64/Boost: sources/Boost/64
	echo "using gcc : mingw : x86_64-w64-mingw32-g++ ;" > sources/Boost/64/user-config.jam
	cd sources/Boost/64 && ./bootstrap.sh --with-libraries=system,filesystem --prefix=${ROOT_PATH}/lib64/Boost && ./b2 -a -q --user-config=user-config.jam toolset=gcc-mingw target-os=windows address-model=64 variant=release install

clean-boost-src: clean-boost-32-src clean-boost-64-src

clean-boost-32-src:
	rm -fr sources/Boost/32

clean-boost-64-src:
	rm -fr sources/Boost/64

clean-libboost: clean-libboost-32 clean-libboost-64

clean-libboost-32:
	rm -fr lib32/Boost

clean-libboost-64:
	rm -fr lib64/Boost

clean-boost-tar:
	rm -f boost_${BOOST_VERSION}.tar.bz2

clean-boost-all: clean-boost-src clean-boost-tar clean-libboost

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

sources/Gsl: sources/Gsl/32 sources/Gsl/64

gsl-${GSL_VERSION}.tar.gz: versions/gsl.version
	wget https://ftpmirror.gnu.org/gnu/gsl/gsl-${GSL_VERSION}.tar.gz
	rm -rf ${ROOT_PATH}/sources/Gsl/32
	rm -rf ${ROOT_PATH}/sources/Gsl/64
	touch gsl-${GSL_VERSION}.tar.gz

lib32/Gsl/lib/libgsl.a: sources/Gsl/32
	cd sources/Gsl/32 && ./configure --host=i686-w64-mingw32 --prefix=${ROOT_PATH}/lib32/Gsl --disable-shared --enable-static && make && make install

lib64/Gsl/lib/libgsl.a: sources/Gsl/64
	cd sources/Gsl/64 && ./configure --host=x86_64-w64-mingw32 --prefix=${ROOT_PATH}/lib64/Gsl --disable-shared --enable-static && make && make install

build-gsl: lib32/Gsl/lib/libgsl.a lib64/Gsl/lib/libgsl.a

clean-gsl-src: clean-gsl-32-src clean-gsl-64-src

clean-libgsl: clean-libgsl-32 clean-libgsl-64

clean-gsl-tar:
	rm -f gsl-${GSL_VERSION}.tar.gz

clean-gsl-all: clean-gsl-src clean-gsl-tar clean-libgsl

clean-gsl-32-src:
	rm -rf sources/Gsl/32

clean-gsl-64-src:
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

sources/Lapack: sources/Lapack/32 sources/Lapack/64

lapack-${LAPACK_VERSION}.tgz: versions/lapack.version
	wget http://www.netlib.org/lapack/lapack-${LAPACK_VERSION}.tgz
	touch lapack-${LAPACK_VERSION}.tgz
	rm -rf ${ROOT_PATH}/sources/Lapack
	rm -rf ${ROOT_PATH}/lib32/Lapack
	rm -rf ${ROOT_PATH}/lib64/Lapack

lib32/Lapack/liblapack.a: sources/Lapack/32
	cp sources/Lapack/32/make.inc.example sources/Lapack/32/make.inc
	patch sources/Lapack/32/make.inc < patch/lapack-w32.patch
	make -C sources/Lapack/32/SRC
	i686-w64-mingw32-strip --strip-debug sources/Lapack/32/liblapack.a
	mkdir -p lib32/Lapack
	mv sources/Lapack/32/liblapack.a lib32/Lapack/liblapack.a
	touch lib32/Lapack/liblapack.a

lib64/Lapack/liblapack.a: sources/Lapack/64
	cp sources/Lapack/64/make.inc.example sources/Lapack/64/make.inc
	patch sources/Lapack/64/make.inc < patch/lapack-w64.patch
	make -C sources/Lapack/64/SRC
	x86_64-w64-mingw32-strip --strip-debug sources/Lapack/64/liblapack.a
	mkdir -p lib64/Lapack
	mv sources/Lapack/64/liblapack.a lib64/Lapack/liblapack.a
	touch lib64/Lapack/liblapack.a

build-lapack: lib32/Lapack/liblapack.a lib64/Lapack/liblapack.a

clean-lapack-src: clean-lapack-32-src clean-lapack-64-src

clean-liblapack: clean-liblapack-32 clean-liblapack-64

clean-lapack-tar:
	rm -f lapack-${LAPACK_VERSION}.tgz

clean-lapack-all: clean-lapack-src clean-lapack-tar clean-liblapack

clean-liblapack-32:
	rm -rf lib32/Lapack

clean-liblapack-64:
	rm -rf lib64/Lapack

clean-lapack-32-src:
	rm -rf sources/Lapack/32

clean-lapack-64-src:
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

sources/matIO: sources/matIO/32 sources/matIO/64

matio-${MATIO_VERSION}.tar.gz: versions/matio.version
	wget https://sourceforge.net/projects/matio/files/matio/${MATIO_VERSION}/matio-${MATIO_VERSION}.tar.gz/download -O matio-${MATIO_VERSION}.tar.gz
	touch matio-${MATIO_VERSION}.tar.gz
	rm -rf ${ROOT_PATH}/lib32/matIO
	rm -rf ${ROOT_PATH}/lib64/matIO
	rm -rf ${ROOT_PATH}/sources/matIO

# The "ac_cv_va_copy=C99" argument is a workaround for https://github.com/tbeu/matio/issues/78

lib32/matIO/lib/libmatio.a: sources/matIO/32 lib32/Zlib/lib/libz.a
	cd sources/matIO/32 && ./configure --host=i686-w64-mingw32 --disable-shared --with-zlib=${ROOT_PATH}/lib32/Zlib --prefix=${ROOT_PATH}/lib32/matIO ac_cv_va_copy=C99 && make install
	ln -s ${ROOT_PATH}/lib32/Zlib/include/zconf.h ${ROOT_PATH}/lib32/matIO/include/zconf.h
	ln -s ${ROOT_PATH}/lib32/Zlib/include/zlib.h ${ROOT_PATH}/lib32/matIO/include/zlib.h
	ln -s ${ROOT_PATH}/lib32/Zlib/lib/libz.a ${ROOT_PATH}/lib32/matIO/lib/libz.a

lib64/matIO/lib/libmatio.a: sources/matIO/64 lib64/Zlib/lib/libz.a
	cd sources/matIO/64 && ./configure --host=x86_64-w64-mingw32 --disable-shared --with-zlib=${ROOT_PATH}/lib64/Zlib --prefix=${ROOT_PATH}/lib64/matIO ac_cv_va_copy=C99 && make install
	ln -s ${ROOT_PATH}/lib64/Zlib/include/zconf.h ${ROOT_PATH}/lib64/matIO/include/zconf.h
	ln -s ${ROOT_PATH}/lib64/Zlib/include/zlib.h ${ROOT_PATH}/lib64/matIO/include/zlib.h
	ln -s ${ROOT_PATH}/lib64/Zlib/lib/libz.a ${ROOT_PATH}/lib64/matIO/lib/libz.a

build-matio: build-zlib lib32/matIO/lib/libmatio.a lib64/matIO/lib/libmatio.a

clean-matio-src: clean-matio-32-src clean-matio-64-src

clean-libmatio: clean-libmatio-32 clean-libmatio-64

clean-matio-tar:
	rm -f matio-${MATIO_VERSION}.tar.gz

clean-matio-all: clean-matio-src clean-matio-tar clean-libmatio

clean-matio-32-src:
	rm -rf sources/matIO/32

clean-matio-64-src:
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

sources/Slicot/64/with-32bit-integer-and-underscore: slicot45.tar.gz
	mkdir -p tmp-slicot-64-with-32bit-integer-and-underscore
	tar -zxf slicot45.tar.gz --directory tmp-slicot-64-with-32bit-integer-and-underscore
	mkdir -p sources/Slicot/64/with-32bit-integer-and-underscore
	mv tmp-slicot-64-with-32bit-integer-and-underscore/slicot/* sources/Slicot/64/with-32bit-integer-and-underscore
	rm -r tmp-slicot-64-with-32bit-integer-and-underscore

sources/Slicot/64/with-64bit-integer-and-underscore: slicot45.tar.gz
	mkdir -p tmp-slicot-64-with-64bit-integer-and-underscore
	tar -zxf slicot45.tar.gz --directory tmp-slicot-64-with-64bit-integer-and-underscore
	mkdir -p sources/Slicot/64/with-64bit-integer-and-underscore
	mv tmp-slicot-64-with-64bit-integer-and-underscore/slicot/* sources/Slicot/64/with-64bit-integer-and-underscore
	rm -r tmp-slicot-64-with-64bit-integer-and-underscore

sources/Slicot: sources/Slicot/32/without-underscore \
	sources/Slicot/32/with-underscore \
	sources/Slicot/64/with-32bit-integer \
	sources/Slicot/64/with-64bit-integer \
	sources/Slicot/64/with-32bit-integer-and-underscore \
	sources/Slicot/64/with-64bit-integer-and-underscore

slicot45.tar.gz:
	wget --user-agent="User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:10.0) Gecko/20100101 Firefox/10.0" -c http://slicot.org/objects/software/shared/slicot45.tar.gz
	touch slicot45.tar.gz

lib32/Slicot/without-underscore/lib/libslicot_pic.a: sources/Slicot/32/without-underscore
	patch sources/Slicot/32/without-underscore/make.inc < patch/slicot-32-without-underscore.patch
	make -C sources/Slicot/32/without-underscore lib
	i686-w64-mingw32-strip --strip-debug sources/Slicot//32/without-underscore/libslicot_pic.a
	mkdir -p lib32/Slicot/without-underscore/lib
	mv sources/Slicot/32/without-underscore/libslicot_pic.a lib32/Slicot/without-underscore/lib/libslicot_pic.a
	touch lib32/Slicot/without-underscore/lib/libslicot_pic.a

lib32/Slicot/with-underscore/lib/libslicot_pic.a: sources/Slicot/32/with-underscore
	patch sources/Slicot/32/with-underscore/make.inc < patch/slicot-32-with-underscore.patch
	make -C sources/Slicot/32/with-underscore lib
	i686-w64-mingw32-strip --strip-debug sources/Slicot/32/with-underscore/libslicot_pic.a
	mkdir -p lib32/Slicot/with-underscore/lib
	mv sources/Slicot/32/with-underscore/libslicot_pic.a lib32/Slicot/with-underscore/lib/libslicot_pic.a
	touch lib32/Slicot/with-underscore/lib/libslicot_pic.a

lib64/Slicot/without-underscore/lib/libslicot_pic.a: sources/Slicot/64/with-32bit-integer
	patch sources/Slicot/64/with-32bit-integer/make.inc < patch/slicot-64-with-32bit-integer.patch
	make -C sources/Slicot/64/with-32bit-integer lib
	x86_64-w64-mingw32-strip --strip-debug sources/Slicot/64/with-32bit-integer/libslicot_pic.a
	mkdir -p lib64/Slicot/without-underscore/lib
	mv sources/Slicot/64/with-32bit-integer/libslicot_pic.a lib64/Slicot/without-underscore/lib/libslicot_pic.a
	touch lib64/Slicot/without-underscore/lib/libslicot_pic.a

lib64/Slicot/without-underscore/lib/libslicot64_pic.a: sources/Slicot/64/with-64bit-integer
	patch sources/Slicot/64/with-64bit-integer/make.inc < patch/slicot-64-with-64bit-integer.patch
	make -C sources/Slicot/64/with-64bit-integer lib
	x86_64-w64-mingw32-strip --strip-debug sources/Slicot/64/with-64bit-integer/libslicot64_pic.a
	mkdir -p lib64/Slicot/without-underscore/lib
	mv sources/Slicot/64/with-64bit-integer/libslicot64_pic.a lib64/Slicot/without-underscore/lib/libslicot64_pic.a
	touch lib64/Slicot/without-underscore/lib/libslicot64_pic.a

lib64/Slicot/with-underscore/lib/libslicot_pic.a: sources/Slicot/64/with-32bit-integer-and-underscore
	patch sources/Slicot/64/with-32bit-integer-and-underscore/make.inc < patch/slicot-64-with-32bit-integer-and-underscore.patch
	make -C sources/Slicot/64/with-32bit-integer-and-underscore lib
	x86_64-w64-mingw32-strip --strip-debug sources/Slicot/64/with-32bit-integer-and-underscore/libslicot_pic.a
	mkdir -p lib64/Slicot/with-underscore/lib
	mv sources/Slicot/64/with-32bit-integer-and-underscore/libslicot_pic.a lib64/Slicot/with-underscore/lib/libslicot_pic.a
	touch lib64/Slicot/with-underscore/lib/libslicot_pic.a

lib64/Slicot/with-underscore/lib/libslicot64_pic.a: sources/Slicot/64/with-64bit-integer-and-underscore
	patch sources/Slicot/64/with-64bit-integer-and-underscore/make.inc < patch/slicot-64-with-64bit-integer-and-underscore.patch
	make -C sources/Slicot/64/with-64bit-integer-and-underscore lib
	x86_64-w64-mingw32-strip --strip-debug sources/Slicot/64/with-64bit-integer-and-underscore/libslicot64_pic.a
	mkdir -p lib64/Slicot/with-underscore/lib
	mv sources/Slicot/64/with-64bit-integer-and-underscore/libslicot64_pic.a lib64/Slicot/with-underscore/lib/libslicot64_pic.a
	touch lib64/Slicot/with-underscore/lib/libslicot64_pic.a

build-slicot: lib32/Slicot/without-underscore/lib/libslicot_pic.a lib32/Slicot/with-underscore/lib/libslicot_pic.a \
	lib64/Slicot/without-underscore/lib/libslicot_pic.a lib64/Slicot/without-underscore/lib/libslicot64_pic.a \
	lib64/Slicot/with-underscore/lib/libslicot_pic.a lib64/Slicot/with-underscore/lib/libslicot64_pic.a

clean-slicot-src: clean-slicot-32-with-underscore-src clean-slicot-32-without-underscore-src \
	clean-slicot-64-with-32bit-integer-src clean-slicot-64-with-64bit-integer-src \
	clean-slicot-64-with-32bit-integer-and-underscore-src clean-slicot-64-with-64bit-integer-and-underscore-src

clean-libslicot: clean-libslicot-32 clean-libslicot-64

clean-slicot-tar:
	rm -f slicot45.tar.gz

clean-slicot-all: clean-slicot-src clean-slicot-tar clean-libslicot

clean-slicot-32-with-underscore-src:
	rm -rf sources/Slicot/32/with-underscore

clean-slicot-32-without-underscore-src:
	rm -rf sources/Slicot/32/without-underscore

clean-slicot-64-with-32bit-integer-src:
	rm -rf sources/Slicot/64/with-32bit-integer

clean-slicot-64-with-64bit-integer-src:
	rm -rf sources/Slicot/64/with-64bit-integer

clean-slicot-64-with-32bit-integer-and-underscore-src:
	rm -rf sources/Slicot/64/with-32bit-integer-and-underscore

clean-slicot-64-with-64bit-integer-and-underscore-src:
	rm -rf sources/Slicot/64/with-64bit-integer-and-underscore

clean-libslicot-32-without-underscore:
	rm -rf lib32/Slicot/without-underscore

clean-libslicot-32-with-underscore:
	rm -rf lib32/Slicot/with-underscore

clean-libslicot-64-with-underscore:
	rm -rf lib64/Slicot/with-underscore

clean-libslicot-64-without-underscore:
	rm -rf lib64/Slicot/without-underscore

clean-libslicot-64:
	rm -rf lib64/Slicot

clean-libslicot-32:
	rm -rf lib32/Slicot

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

sources/Zlib: sources/Zlib/64 sources/Zlib/32

zlib-${ZLIB_VERSION}.tar.xz: versions/zlib.version
	wget https://sourceforge.net/projects/libpng/files/zlib/${ZLIB_VERSION}/zlib-${ZLIB_VERSION}.tar.xz/download -O zlib-${ZLIB_VERSION}.tar.xz
	touch zlib-${ZLIB_VERSION}.tar.xz
	rm -rf sources/Zlib/32
	rm -rf sources/Zlib/64
	rm -rf ${ROOT_PATH}/lib32/matIO/include/zconf.h
	rm -rf ${ROOT_PATH}/lib32/matIO/include/zlib.h
	rm -rf ${ROOT_PATH}/lib32/matIO/lib/libz.a
	rm -rf ${ROOT_PATH}/lib64/matIO/include/zconf.h
	rm -rf ${ROOT_PATH}/lib64/matIO/include/zlib.h
	rm -rf ${ROOT_PATH}/lib64/matIO/lib/libz.a

lib32/Zlib/lib/libz.a: sources/Zlib/32
	cd sources/Zlib/32 && CC=i686-w64-mingw32-gcc && ./configure --static --prefix=${ROOT_PATH}/lib32/Zlib && make install

lib64/Zlib/lib/libz.a: sources/Zlib/64
	cd sources/Zlib/64 && CC=x86_64-w64-mingw32-gcc && ./configure --static --prefix=${ROOT_PATH}/lib64/Zlib && make install

build-zlib: lib32/Zlib/lib/libz.a lib64/Zlib/lib/libz.a

clean-zlib-src: clean-zlib-32-src clean-zlib-64-src

clean-libzlib: clean-libzlib-32 clean-libzlib-64

clean-zlib-tar:
	rm -f zlib-${ZLIB_VERSION}.tar.xz

clean-zlib-all: clean-zlib-src clean-zlib-tar clean-libzlib

clean-libzlib-32:
	rm -rf lib32/Zlib

clean-libzlib-64:
	rm -rf lib64/Zlib

clean-zlib-32-src:
	rm -rf sources/Zlib/32

clean-zlib-64-src:
	rm -rf sources/Zlib/64

#
# Octave
#

octave-${OCTAVE_VERSION}-w32${OCTAVE_W32_BUILD}.7z: versions/octave.version
	@echo "Download $@ from https://ftpmirror.gnu.org/gnu/octave/windows ..."
	@wget -q -o /dev/null https://ftpmirror.gnu.org/gnu/octave/windows/$@
	@echo "Download $@.sig from https://ftpmirror.gnu.org/gnu/octave/windows ..."
	@wget -q -o /dev/null https://ftpmirror.gnu.org/gnu/octave/windows/$@.sig
	gpg --verify $@.sig $@
	@touch $@ $@.sig

octave-${OCTAVE_VERSION}-w64${OCTAVE_W64_BUILD}.7z: versions/octave.version
	@echo "Download $@ from https://ftpmirror.gnu.org/gnu/octave/windows ..."
	@wget -q -o /dev/null https://ftpmirror.gnu.org/gnu/octave/windows/$@
	@echo "Download $@.sig from https://ftpmirror.gnu.org/gnu/octave/windows ..."
	@wget -q -o /dev/null https://ftpmirror.gnu.org/gnu/octave/windows/$@.sig
	gpg --verify $@.sig $@
	@touch $@ $@.sig

lib32/octave/bin/octave.exe: octave-${OCTAVE_VERSION}-w32${OCTAVE_W32_BUILD}.7z
	@echo "Unarchive Octave 32bits..."
	@7z x -olib32 $< > /dev/null
	@mv lib32/octave-${OCTAVE_VERSION}-w32 lib32/octave
	@touch lib32/octave/bin/octave.exe

lib64/octave/bin/octave.exe: octave-${OCTAVE_VERSION}-w64${OCTAVE_W64_BUILD}.7z
	@echo "Unarchive Octave 64bits..."
	@7z x -olib64 $< > /dev/null
	@mv lib64/octave-${OCTAVE_VERSION}-w64 lib64/octave
	@touch lib64/octave/bin/octave.exe

octave-libs: lib32/octave/bin/octave.exe lib64/octave/bin/octave.exe

clean-octave-libs:
	rm -rf lib32/octave
	rm -rf lib64/octave

clean-octave: clean-octave-libs
	rm -f octave-${OCTAVE_VERSION}-w64${OCTAVE_W64_BUILD}.7z
	rm -f octave-${OCTAVE_VERSION}-w64${OCTAVE_W64_BUILD}.7z.sig
	rm -f octave-${OCTAVE_VERSION}-w32${OCTAVE_W32_BUILD}.7z
	rm -f octave-${OCTAVE_VERSION}-w32${OCTAVE_W32_BUILD}.7z.sig

#
# Matlab
#

matlab32.tar.xz:
	@wget -q -o /dev/null http://www.dynare.org/dynare-build/matlab32.tar.xz.gpg -O matlab32.tar.xz.gpg
	@gpg --output matlab32.tar.xz --decrypt matlab32.tar.xz.gpg
	@rm matlab32.tar.xz.gpg
	@touch matlab32.tar.xz

matlab64.tar.xz:
	@wget  -q -o /dev/null http://www.dynare.org/dynare-build/matlab64.tar.xz.gpg -O matlab64.tar.xz.gpg
	@gpg --output matlab64.tar.xz --decrypt matlab64.tar.xz.gpg
	@rm matlab64.tar.xz.gpg
	@touch matlab64.tar.xz

lib32/matlab/R2007a/bin/matlab.bat: matlab32.tar.xz
	@tar xJf matlab32.tar.xz -C lib32
	@mv lib32/32 lib32/matlab
	@touch lib32/matlab/R2007a/bin/matlab.bat

lib64/matlab/R2007a/bin/win64/matlab.exe: matlab64.tar.xz
	@tar xJf matlab64.tar.xz -C lib64
	@mv lib64/64 lib64/matlab
	@touch lib64/matlab/R2007a/bin/win64/matlab.exe

install-matlab-files: lib32/matlab/R2007a/bin/matlab.bat lib64/matlab/R2007a/bin/win64/matlab.exe


clean-matlab:
	rm -f matlab32.tar.xz
	rm -f matlab64.tar.xz
	rm -rf lib32/matlab
	rm -rf lib64/matlab

#
# Dlls
#

lib32/libquadmath-0.dll:
	wget -q -o /dev/null http://www.dynare.org/dynare-build/dll32/libquadmath-0.dll -O lib32/libquadmath-0.dll

lib32/libgcc_s_sjlj-1.dll:
	wget -q -o /dev/null http://www.dynare.org/dynare-build/dll32/libgcc_s_sjlj-1.dll -O lib32/libgcc_s_sjlj-1.dll

lib64/libquadmath-0.dll:
	wget -q -o /dev/null http://www.dynare.org/dynare-build/dll64/libquadmath-0.dll -O lib64/libquadmath-0.dll

lib64/libgcc_s_seh-1.dll:
	wget -q -o /dev/null http://www.dynare.org/dynare-build/dll64/libgcc_s_seh-1.dll -O lib64/libgcc_s_seh-1.dll

dll32: lib32/libquadmath-0.dll lib32/libgcc_s_sjlj-1.dll

dll64: lib64/libquadmath-0.dll lib64/libgcc_s_seh-1.dll

dll: dll32 dll64

clean-dll32:
	rm -f lib32/libquadmath-0.dll lib32/libgcc_s_sjlj-1.dll

clean-dll64:
	rm -f lib64/libquadmath-0.dll lib64/libgcc_s_seh-1.dll

clean-dll: clean-dll32 clean-dll64
