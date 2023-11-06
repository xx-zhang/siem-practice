# !/bin/bash 
# https://gitlab.freedesktop.org/pkg-config/pkg-config/
#  https://github.com/ofalk/libdnet/archive/refs/tags/libdnet-1.17.0.tar.gz


function default_deps(){




wget -c -N https://ftp.gnu.org/gnu/m4/m4-1.4.19.tar.gz --no-check-certificate
wget -c -N https://ftp.gnu.org/gnu/bison/bison-3.8.tar.gz --no-check-certificate

}



function instalL_openssl(){

./config && make -j$(nproc) && make install
}


function install_flex(){

./configure && make -j$(nproc) && make install
}

function install_zlib(){

./configure && make -j$(nproc) && make install
}

function install_luajit(){
    if [ -d ./luajit2-2.1-20230410]; then 
        wget -c -N https://github.com/openresty/luajit2/archive/refs/tags/v2.1-20230410.tar.gz
        tar xf v2.1-20230410.tar.gz
    fi 
    cd luajit2-2.1-20230410
    make PREFIX=/usr/local/luajit
    make install PREFIX=/usr/local/luajit
    export LUAJIT_LIB=/usr/local/luajit/lib
    export LUAJIT_INC=/usr/local/luajit/include/luajit-2.1
}


function install_cmake3(){

    
}
