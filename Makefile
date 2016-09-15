include versions.mk

.PHONY: clean-openblas clean-openblas-tar cleanall-openblas \
	clean-boost clean-boost-tar cleanall-boost \
	clean-gsl clean-gsl-tar cleanall-gsl \
	all

all: sources/OpenBLAS sources/Boost sources/Gsl sources/Lapack

clean: clean-openblas clean-boost clean-gsl clean-lapack

cleanall: cleanall-openblas cleanall-boost cleanall-gsl cleanall-lapack

#
# OpenBLAS library
#

sources/OpenBLAS: v${OPENBLAS_VERSION}.tar.gz
	rm -rf sources/OpenBLAS
	tar -zxf v${OPENBLAS_VERSION}.tar.gz
	mkdir sources/OpenBLAS
	mv OpenBLAS-${OPENBLAS_VERSION}/* sources/OpenBLAS
	rm -r OpenBLAS-${OPENBLAS_VERSION}

v${OPENBLAS_VERSION}.tar.gz:
	wget http://github.com/xianyi/OpenBLAS/archive/v${OPENBLAS_VERSION}.tar.gz

clean-openblas:
	rm -r sources/OpenBLAS

clean-openblas-tar:
	rm v${OPENBLAS_VERSION}.tar.gz

cleanall-openblas: clean-openblas clean-openblas-tar

#
# Boost library
#

sources/Boost: boost_${BOOST_VERSION}.tar.bz2
	rm -rf sources/Boost
	tar xjf boost_${BOOST_VERSION}.tar.bz2
	mkdir sources/Boost
	mv boost_${BOOST_VERSION}/* sources/Boost
	rm -r boost_${BOOST_VERSION}

boost_${BOOST_VERSION}.tar.bz2:
	wget https://sourceforge.net/projects/boost/files/boost/`echo "${BOOST_VERSION}" | sed -e 's/_/./g'`/boost_${BOOST_VERSION}.tar.bz2/download -O boost_${BOOST_VERSION}.tar.bz2

clean-boost:
	rm -r sources/Boost

clean-boost-tar:
	rm boost_${BOOST_VERSION}.tar.bz2

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

gsl-${GSL_VERSION}.tar.gz:
	wget http://fr.mirror.babylon.network/gnu/gsl/gsl-${GSL_VERSION}.tar.gz

clean-gsl:
	rm -r sources/Gsl

clean-gsl-tar:
	rm gsl-${GSL_VERSION}.tar.gz

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

lapack-${LAPACK_VERSION}.tgz:
	wget http://www.netlib.org/lapack/lapack-${LAPACK_VERSION}.tgz

clean-lapack:
	rm -r sources/Gsl

clean-lapack-tar:
	rm lapack-${LAPACK_VERSION}.tgz

cleanall-lapack: clean-lapack clean-lapack-tar

