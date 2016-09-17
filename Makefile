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
	all

download: sources/OpenBLAS sources/Boost sources/Gsl sources/Lapack sources/matIO sources/Slicot sources/Zlib

clean: clean-openblas clean-boost clean-gsl clean-lapack clean-matio clean-slicot clean-zlib

cleanall: cleanall-openblas cleanall-boost cleanall-gsl cleanall-lapack cleanall-matio cleanall-slicot cleanall-zlib

#
# OpenBLAS library
#

sources/OpenBLAS: v${OPENBLAS_VERSION}.tar.gz
	rm -rf sources/OpenBLAS
	tar -zxf v${OPENBLAS_VERSION}.tar.gz
	mkdir sources/OpenBLAS
	mv OpenBLAS-${OPENBLAS_VERSION}/* sources/OpenBLAS
	rm -r OpenBLAS-${OPENBLAS_VERSION}

v${OPENBLAS_VERSION}.tar.gz: versions/openblas.version
	rm -f v${OPENBLAS_VERSION}.tar.gz
	wget http://github.com/xianyi/OpenBLAS/archive/v${OPENBLAS_VERSION}.tar.gz
	touch v${OPENBLAS_VERSION}.tar.gz

clean-openblas:
	rm -rf sources/OpenBLAS

clean-openblas-tar:
	rm -f v${OPENBLAS_VERSION}.tar.gz

cleanall-openblas: clean-openblas clean-openblas-tar

lib32/libopenblas.a: sources/OpenBLAS
	cp sources/OpenBLAS/Makefile.rule sources/OpenBLAS/Makefile.rule.copy
	patch sources/OpenBLAS/Makefile.rule < patch/openblas-w32.patch
	make -C sources/OpenBLAS
	mv sources/OpenBLAS/Makefile.rule.copy sources/OpenBLAS/Makefile.rule
	i686-w64-mingw32-strip --strip-debug sources/OpenBLAS/libopenblas.a
	mv sources/OpenBLAS/libopenblasp-r${OPENBLAS_VERSION}.a lib32/libopenblasp-r${OPENBLAS_VERSION}.a
	mv sources/OpenBLAS/libopenblas.a lib32/libopenblas.a

lib64/libopenblas.a: sources/OpenBLAS
	cp sources/OpenBLAS/Makefile.rule sources/OpenBLAS/Makefile.rule.copy
	patch sources/OpenBLAS/Makefile.rule < patch/openblas-w64.patch
	make -C sources/OpenBLAS
	mv sources/OpenBLAS/Makefile.rule.copy sources/OpenBLAS/Makefile.rule
	x86_64-w64-mingw32-strip --strip-debug sources/OpenBLAS/libopenblas.a
	mv sources/OpenBLAS/libopenblasp-r${OPENBLAS_VERSION}.a lib64/libopenblasp-r${OPENBLAS_VERSION}.a
	mv sources/OpenBLAS/libopenblas.a lib64/libopenblas.a

clean-openblas-32:
	rm -rf lib32/*openblas*

clean-openblas-64:
	rm -rf lib64/*openblas*


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

sources/Gsl: gsl-${GSL_VERSION}.tar.gz
	rm -rf sources/Gsl
	tar -zxf gsl-${GSL_VERSION}.tar.gz
	mkdir -p sources/Gsl
	mv gsl-${GSL_VERSION}/* sources/Gsl
	rm -r gsl-${GSL_VERSION}

gsl-${GSL_VERSION}.tar.gz: versions/gsl.version
	rm -f gsl-${GSL_VERSION}.tar.gz
	wget http://fr.mirror.babylon.network/gnu/gsl/gsl-${GSL_VERSION}.tar.gz
	touch gsl-${GSL_VERSION}.tar.gz

clean-gsl:
	rm -rf sources/Gsl

clean-gsl-tar:
	rm -f gsl-${GSL_VERSION}.tar.gz

cleanall-gsl: clean-gsl clean-gsl-tar

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
	rm -rf sources/Gsl

clean-lapack-tar:
	rm -f lapack-${LAPACK_VERSION}.tgz

cleanall-lapack: clean-lapack clean-lapack-tar

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
