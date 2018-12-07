#
# This container provides a 'jump box' for
# troubleshooting applications/services on Openshift
#

#FROM		debian:testing
FROM		ubuntu:18.04
MAINTAINER	Mike Hudgins <mchudgins@dstsystems.com> @mchudgins

LABEL io.k8s.description="An application troubleshooting jumpbox" \
      io.k8s.display-name="Jump Box" \
      io.openshift.tags="jumpbox"

ENV HOME /work
ENV ENV=$HOME/.shinit;
ENV USER jumper
ENV LOGNAME jumper
ENV PATH=$PATH:/usr/local/go/bin
ENV GOPATH=$HOME/go

RUN groupadd --gid 1001 jumper \
	&& useradd --uid 1001 --gid 1001 --home /work jumper \
	&& apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y --no-install-recommends ca-certificates curl dnsutils gettext git \
		htop jq libnss-wrapper mysql-client nano python silversearcher-ag tar unzip vim-tiny \
	&& apt-get clean \
	&& curl -s "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" \
	&& unzip awscli-bundle.zip \
	&& ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
	&& rm awscli-bundle.zip \
	&& rm -rf awscli-bundle \
	&& curl -L https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz -o oso.tar.gz \
	&& tar xvfz oso.tar.gz \
	&& mv openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/oc /usr/local/bin \
	&& rm -rf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit \
	&& mkdir /work \
	&& chmod ugo+rwx /work \
	&& rm oso.tar.gz \
	&& curl -sLo /tmp/go.tar.gz  https://dl.google.com/go/go1.11.2.linux-amd64.tar.gz \
	&& cd /usr/local && tar xvfz /tmp/go.tar.gz && rm /tmp/go.tar.gz \
	&& cp /etc/passwd /etc/nss-passwd && cp /etc/group /etc/nss-group

RUN git config --global alias.co checkout \
	&& git config --global alias.br branch \
	&& git config --global alias.ci commit \
	&& git config --global alias.co checkout \
	&& git config --global alias.st status \
	&& git config --global alias.stat status

RUN go get golang.org/x/tools/cmd/... && rm -rf ${GOPATH}/src/golang.org/x/tools

ADD setenv.sh /work/.shinit
COPY bashrc /work/.bashrc
COPY bash_aliases /work/.bash_aliases
RUN chmod -R ugo+rwx /work

COPY passwd.template /usr/local/etc/passwd.template
COPY group.template /usr/local/etc/group.template
COPY bash.bashrc /etc/bash.bashrc
COPY nss_wrapper.sh /etc/profile.d/nss_wrapper.sh

# USER only works in Docker, not in Openshift
USER 1001
ENV LD_PRELOAD libnss_wrapper.so

