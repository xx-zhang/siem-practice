#!/bin/bash
# This script is to complie nginx
# Build by zt 20190603
# Changelog
# Build by zt to compile nginx 2019
# [Re] reBuild by zxx 20200914
# 20201115:[ngx-modsecurity](https://github.com/SpiderLabs/ModSecurity/issues/2237)
# 20210629:modify nginx version to 1.21.0 and dump deps to local path
# 20220917: update modsecurity 3.0.8
RELEASE_SITE_DIR="https://raw.githubusercontent.com/xx-zhang/devops-pkgs/pkgs/ngx-deps/"

if [ ! $RELEASE_SITE_DIR ]; then
  # RELEASE_SITE_DIR=`echo 'ZnRwOi8vY2VzaGk6VGFsZW50MTIzQDEwLjcuMjE3LjE2NC/lpKfmlbDmja7kuqflk4HmioDmnK/kuK3lv4MvMTct5bi455So5LiJ5pa55YyFL25neC1kZXBzCg==' | base64 -d`
  # RELEASE_SITE_DIR=`echo 'ZnRwOi8vY2VzaGk6VGFsZW50MTIzQDEwLjcuMjE3LjE2NC/lpKfmlbDmja7kuqflk4HmioDmnK/kuK3lv4MvMTct5bi455So5LiJ5pa55YyFL25neC1kZXBzCg==' | base64 -d`
  # RELEASE_SITE_DIR="https://10.7.202.199/filestore/ngx-deps"
  #RELEASE_SITE_DIR=${RELEASE_SITE_DIR:-"https://10.11.6.26/nexus/repository/filestore-v2/tech/ngx-deps/"}
  RELEASE_SITE_DIR=${RELEASE_SITE_DIR:-"https://10.11.6.26/nexus/repository/filestore-v2/tech/ngx-deps/"}
fi

# TODO render gcc to gcc7
#if [ -f /opt/rh/devtoolset-7/root/bin/gcc ]; then
#  export CC=/opt/rh/devtoolset-7/root/bin/gcc
#fi

if cat /etc/*-release | grep -Eq 'CentOS'; then
  yum -y install centos-release-scl
  yum -y install devtoolset-7
  export CC=/opt/rh/devtoolset-7/root/bin/gcc
fi


function error_exit
{
  echo -e "\033[41;30m [ERROR]"$1"\033[0m" 1>&2
  exit 0
}

function say_ok
{
  echo -e "\033[44m[SUCESS]"$1"\033[0m"
}

function notice
{
  echo -e "\033[43m[WARNING]"$1"\033[0m"
}

# shellcheck disable=SC1073
if [ -z $1 ]; then
   curdir=$(cd $(dirname $0); pwd)
else
   curdir=$1
fi

# TODO 方便其他脚本能够寻找到准确的路径
if [ -d /workdir ]; then
  rm -rf /workdir;
fi
ln -sf ${curdir} /workdir
# TODO ########################

#openssl_version=1.1.1q
openssl_prefix="openssl"
openssl_version=1.1.1v
pcre_version=8.44
zlib_version=1.2.11
luajit2_version=2.1-20210510

modsecurity_version=3.0.5
modsecurity_nginx_version=1.0.3
nginxver=1.24.0

NGINX_ALIAS_NAME=${NGINX_ALIAS_NAME:-nginx}
#NGINX_ALIAS_NAME=${NGINX_ALIAS_NAME:-tengine}

# shellcheck disable=SC1046
if [ ! -d ${curdir}/builds ]; then
  mkdir -p ${curdir}/builds ;
fi

if [ ! -d ${curdir}/compile ]; then
  mkdir -p ${curdir}/compile ;
fi

if [ ! -d ${curdir}/plugins ]; then
  mkdir -p ${curdir}/plugins ;
fi

if [ ! -f ${curdir}/DEP ]; then
  cat << EOF > ${curdir}/DEP
nginx-${nginxver}.tar.gz
nginx-goodies-nginx-sticky-module-ng-08a395c66e42.tar.gz
nginx-http-flv-module-1.2.9.tar.gz
${openssl_prefix}-${openssl_version}.tar.gz
pcre-${pcre_version}.tar.gz
zlib-${zlib_version}.tar.gz
ssdeep-2.14.1.tar.gz
modsecurity-v${modsecurity_version}.tar.gz
modsecurity-nginx-v${modsecurity_nginx_version}.tar.gz
ngx_devel_kit-0.3.1.tar.gz
nginx-upload-module-2.3.0.tar.gz
lua-nginx-module-0.10.25.tar.gz
luajit2-${luajit2_version}.tar.gz
ngx-fancyindex-0.5.1.tar.gz
njs-0.7.5.tar.gz
nginx-dav-ext-module-3.0.0.tar.gz
EOF

fi


yum -yqq install wget patch which;


if [ ! -d ${curdir}/deps ]; then
  mkdir ${curdir}/deps && cd ${curdir}/deps && \
  for x in $(cat ${curdir}/DEP); do wget -c -N  --no-check-certificate  ${RELEASE_SITE_DIR}/$x;  done
fi

# centos7
#yum -y install epel-release

yum -yqq install wget automake autoconf libtool
yum install gcc make gcc-c++ \
  libxml2 libxml2-devel \
  libxslt libxslt-devel \
  flex bison \
  yajl yajl-devel \
  geoip geoip-devel \
  gd gd-devel \
  curl-devel curl \
  zlib-devel \
  pcre-devel perl-ExtUtils-Embed \
  lmdb lmdb-devel \
  doxygen -yqq


cd ${curdir}/builds
tar xf ${curdir}/deps/${:wq

：:}-${openssl_version}.tar.gz && \
mv ${openssl_prefix}-* ${curdir}/compile/openssl
#cd ${curdir}/compile/openssl && ./config && make -j2
say_ok "Installed ${openssl_prefix}"


cd ${curdir}/builds
tar xf ${curdir}/deps/pcre-${pcre_version}.tar.gz && \
  mv `find . -type d -name 'pcre-*'` ${curdir}/compile/pcre
say_ok "Installed pcre"


cd ${curdir}/builds
tar xf ${curdir}/deps/zlib-${zlib_version}.tar.gz && \
mv  `find . -type d -name 'zlib-*'` ${curdir}/compile/zlib
say_ok "Installed zlib"


cd ${curdir}/builds
tar -xzvf ${curdir}/deps/luajit2-${luajit2_version}.tar.gz && cd luajit2-${luajit2_version}
make PREFIX=${curdir}/compile/luajit
make install PREFIX=${curdir}/compile/luajit
say_ok "installed luajit"

# TODO 编译modsecurity需要增加的内容
cd ${curdir}/builds
tar -xzvf ${curdir}/deps/ssdeep-2.14.1.tar.gz && cd ssdeep-2.14.1
./configure && make && make install
say_ok "installed ssdeep"

######## NGINX MODSECURY #############
cd ${curdir}/builds
tar xf ${curdir}/deps/modsecurity-v${modsecurity_version}.tar.gz  && \
   cd modsecurity-v${modsecurity_version} && \
   ./configure &&  make -j2 && make install
say_ok "Install modsecurity ok"

cd ${curdir}/builds
tar xf ${curdir}/deps/modsecurity-nginx-v${modsecurity_nginx_version}.tar.gz && \
  mv  $(find .  -type d  | grep  modsecurity-nginx- | head -n 1) ${curdir}/plugins/modsecurity-nginx
say_ok "Install modsecurity-nginx ok"
###########################################

libsodium_install (){
  git clone https://github.com/jedisct1/libsodium.git --branch stable libsodium-src && \
  cd libsodium-src \
        &&  ./configure --prefix=/data/workdir/nginx-demo/nginx-1.24.0/libsodium --with-pic \
        &&  make -j$(nproc) && make check -j $(nproc) && make install
}

# shellcheck disable=SC1073
if [ -z $1 ]; then
   curdir=$(cd $(dirname $0); pwd)
else
   curdir=$1
fi
# uthash
# export LIB_UTHASH=/www/server/nginx/src/uthash
########## install ngx_waf
# install ngx-waf to plugins 
ngx_waf_install() {
    git clone -b current https://github.com/xx-zhang/ngx_waf ${curdir}/plugins/ngx_waf
    cd ${curdir}/plugins/ngx_waf && \
    git clone -b v1.7.15 https://github.com/DaveGamble/cJSON.git lib/cjson
    git clone -b v2.3.0 https://github.com/troydhanson/uthash.git lib/uthash

}

ngx_waf_install
##########


cd ${curdir}/deps

for module in 'nginx-http-flv-module' \
              'nginx-goodies-nginx-sticky-module-ng' \
              'ngx-fancyindex' \
              'nginx-dav-ext-module' \
              'njs' \
              'lua-nginx-module' \
              'nginx-upload-module' \
              'ngx_devel_kit' \
              ; do
  tar xf `find . -maxdepth 1 -type f | grep $module`
  mv  $(find . -maxdepth 1 -type d  | grep ${module} | head -n 1)  ${curdir}/plugins/$module ;
  say_ok "DUMP ${module} OK!"
done

cd $curdir &&  tar xf ${curdir}/deps/nginx-${nginxver}.tar.gz -C .

# clear old version
rm -rf ${curdir}/nginx || echo '[X] local not exist nginx.'
echo ${curdir}

#nginxdir=$(ls -F | grep '/$' | grep nginx-)
nginxdir=${curdir}/nginx-${nginxver}
echo ${nginxdir}
cd ${nginxdir}

# TODO unshowing nginx version
cur_date=$(echo `date +%Y%m%d`) && \
sed -i 's/#define NGINX_VERSION      "'${nginxver}'"/#define NGINX_VERSION      "v'${cur_date}'"/' src/core/nginx.h
sed -i 's/#define TENGINE_VERSION      "'${nginxver}'"/#define TENGINE_VERSION      "v'${cur_date}'"/' src/core/nginx.h
sed -i 's/"nginx\/"/"WS\/"/' src/core/nginx.h
sed -i 's/"tengine\/"/"WebSrv\/"/' src/core/nginx.h
sed -i 's/"Server: nginx"/"Server: WS"/' src/http/ngx_http_header_filter_module.c
sed -i 's#"<hr><center>" NGINX_VER "</center>" CRLF#"<hr><center>" NGINX_VERSION "</center>" CRLF#' src/http/ngx_http_special_response.c

say_ok "unshowing nginx version"
# 2021/12/12
#wget -c -N https://code.aliyun.com/ngx-plus/ngx-deps/raw/master/ngx-patch/ngx-worker-patch
#patch -p1 < ngx-worker-patch
#say_ok "增加worker补丁适配TopODP的监控"

#make clean
# TODO 切记这里要执行，如果没有执行那么就手动执行。
export LUAJIT_LIB=${curdir}/compile/luajit/lib
export LUAJIT_INC=${curdir}/compile/luajit/include/luajit-2.1
export LIB_MODSECURITY=/usr/local/modsecurity
export LIB_SODIUM=${curdir}/nginx-${nginxver}/libsodium 

chmod u+x ./configure

./configure \
	--prefix=../nginx \
	--sbin-path=../nginx/sbin/nginx \
	--conf-path=../nginx/conf/nginx.conf \
	--modules-path=../nginx/modules  \
	--with-openssl=../compile/openssl \
	--with-openssl-opt='--strict-warnings' \
	--with-pcre=../compile/pcre \
	--with-zlib=../compile/zlib \
	--with-http_ssl_module \
	--with-http_realip_module \
	--with-http_addition_module \
	--with-http_sub_module \
	--with-http_dav_module \
	--with-http_flv_module \
	--with-http_mp4_module \
	--with-http_gunzip_module \
	--with-http_gzip_static_module \
	--with-http_random_index_module \
	--with-http_secure_link_module \
	--with-http_stub_status_module \
	--with-http_auth_request_module \
	--with-http_xslt_module=dynamic \
	--with-http_image_filter_module=dynamic \
	--with-http_geoip_module=dynamic \
	--with-http_perl_module=dynamic \
	--with-threads \
	--with-stream=dynamic \
	--with-stream_ssl_module \
	--with-stream_ssl_preread_module \
	--with-stream_realip_module \
	--with-stream_geoip_module=dynamic \
	--with-http_slice_module \
	--with-mail=dynamic \
	--with-mail_ssl_module \
	--with-file-aio \
	--with-http_v2_module \
  --with-http_dav_module \
  --add-module=../plugins/lua-nginx-module \
  --add-module=../plugins/nginx-upload-module \
  --add-module=../plugins/ngx_devel_kit \
  --with-debug \
  --with-cc-opt='-O3 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic' \
  --with-ld-opt=-Wl,-rpath,../compile/luajit/lib \
  --with-pcre-jit \
  --with-compat --add-dynamic-module=../plugins/modsecurity-nginx/\
  --add-module=../plugins/ngx_waf

# TODO 2023-08-11 

 make -j2
 make install
 say_ok "Build Nginx OK."

# # TODO collect libs
# mkdir -p ${curdir}/${NGINX_ALIAS_NAME}/lib64
cd ${curdir}/${NGINX_ALIAS_NAME}/lib64
cp /usr/local/modsecurity/lib/libmodsecurity.so.3.* . || echo "N"
cp /usr/lib64/libfuzzy.so.2.* . || echo "N"
cp /usr/lib64/libyajl.so.2.* . || echo "N"
cp /usr/lib64/libGeoIP.so.1.*  . || echo "N"
cp /usr/local/lib/libfuzzy.so.2.* . || echo "N"
cp /usr/lib64/liblmdb.so.0.* . || echo "N"
cp /usr/lib64/libxslt.so.1.* . || echo "N"
cp /usr/lib64/libexslt.so.0.* . || echo "N"
cp /usr/lib64/liblmdb.so.0.* . || echo "N"
cp /usr/lib64/libgcrypt.so.11.* . || echo "N"
cp ${curdir}/compile/luajit/lib/libluajit-5.1.so.2.1.0  .  || echo "N"

# # TODO 更新本地目录
# function override_ngx_conf(){
#   rm -rf ${curdir}/${NGINX_ALIAS_NAME}/html
#   rm -rf ${curdir}/${NGINX_ALIAS_NAME}/conf
#   cp -r ${curdir}/resty ${curdir}/${NGINX_ALIAS_NAME}
#   cp -r ${curdir}/html ${curdir}/${NGINX_ALIAS_NAME}
#   cp -r ${curdir}/conf ${curdir}/${NGINX_ALIAS_NAME}
#   cp ./nginx.sh ${curdir}/${NGINX_ALIAS_NAME}
#   chmod +x ./nginx.sh
# }

# override_ngx_conf || echo "Local Modify ERROR"

# ls -alh .

# # TODO mv to artifact dir
# ARTIFACT_REPO_DIR=${ARTIFACT_REPO_DIR:-/workir/release/}
# if [ ! -d "${ARTIFACT_REPO_DIR}" ]; then
#   mkdir -p "${ARTIFACT_REPO_DIR}";
# fi

# cd $curdir
# tar czf nginx-bin.tar.gz "${NGINX_ALIAS_NAME}"
# mv nginx-bin.tar.gz "${ARTIFACT_REPO_DIR}"/nginx-bin.$(date +%Y%m%d.%H%m).tar.gz
# # patchelf --set-rpath lib64/ ./sbin/nginx
# # patchelf --set-rpath lib64/ ./modules/*
