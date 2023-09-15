#!/bin/bash 


get_qnsm_src {
    git clone https://github.com/iqiyi/qnsm
    
}


install_dpdk {
    mkdir -p /opt/qnsm_deps/ && \
    cd /opt/qnsm_deps/ && \
    wget -c -N https://fast.dpdk.org/rel/dpdk-19.11.14.tar.xz  && \
    tar xf dpdk-19.11.14.tar.xz

    cd dpdk-stable-19.11.14 && \
    export RTE_SDK=`pwd` && \
    export RTE_TARGET=x86_64-native-linuxapp-gcc && \
    make install T=${RTE_TARGET} DESTDIR=install
}

install_deps() {
    # yum install yum-plugin-downloadonly yum-utils 
    yum -y install epel-release  wget curl git 
    # yum install kernel-devel-$(uname -r) 
    # yum install --downloadonly --downloaddir=./ gcc gcc-c++  kernel-devel kernel-headers kernel.x86_64 net-tools numactl-devel.x86_64 numactl-libs.x86_64 pciutils kernel-devel-3.10.0-1160.88.1.el7.x86_64

    yum -y install autoconf automake libtool pkgconfig \
        rust cargo file file-devel \
        gcc gcc-c++ git hiredis-devel \
        jansson-devel jq lua-devel libyaml-devel zlib-devel \
        libnfnetlink-devel libnetfilter_queue-devel \
        libnet-devel  libcap-ng-devel \
        libevent-devel libmaxminddb-devel \
        libpcap-devel  libprelude-devel \
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

   yum install -y flex bisson kernel-devel
}


qnsm_deps_centos7 {
    yum -y install epel-release 
    yum -y install patch git gcc gcc-c++ wget 
    yum install -y libpcap-devel pcre-devel file-devel libyaml-devel \
        jansson-devel libcap-ng-devel librdkafka-devel nss-devel nspr-devel make gcc \
        libxml2-devel python-pip 

    # pip install  --upgrade pip  configparser
    pip install  configparser==3.5.0 
     
}


install_cargo() {
    curl -sSf https://static.rust-lang.org/rustup.sh | sh
    
  mkdir -p /root/.cargo/
    cat > /root/.cargo/config <<- EOF

[source.crates-io]
registry = "https://github.com/rust-lang/crates.io-index"
replace-with = 'tuna'

[source.tuna]
registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"

EOF

/usr/bin/cargo install cbindgen && \
    ln -sf /root/.cargo/bin/cbindgen /usr/bin/cbindgen

pip3 install Pyyaml -i https://pypi.tuna.tsinghua.edu.cn/simple

}


install_htp {
     git clone https://github.com/OISF/libhtp.git --depth=1 && \
            ./autogen.sh && \
            CPPFLAGS=-I/usr/include/ CFLAGS=-g  \
            ./configure \
            --enable-rust=yes \
            --enable-gccmarch-native=no 
}

download_suricata() {
    # https://static.rust-lang.org/dist/rust-1.72.0-x86_64-unknown-linux-gnu.tar.gz
    # https://forge.rust-lang.org/infra/other-installation-methods.html

    cd /srv && git clone https://github.com/OISF/suricata.git --depth=1 && \
        cd suricata 
        # cd suricata-update && \
        #     curl -L \
        #     https://github.com/OISF/suricata-update/archive/master.tar.gz | \
        #       tar zxf - --strip-components=1
}

install_suricata {
    mkdri -p /topnsm/idps || echo "[/topnsm/idps] DIR exist." 
    cd /srv/suricata && ./autogen.sh && \
  LIBS="-lrt" CPPFLAGS=-I/usr/include/ CFLAGS=-g ./configure  \
  --enable-rust=yes \
  --enable-gccmarch-native=no \
  --enable-dpdk=yes \
  --enable-libmagic=yes \
  --prefix=/topnsm/idps/ \
  --enable-geoip  \
  --enable-luajit \
  --with-libluajit-includes=/usr/local/include/luajit-2.0/ \
  --with-libluajit-libraries=/usr/local/lib/ \
  --with-libhs-includes=/usr/local/include/hs/ \
  --with-libhs-libraries=/usr/local/lib/ \
  --enable-profiling --enable-nfqueue

    make clean && make -j 2 && make install && ldconfig
    make install-conf

    # patchelf modify

}

dpdk_test {

    export RTE_SDK='/root/dpdk-stable-19.11.14/' && \
    export RTE_TARGET=x86_64-native-linuxapp-gcc && \
    python scripts/setup_dpdk_env.py ./conf/dpdk_env.cfg
}

hugepage_cfg {
    # 在/etc/default/grub中添加GRUB_CMDLINE_LINUX=“net.ifnames=0 biosdevname=0 default_hugepagesz=2M hugepagesz=2M hugepages=2048”，
    

    if [`cat /etc/fstab | grep huge | wc -l` -gt 0]; then 
        mkdir /mnt/huge || echo 'huge page file exist' 
        chmod 777 /mnt/huge 
        echo 'nodev /mnt/huge hugetlbfs defaults 0 0' >> /etc/fstab 
    fi 
}
