FROM ubuntu:20.04
ARG NPROC=6

# WORKDIR /usr/local/src/gridlabd
# COPY . .

# ARG NPROC=6
RUN apt-get -q update
RUN apt-get -q install tzdata -y

# # install system build tools needed by gridlabd
RUN apt-get -q install git -y
RUN apt-get -q install unzip -y
RUN apt-get -q install autoconf -y
RUN apt-get -q install libtool -y
RUN apt-get -q install g++ -y
RUN apt-get -q install cmake -y 
RUN apt-get -q install flex -y
RUN apt-get -q install bison -y
RUN apt-get -q install libcurl4-gnutls-dev -y
RUN apt-get -q install libncurses5-dev -y
RUN apt-get -q install liblzma-dev -y
RUN apt-get -q install libssl-dev -y
RUN apt-get -q install libbz2-dev -y
RUN apt-get -q install libffi-dev -y
RUN apt-get -q install zlib1g-dev -y
RUN apt-get -q install curl -y

# # install python 3.9

# # Install python 3.9.6
WORKDIR "/usr/local/src"
RUN curl https://www.python.org/ftp/python/3.9.6/Python-3.9.6.tgz > Python-3.9.6.tgz
RUN tar xzf Python-3.9.6.tgz 
WORKDIR "/usr/local/src/Python-3.9.6"
# RUN ./configure --prefix=/usr/local --enable-optimizations --with-system-ffi --with-computed-gotos --enable-loadable-sqlite-extensions CFLAGS="-fPIC"
RUN ./configure --prefix=/usr/local --enable-optimizations --enable-shared --with-system-ffi --enable-loadable-sqlite-extensions CXXFLAGS="-fPIC"
RUN make -j${NPROC}
RUN make altinstall
RUN /sbin/ldconfig /usr/local/lib
RUN ln -sf /usr/local/bin/python3.9 /usr/local/bin/python3
RUN ln -sf /usr/local/bin/python3.9-config /usr/local/bin/python3-config
RUN ln -sf /usr/local/bin/pydoc3.9 /usr/local/bin/pydoc
RUN ln -sf /usr/local/bin/idle3.9 /usr/local/bin/idle
RUN ln -sf /usr/local/bin/pip3.9 /usr/local/bin/pip3
# #Python 3 pacakges

# RUN echo "Install Python pacakges"
RUN /usr/local/bin/python3 -m pip install mysql-connector
RUN /usr/local/bin/python3 -m pip install matplotlib 
RUN /usr/local/bin/python3 -m pip install Pillow 
RUN /usr/local/bin/python3 -m pip install pandas 
RUN /usr/local/bin/python3 -m pip install numpy 
RUN /usr/local/bin/python3 -m pip install networkx 
# RUN /usr/local/bin/python3 -m pip install pytz 
# RUN /usr/local/bin/python3 -m pip install pysolar 
# RUN /usr/local/bin/python3 -m pip install PyGithub 
# RUN /usr/local/bin/python3 -m pip install scikit-learn 
# RUN /usr/local/bin/python3 -m pip install xlrd 
# RUN /usr/local/bin/python3 -m pip install boto3
RUN /usr/local/bin/python3 -m pip install IPython 
RUN /usr/local/bin/python3 -m pip install wheel
RUN /usr/local/bin/python3 -m pip install censusdata

RUN export PYTHONPATH="."
RUN export PATH=/usr/local/bin:$PATH
RUN export MAKEFLAGS=-j20
RUN export PYTHONSETUPFLAGS="-j 20"

WORKDIR /usr/local/src
# # remove python tgz
RUN rm -f Python-3.9.6.tgz

# install python libraries by validation
# /usr/local/bin/python3 pip -m install --upgrade pip
# /usr/local/bin/python3 pip -m install mysql-connector mysql-client matplotlib numpy pandas Pillow

# doxggen
# apt-get -q install gawk -y
# if [ ! -x /usr/bin/doxygen ]; then
# 	if [ ! -d /usr/local/src/doxygen ]; then
# 		git clone https://github.com/doxygen/doxygen.git /usr/local/src/doxygen
# 	fi
# 	if [ ! -d /usr/local/src/doxygen/build ]; then
# 		mkdir /usr/local/src/doxygen/build
# 	fi
# 	cd /usr/local/src/doxygen/build
# 	cmake -G "Unix Makefiles" ..
# 	make
# 	make install
# fi

# mono
# apt-get -q install curl -y
# if [ ! -f /usr/bin/mono ]; then
# 	cd /tmp
# 	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
# 	echo "deb http://download.mono-project.com/repo/ubuntu wheezy/snapshots/4.8.0 main" | tee /etc/apt/sources.list.d/mono-official.list
# 	apt-get -q update -y
# 	apt-get -q install mono-devel -y
# fi

# natural_docs
# if [ ! -x /usr/local/bin/natural_docs ]; then
# 	cd /usr/local
# 	curl https://www.naturaldocs.org/download/natural_docs/2.0.2/Natural_Docs_2.0.2.zip > natural_docs.zip
# 	unzip -qq natural_docs
# 	rm -f natural_docs.zip
# 	mv Natural\ Docs natural_docs
# 	echo '#!/bin/bash
# mono /usr/local/natural_docs/NaturalDocs.exe \$*' > /usr/local/bin/natural_docs
# 	chmod a+x /usr/local/bin/natural_docs
# fi

# converter support
# RUN /usr/local/bin/python3 -m pip install networkx
RUN apt-get -q install mdbtools -y

WORKDIR "/usr/local/src/gridlabd"
COPY . .
RUN autoreconf -isf && ./configure 
RUN make -j${NPROC} system
# # # numpy need to be upgrade after make system
RUN /usr/local/bin/python3 -m pip install --upgrade numpy 