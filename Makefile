include versions.mk

.PHONY: clean-openblas clean-openblas-tar cleanall-openblas \
	clean-boost clean-boost-tar cleanall-boost \
	clean-gsl clean-gsl-tar cleanall-gsl \
	all

all: sources/OpenBLAS sources/Boost sources/Gsl sources/Lapack sources/matIO sources/Slicot

clean: clean-openblas clean-boost clean-gsl clean-lapack clean-matio clean-slicot

cleanall: cleanall-openblas cleanall-boost cleanall-gsl cleanall-lapack cleanall-matio cleanall-slicot

#
# OpenBLAS library
#

sources/OpenBLAS: v${OPENBLAS_VERSION}.tar.gz
	rm -rf sources/OpenBLAS
	tar -zxf v${OPENBLAS_VERSION}.tar.gz
	mkdir sources/OpenBLAS
	mv OpenBLAS-${OPENBLAS_VERSION}/* sources/OpenBLAS
	rm -r OpenBLAS-${OPENBLAS_VERSION}

v${OPENBLAS_VERSION}.tar.gz: versions.mk
	rm -f v${OPENBLAS_VERSION}.tar.gz
	wget http://github.com/xianyi/OpenBLAS/archive/v${OPENBLAS_VERSION}.tar.gz

clean-openblas:
	rm -rf sources/OpenBLAS

clean-openblas-tar:
	rm -f v${OPENBLAS_VERSION}.tar.gz

cleanall-openblas: clean-openblas clean-openblas-tar

lib32/openblas.a: sources/OpenBLAS
	cp sources/OpenBLAS/Makefile.rule sources/OpenBLAS/Makefile.rule.copy
	patch sources/OpenBLAS/Makefile.rule < patch/openblas-w32.patch
	make -C sources/OpenBLAS
	mv sources/OpenBLAS/Makefile.rule.copy sources/OpenBLAS/Makefile.rule
	i686-w64-mingw32-strip --strip-debug sources/OpenBLAS/libopenblas.a
	mv sources/OpenBLAS/libopenblas.a lib32/openblas.a

lib64/openblas.a: sources/OpenBLAS
	cp sources/OpenBLAS/Makefile.rule sources/OpenBLAS/Makefile.rule.copy
	patch sources/OpenBLAS/Makefile.rule < patch/openblas-w64.patch
	make -C sources/OpenBLAS
	mv sources/OpenBLAS/Makefile.rule.copy sources/OpenBLAS/Makefile.rule
	x86_64-w64-mingw32-strip --strip-debug sources/OpenBLAS/libopenblas.a
	mv sources/OpenBLAS/libopenblas.a lib64/openblas.a

#
# Boost library
#

sources/Boost: boost_${BOOST_VERSION}.tar.bz2
	rm -rf sources/Boost
	tar xjf boost_${BOOST_VERSION}.tar.bz2
	mkdir sources/Boost
	mv boost_${BOOST_VERSION}/* sources/Boost
	rm -r boost_${BOOST_VERSION}

boost_${BOOST_VERSION}.tar.bz2: versions.mk
	rm -f boost_${BOOST_VERSION}.tar.bz2
	wget https://sourceforge.net/projects/boost/files/boost/`echo "${BOOST_VERSION}" | sed -e 's/_/./g'`/boost_${BOOST_VERSION}.tar.bz2/download -O boost_${BOOST_VERSION}.tar.bz2

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

gsl-${GSL_VERSION}.tar.gz: versions.mk
	rm -f gsl-${GSL_VERSION}.tar.gz
	wget http://fr.mirror.babylon.network/gnu/gsl/gsl-${GSL_VERSION}.tar.gz

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

lapack-${LAPACK_VERSION}.tgz: versions.mk
	rm -f lapack-${LAPACK_VERSION}.tgz
	wget http://www.netlib.org/lapack/lapack-${LAPACK_VERSION}.tgz

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

matio-${MATIO_VERSION}.tar.gz: versions.mk
	rm matio-${MATIO_VERSION}.tar.gz
	wget https://sourceforge.net/projects/matio/files/matio/${MATIO_VERSION}/matio-${MATIO_VERSION}.tar.gz/download -O matio-${MATIO_VERSION}.tar.gz

clean-matio:
	rm -r sources/matIO

clean-matio-tar:
	rm matio-${MATIO_VERSION}.tar.gz

cleanall-matio: clean-matio clean-matio-tar

#
# Slicot
#

sources/Slicot: slicot45.tar.gz
	rm -rf sources/Slicot
	tar -zxf slicot45.tar.gz
	mkdir -p sources/Slicot
	mv slicot/* sources/Slicot
	rm -r slicot

slicot45.tar.gz: versions.mk
	rm -f slicot45.tar.gz
	wget --user-agent="User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:10.0) Gecko/20100101 Firefox/10.0" -c http://slicot.org/objects/software/shared/slicot45.tar.gz

clean-slicot:
	rm -rf sources/Slicot

clean-slicot-tar:
	rm -f slicot45.tar.gz

cleanall-slicot: clean-slicot clean-slicot-tar
