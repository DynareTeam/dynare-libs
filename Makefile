include versions.mk

.PHONY: clean-openblas clean-openblas-tar cleanall-openblas \
	clean-boost clean-boost-tar cleanall-boost \
	all

all: sources/OpenBLAS sources/Boost

#
# OpenBLAS library
#

sources/OpenBLAS: v${OPENBLAS_VERSION}.tar.gz
	tar -zxvf v${OPENBLAS_VERSION}.tar.gz
	mv OpenBLAS-${OPENBLAS_VERSION} sources/OpenBLAS

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
	tar xjf boost_${BOOST_VERSION}.tar.bz2
	mv boost_${BOOST_VERSION} sources
	mv sources/boost_${BOOST_VERSION} sources/Boost

boost_${BOOST_VERSION}.tar.bz2:
	wget https://sourceforge.net/projects/boost/files/boost/`echo "${BOOST_VERSION}" | sed -e 's/_/./g'`/boost_${BOOST_VERSION}.tar.bz2/download -O boost_${BOOST_VERSION}.tar.bz2

clean-boost:
	rm -r sources/Boost

clean-boost-tar:
	rm boost_${BOOST_VERSION}.tar.bz2

cleanall-boost: clean-boost clean-boost-tar
