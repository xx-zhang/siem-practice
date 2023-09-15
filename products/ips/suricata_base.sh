#!/bin/bash
# CopyRight 2018 
# Ref https://github.com/xx-zhang/suricata-plus/blob/master/docker-suricata/centos/suricata_ips.sh

SURICATA_DEPS_DIR=/builds/deps/
SURICATA_BUILD_WORKING_DIR=/builds/workdir/

install_gcc9 ()  {
    yum -y install centos-release-scl 
    yum -y install devtoolset-9 
  export CC=/opt/rh/devtoolset-9/root/bin/gcc
  export CXX=/opt/rh/devtoolset-9/root/bin/g++
}


# yum --enablerepo=elrepo-kernel install kernel-ml
if [ ! -d ${SURICATA_DEPS_DIR} ]; then
  mkdir -p ${SURICATA_DEPS_DIR} ;
fi

if [ ! -d ${SURICATA_BUILD_WORKING_DIR} ]; then
  mkdir -p ${SURICATA_BUILD_WORKING_DIR} ;
fi

function error_exit
{
  echo -e "\033[41;30m [ERROR]"$1"\033[0m" 1>&2
  exit 1
}

function say_ok
{
  echo -e "\033[44m[OK]"$1"\033[0m"
}


init_centos() {
    export LANG en_US.UTF-8
    ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    echo Asia/Shanghai > /etc/timezone
    curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo 
    sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo 
    curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

    yum makecache && yum -y update && yum -y install wget cmake3 cmake

    install_gcc9

    say_ok "Inital Centos deps OK!"

}

install_deps() {
    yum -y install epel-release  wget curl git 

    yum -y install autoconf automake libtool pkgconfig \
        rust cargo file file-devel pcre2-devel \
        gcc gcc-c++ git hiredis-devel \
        jansson-devel jq lua-devel libyaml-devel zlib-devel \
        libnfnetlink-devel libnetfilter_queue-devel \
        libnet-devel  libcap-ng-devel \
        libevent-devel libmaxminddb-devel \
        libpcap-devel  libprelude-devel numactl-devel \
        lz4-devel make nspr-devel nss-devel nss-softokn-devel \
        pcre-devel python3 python3-pip python3-devel \
        which  && \
        yum clean all

   yum install -y libpcap zlib libyaml \
    jansson-devel pcre-devel lua-devel \
    libmaxminddb-devel \
    libnetfilter_queue-devel nss-devel \
    libyaml-devel zlib-devel && \
        yum clean all

   yum install -y flex bisson 

   pip3 --upgrade pip install  Pyyaml -i https://pypi.tuna.tsinghua.edu.cn/simple


   say_ok "Install Centos deps OK!"
}


install_cargo() {

# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# tar -xzf ${SURICATA_DEPS_DIR}/rust-1.65.0-x86_64-unknown-linux-gnu.tar.gz -C ${SURICATA_BUILD_WORKING_DIR}
# ln -sf ${SURICATA_BUILD_WORKING_DIR}/rust-1.65.0-x86_64-unknown-linux-gnu/rustc/bin/rustc /usr/bin/rustc
# ln -sf ${SURICATA_BUILD_WORKING_DIR}/rust-1.65.0-x86_64-unknown-linux-gnu/cargo/bin/cargo /usr/bin/cargo


mkdir -p /root/.cargo/
cat > /root/.cargo/config <<- EOF

[source.crates-io]
registry = "https://github.com/rust-lang/crates.io-index"
replace-with = 'ustc'

[source.ustc]
registry = "git://mirrors.ustc.edu.cn/crates.io-index"

[source.tuna]
registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"

EOF

/usr/bin/cargo install cbindgen && \
    ln -sf /root/.cargo/bin/cbindgen /usr/bin/cbindgen

say_ok "Cargo source Inital OK!"
}

install_luajit() {
  cd ${SURICATA_BUILD_WORKING_DIR}
  tar -xzf ${SURICATA_DEPS_DIR}/LuaJIT-2.0.5.tar.gz && cd LuaJIT-2.0.5 && make && make install


say_ok "Install LuaJit !"
}

install_hyperscan() {

cd ${SURICATA_BUILD_WORKING_DIR}
## 安装 hyperscan ; https://www.cnblogs.com/yanhai307/p/10770821.html
tar -zxf ${SURICATA_DEPS_DIR}/ragel-6.10.tar.gz
cd ragel-6.10
./configure && make -j$(nproc) && make install

cd ${SURICATA_BUILD_WORKING_DIR}
tar -zxf ${SURICATA_DEPS_DIR}/boost_1_69_0.tar.gz
cd boost_1_69_0 
./bootstrap.sh 
./b2 --with-iostreams --with-random install
ldconfig

cd ${SURICATA_BUILD_WORKING_DIR}
tar -zxf ${SURICATA_DEPS_DIR}/hyperscan-5.4.2.tar.gz 
cd hyperscan-5.4.2
mkdir cmake-build && cd cmake-build
cmake -DBUILD_SHARED_LIBS=on -DCMAKE_BUILD_TYPE=Release .. && \
make -j$(nproc) && make install
ldconfig

say_ok "Install hyperscan !"

}

install_libhtp() {

cd ${SURICATA_BUILD_WORKING_DIR}
#   tar -zxf ${SURICATA_BUILD_WORKING_DIR}/suricata-7.0.0.tar.gz
tar -zxf ${SURICATA_DEPS_DIR}/libhtp-0.5.45.tar.gz
cd libhtp-0.5.45/
./autogen.sh 
CPPFLAGS=-I/usr/include/ CFLAGS=-g ./configure \
    --enable-rust=yes \
    --enable-gccmarch-native=no
# ldconfig 

say_ok "Install LibHtp OK!"

}

install_suricata() {
cd ${SURICATA_BUILD_WORKING_DIR}

tar -zxf ${SURICATA_DEPS_DIR}/suricata-7.0.0.tar.gz
cd suricata-suricata-7.0.0
./autogen.sh
cp -r ../libhtp-0.5.45/ .
CPPFLAGS=-I/usr/include/ CFLAGS=-g LIBS="-lrt" ./configure  \
    --enable-rust=yes \
    --enable-gccmarch-native=no \
    --enable-libmagic=yes \
    --prefix=/topnsm/idps/ \
    --enable-geoip  \
    --enable-luajit \
    --with-libluajit-includes=/usr/local/include/luajit-2.0/ \
    --with-libluajit-libraries=/usr/local/lib/ \
    --with-libhs-includes=/usr/local/include/hs/ \
    --with-libhs-libraries=/usr/local/lib/ \
    --enable-profiling \
    --enable-nfqueue

make clean && make -j$(nproc) && make install && ldconfig
make install-conf

say_ok "Install Suricata OK!"

# patchelf --set-rpath /topnsm/idps/lib64/ ./bin/suricata
# patchelf --add-needed ./lib64/libfuzzy.so.2.1.0 ./sbin/nginx
}


changelog() {
cat << EndOfCL
    # 01.06.2021 - First commit
EndOfCL
}


init_centos
install_deps
install_cargo
install_hyperscan
install_luajit
install_libhtp
install_suricata
