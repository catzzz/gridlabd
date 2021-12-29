FROM centos:8

# variable pass from install.sh
ARG NPROC=${NPROC}
ARG RUN_VALIDATION=${RUN_VALIDATION}
RUN echo "NPROC=$NPROC RUN_VALIDATION=$RUN_VALIDATION"
# Install needed system tools
RUN yum clean all
RUN echo "Install needed system tools"
RUN yum groupinstall "Development Tools" -y
RUN yum install cmake -y 
RUN yum install ncurses-devel -y
RUN yum install epel-release -y
RUN yum install curl-devel -y
RUN yum install which -y
RUN yum install svn -y

RUN yum install 'dnf-command(config-manager)' -y



# change directory
WORKDIR "/usr/local/src"
RUN yum install gcc openssl-devel bzip2-devel libffi-devel zlib-devel  xz-devel  -y

# Install python 3.9.6
RUN curl https://www.python.org/ftp/python/3.9.6/Python-3.9.6.tgz > Python-3.9.6.tgz
RUN tar xzf Python-3.9.6.tgz 
WORKDIR "/usr/local/src/Python-3.9.6"
RUN ./configure --prefix=/usr/local --enable-optimizations --with-system-ffi --with-computed-gotos --enable-loadable-sqlite-extensions CFLAGS="-fPIC"
RUN make -j${NPROC}
RUN make altinstall
RUN /sbin/ldconfig /usr/local/lib
RUN ln -sf /usr/local/bin/python3.9 /usr/local/bin/python3
RUN ln -sf /usr/local/bin/python3.9-config /usr/local/bin/python3-config
RUN ln -sf /usr/local/bin/pydoc3.9 /usr/local/bin/pydoc
RUN ln -sf /usr/local/bin/idle3.9 /usr/local/bin/idle
RUN ln -sf /usr/local/bin/pip3.9 /usr/local/bin/pip3
#Python 3 pacakges
RUN echo "Install Python pacakges"
RUN /usr/local/bin/python3 -m pip install matplotlib 
RUN /usr/local/bin/python3 -m pip install Pillow 
RUN /usr/local/bin/python3 -m pip install pandas 
RUN /usr/local/bin/python3 -m pip install numpy 
RUN /usr/local/bin/python3 -m pip install networkx 
RUN /usr/local/bin/python3 -m pip install pytz 
RUN /usr/local/bin/python3 -m pip install pysolar 
RUN /usr/local/bin/python3 -m pip install PyGithub 
RUN /usr/local/bin/python3 -m pip install scikit-learn 
RUN /usr/local/bin/python3 -m pip install xlrd 
RUN /usr/local/bin/python3 -m pip install boto3
RUN /usr/local/bin/python3 -m pip install IPython 
RUN /usr/local/bin/python3 -m pip install censusdata
WORKDIR /usr/local/src
# remove python tgz
RUN rm -f Python-3.9.6.tgz
RUN pip3 install --upgrade pip



RUN export PYTHONPATH="."
RUN export PATH=/usr/local/bin:$PATH
RUN export MAKEFLAGS=-j${NPROC}
RUN export PYTHONSETUPFLAGS="-j20"

# install doxygen
RUN	git clone https://github.com/doxygen/doxygen.git /usr/local/src/doxygen --depth 1
RUN	mkdir /usr/local/src/doxygen/build
WORKDIR "/usr/local/src/doxygen/build"
RUN	cmake -G "Unix Makefiles" ..
RUN	make 
RUN	make install


# # COPY gridlabd 
WORKDIR "/usr/local/src/gridlabd"


COPY . .
# WORKDIR "/usr/local/src/gridlabd/docker/docker-build"

# ENV GET_WEATHER=no

# ARG RUN_VALIDATION

# ARG NPROC
# # ENV LD_LIBRARY_PATH /usr/local/lib


# # RUN chmod +wx *.sh
# # RUN ./gridlabd.sh
# WORKDIR "/usr/local/src/gridlabd"

RUN autoreconf -isf && ./configure 
RUN make -j${NPROC} system
# numpy need to be upgrade after make system
RUN /usr/local/bin/python3 -m pip install --upgrade numpy 
# # #variables
# # ENV GET_WEATHER=no
# # ENV REMOVE_SOURCE=no
# # ARG RUN_VALIDATION=no
# # ENV LD_LIBRARY_PATH /usr/local/lib
# # # get weather
RUN if [ "${GET_WEATHER:-yes}" == "yes" ]; then make index ; fi

# # # run validation
RUN if [ "${RUN_VALIDATION:-no}" == "yes" ]; then gridlabd -T ${NPROC} --validate; fi

# EXPOSE 6266-6299/tcp