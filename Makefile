include versions/openblas.version
include versions/lapack.version
include versions/gsl.version
include versions/boost.version
include versions/matio.version
include versions/zlib.version
include versions/octave.version

ROOT_PATH = $(realpath .)

.PHONY: clean-openblas-scr clean-openblas-tar clean-openblas-all clean-libopenblas \
	clean-boost-scr clean-boost-tar clean-boost-all clean-libboost \
	clean-gsl-scr clean-gsl-tar clean-gsl-all clean-libgsl\
	clean-slicot-scr clean-slicot-tar clean-slicot-all clean-libslicot \
	clean-matio-scr clean-matio-tar clean-matio-all clean-libmatio\
	clean-zlib-scr clean-zlib-tar clean-zlib-scr clean-libzlib\
	clean-lapack-scr clean-lapack-tar clean-lapack-all clean-liblapack\
	download build clean-src clean-all clean-lib clean-tar \
	octave-libs \
	install-matlab-files \
	install

all: build octave-libs install-matlab-files

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

build-boost: sources/Boost lib32/Boost/include lib64/Boost/include

lib32/Boost/include: sources/Boost
	mkdir -p lib32/Boost/include
	ln -s ${ROOT_PATH}/sources/Boost/boost ${ROOT_PATH}/lib32/Boost/include/boost
	touch lib32/Boost/include

lib64/Boost/include: sources/Boost
	mkdir -p lib64/Boost/include
	ln -s ${ROOT_PATH}/sources/Boost/boost ${ROOT_PATH}/lib64/Boost/include/boost
	touch lib64/Boost/include

clean-boost-src:
	rm -fr sources/Boost

clean-libboost:
	rm -fr lib32/Boost
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
	wget http://fr.mirror.babylon.network/gnu/gsl/gsl-${GSL_VERSION}.tar.gz
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

lib32/matIO/lib/libmatio.a: sources/matIO/32 lib32/Zlib/lib/libz.a
	cd sources/matIO/32 && ./configure --host=i686-w64-mingw32 --disable-shared --with-zlib=${ROOT_PATH}/lib32/Zlib --prefix=${ROOT_PATH}/lib32/matIO && make install
	ln -s ${ROOT_PATH}/lib32/Zlib/include/zconf.h ${ROOT_PATH}/lib32/matIO/include/zconf.h
	ln -s ${ROOT_PATH}/lib32/Zlib/include/zlib.h ${ROOT_PATH}/lib32/matIO/include/zlib.h
	ln -s ${ROOT_PATH}/lib32/Zlib/lib/libz.a ${ROOT_PATH}/lib32/matIO/lib/libz.a

lib64/matIO/lib/libmatio.a: sources/matIO/64 lib64/Zlib/lib/libz.a
	cd sources/matIO/64 && ./configure --host=x86_64-w64-mingw32 --disable-shared --with-zlib=${ROOT_PATH}/lib64/Zlib --prefix=${ROOT_PATH}/lib64/matIO && make install
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

sources/Slicot: sources/Slicot/32/without-underscore sources/Slicot/32/with-underscore sources/Slicot/64/with-32bit-integer sources/Slicot/64/with-64bit-integer

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

lib64/Slicot/lib/libslicot_pic.a: sources/Slicot/64/with-32bit-integer
	patch sources/Slicot/64/with-32bit-integer/make.inc < patch/slicot-64-with-32bit-integer.patch
	make -C sources/Slicot/64/with-32bit-integer lib
	x86_64-w64-mingw32-strip --strip-debug sources/Slicot/64/with-32bit-integer/libslicot_pic.a
	mkdir -p lib64/Slicot/lib
	mv sources/Slicot/64/with-32bit-integer/libslicot_pic.a lib64/Slicot/lib/libslicot_pic.a
	touch lib64/Slicot/lib/libslicot_pic.a

lib64/Slicot/lib/libslicot64_pic.a: sources/Slicot/64/with-64bit-integer
	patch sources/Slicot/64/with-64bit-integer/make.inc < patch/slicot-64-with-64bit-integer.patch
	make -C sources/Slicot/64/with-64bit-integer lib
	x86_64-w64-mingw32-strip --strip-debug sources/Slicot/64/with-64bit-integer/libslicot64_pic.a
	mkdir -p lib64/Slicot/lib
	mv sources/Slicot/64/with-64bit-integer/libslicot64_pic.a lib64/Slicot/lib/libslicot64_pic.a
	touch lib64/Slicot/lib/libslicot64_pic.a

build-slicot: lib32/Slicot/without-underscore/lib/libslicot_pic.a lib32/Slicot/with-underscore/lib/libslicot_pic.a lib64/Slicot/lib/libslicot_pic.a lib64/Slicot/lib/libslicot64_pic.a

clean-slicot-src: clean-slicot-32-with-underscore-src clean-slicot-32-without-underscore-src clean-slicot-64-with-32bit-integer-src clean-slicot-64-with-64bit-integer-src

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

clean-libslicot-32-without-underscore:
	rm -rf lib32/Slicot/without-underscore

clean-libslicot-32-with-underscore:
	rm -rf lib32/Slicot/with-underscore

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

octave-${OCTAVE_VERSION}-w32-installer.exe: versions/octave.version
	@echo "Download octave-${OCTAVE_VERSION}-w32-installer.exe from https://ftp.gnu.org/gnu/octave/windows ..."
	@wget -q -o /dev/null https://ftp.gnu.org/gnu/octave/windows/octave-${OCTAVE_VERSION}-w32-installer.exe -O octave-${OCTAVE_VERSION}-w32-installer.exe
	@echo "Download octave-${OCTAVE_VERSION}-w32-installer.exe.sig from https://ftp.gnu.org/gnu/octave/windows ..."
	@wget -q -o /dev/null https://ftp.gnu.org/gnu/octave/windows/octave-${OCTAVE_VERSION}-w32-installer.exe.sig -O octave-${OCTAVE_VERSION}-w32-installer.exe.sig
	gpg --verify octave-${OCTAVE_VERSION}-w32-installer.exe.sig octave-${OCTAVE_VERSION}-w32-installer.exe
	@touch octave-${OCTAVE_VERSION}-w32-installer.exe.sig
	@touch octave-${OCTAVE_VERSION}-w32-installer.exe

octave-${OCTAVE_VERSION}-w64-installer.exe: versions/octave.version
	@echo "Download octave-${OCTAVE_VERSION}-w64-installer.exe from https://ftp.gnu.org/gnu/octave/windows ..."
	@wget -q -o /dev/null https://ftp.gnu.org/gnu/octave/windows/octave-${OCTAVE_VERSION}-w64-installer.exe -O octave-${OCTAVE_VERSION}-w64-installer.exe
	@echo "Download octave-${OCTAVE_VERSION}-w64-installer.exe.sig from https://ftp.gnu.org/gnu/octave/windows ..."
	@wget -q -o /dev/null https://ftp.gnu.org/gnu/octave/windows/octave-${OCTAVE_VERSION}-w64-installer.exe.sig -O octave-${OCTAVE_VERSION}-w64-installer.exe.sig
	gpg --verify octave-${OCTAVE_VERSION}-w64-installer.exe.sig octave-${OCTAVE_VERSION}-w64-installer.exe
	@touch octave-${OCTAVE_VERSION}-w64-installer.exe.sig
	@touch octave-${OCTAVE_VERSION}-w64-installer.exe

lib32/octave/bin/octave.exe: octave-${OCTAVE_VERSION}-w32-installer.exe
	@echo "Unarchive Octave 32bits..."
	@mkdir -p lib32/octave
	@cp octave-${OCTAVE_VERSION}-w32-installer.exe lib32/octave
	@cd lib32/octave && 7z x octave-${OCTAVE_VERSION}-w32-installer.exe > /dev/null
	@rm lib32/octave/octave-${OCTAVE_VERSION}-w32-installer.exe
	@touch lib32/octave/bin/octave.exe

lib64/octave/bin/octave.exe: octave-${OCTAVE_VERSION}-w64-installer.exe
	@echo "Unarchive Octave 64bits..."
	@mkdir -p lib64/octave
	@cp octave-${OCTAVE_VERSION}-w64-installer.exe lib64/octave
	@cd lib64/octave && 7z x octave-${OCTAVE_VERSION}-w64-installer.exe > /dev/null
	@rm lib64/octave/octave-${OCTAVE_VERSION}-w64-installer.exe
	@touch lib64/octave/bin/octave.exe

octave-libs: lib32/octave/bin/octave.exe lib64/octave/bin/octave.exe

clean-octave:
	rm -f octave-${OCTAVE_VERSION}-w64-installer.exe
	rm -f octave-${OCTAVE_VERSION}-w64-installer.exe.sig
	rm -f octave-${OCTAVE_VERSION}-w32-installer.exe
	rm -f octave-${OCTAVE_VERSION}-w32-installer.exe.sig
	rm -rf lib32/octave
	rm -rf lib64/octave

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
