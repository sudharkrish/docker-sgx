FROM tozd/runit:ubuntu-trusty

COPY ./patches /patches

ENV http_proxy 'http://10.7.211.16:911'
ENV https_proxy 'https://10.7.211.16:911'

RUN apt-get update -q -q && \
 apt-get install wget python git patch build-essential ocaml automake autoconf libtool libcurl4-openssl-dev protobuf-compiler protobuf-c-compiler libprotobuf-dev libprotobuf-c0-dev --yes --force-yes && \
 cd /tmp && \
 git clone https://github.com/01org/linux-sgx.git && \
 cd linux-sgx && \
 git reset --hard 171c04e0a2d079e75580018f891dd32562963cc4 && \
 cd ../ && \
 cd / && \
 for patch in /patches/*; do patch --prefix=/patches/ -p0 --force "--input=$patch" || exit 1; done && \
 rm -rf /patches && \
 cd /tmp/linux-sgx && \
 ./download_prebuilt.sh && \
 make && \
 make sdk_install_pkg && \
 make psw_install_pkg && \
 mkdir -p /opt/intel && \
 cd /opt/intel && \
 yes yes | /tmp/linux-sgx/linux/installer/bin/sgx_linux_x64_sdk_*.bin && \
 /tmp/linux-sgx/linux/installer/bin/sgx_linux_x64_psw_*.bin && \
 rm -rf /tmp/linux-sgx

COPY ./etc /etc
