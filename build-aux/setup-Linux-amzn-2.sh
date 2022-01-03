#!/bin/bash
#
# Install script for Amazon EC2 instance 
#

chmod -R 775 /usr/local
chown -R root:adm /usr/local

# Install needed system tools
yum -q clean all
# install deltrpm
yum install deltarpm -y
yum -q update -y 
yum -q install git -y
yum -q groupinstall "Development Tools" -y
yum -q install cmake -y 
yum -q install ncurses-devel -y
#yum -q install epel-release -y
yum -q install libcurl-devel -y
yum install openssl-devel bzip2-devel libffi-devel zlib-devel xz-devel -q -y
# python3.9.x support needed as of 4.2
if [ ! -x /usr/local/bin/python3 -o "$(/usr/local/bin/python3 --version | cut -f-2 -d.)" != "Python 3.9" ]; then
	echo "install python 3.9.6"
	cd /usr/local/src
	curl https://www.python.org/ftp/python/3.9.6/Python-3.9.6.tgz | tar xz
	cd /usr/local/src/Python-3.9.6
	./configure --prefix=/usr/local --enable-optimizations --with-system-ffi --with-computed-gotos --enable-loadable-sqlite-extensions CFLAGS="-fPIC"
	echo "make altinstall "
    make -j $(nproc)
	make altinstall
	ln -sf /usr/local/bin/python3.9 /usr/local/bin/python3
	ln -sf /usr/local/bin/python3.9-config /usr/local/bin/python3-config
	ln -sf /usr/local/bin/pydoc3.9 /usr/local/bin/pydoc
	ln -sf /usr/local/bin/idle3.9 /usr/local/bin/idle
	ln -sf /usr/local/bin/pip3.9 /usr/local/bin/pip3
	# setup up python path due to the ec2 default python 3.7 setting
	
	# Ec2 have Python3.7.x preinstalled, switch to python3.9.6. Pre-installation locats at /bin/python3
	# ln -sf /usr/local/bin/python3.9 /bin/python3
	# ln -sf /usr/local/bin/python3.9-config /bin/python3-config
	# ln -sf /usr/local/bin/pydoc3.9 /bin/pydoc
	# ln -sf /usr/local/bin/idle3.9 /bin/idle
	# ln -sf /usr/local/bin/pip3.9 /bin/pip3
	curl -sSL https://bootstrap.pypa.io/get-pip.py | bin/python3
    echo "install python depencies "
	/usr/local/bin/python3 -m pip install mysql-connector mysql-client     
    /usr/local/bin/python3 -m pip install matplotlib Pillow pandas numpy networkx pytz pysolar PyGithub scikit-learn xlrd boto3
    /usr/local/bin/python3 -m pip install IPython censusdata

fi
# export PYTHONPATH="."
# export PATH=/usr/local/bin:$PATH


# valid install
# reference https://blog.kloud.com.au/2016/05/30/installing-mono-into-amazon-linux/
# if [ ! -f /usr/bin/mono ]; then
# 	echo "Install mono"
# 	cd ~
# 	wget https://dl.fedoraproject.org/pub/fedora/linux/development/rawhide/Everything/x86_64/os/Packages/l/libpng15-1.5.30-13.fc35.x86_64.rpm
# 	yum install -y ~/downloads/mono_dependencies/libpng15-1.5.30-13.fc35.x86_64.rpm
# 	yum install yum-utils
# 	rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
# 	yum-config-manager --add-repo http://download.mono-project.com/repo/centos/
# 	yum clean all
# 	yum makecache
# 	yum install mono-complete -y
# 	cd ~
# 	rm -rf /tmp/mono_deps
# fi

#https://blog.kloud.com.au/2016/05/30/installing-mono-into-amazon-linux/
#
# amazon-linux-extras install mono
# https://gist.github.com/yetanotherchris/42b429059e5fe1b3f7bb4169f5706c00
# mono
# if [ ! -f /usr/bin/mono ]; then
# 	#https://gist.github.com/yetanotherchris/42b429059e5fe1b3f7bb4169f5706c00
# 	# rpmkeys --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
# 	# su -c 'curl https://download.mono-project.com/repo/centos8-stable.repo | tee /etc/yum.repos.d/mono-centos8-stable.repo'
# 	# yum -q install mono-devel -y
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
# cd /tmp
# curl http://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/m/mdbtools-0.7.1-3.el7.x86_64.rpm > mdbtools-0.7.1-3.el7.x86_64.rpm
# rpm -Uvh mdbtools-0.7.1-3.el7.x86_64.rpm
echo "Install support"
cd ~
amazon-linux-extras install epel -y
yum-config-manager --enable epel
yum -q install mdbtools -y

#latex
echo "Install latex"
yum -q install texlive -y
