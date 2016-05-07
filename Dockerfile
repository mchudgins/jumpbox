#
# This container provides a 'jump box' for
# troubleshooting applications/services on Openshift
#

FROM		debian:latest
MAINTAINER	Mike Hudgins <mchudgins@dstsystems.com> @mchudgins

LABEL io.k8s.description="An application troubleshooting jumpbox" \
      io.k8s.display-name="Jump Box" \
      io.openshift.tags="jumpbox"

RUN groupadd --gid 1001 jumper \
	&& useradd --uid 1001 --gid 1001 --home /work jumper \
	&& apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y --no-install-recommends ca-certificates curl dnsutils gettext git \
		mysql-client nano python tar unzip vim-tiny \
	&& apt-get clean \
	&& curl -s "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" \
	&& unzip awscli-bundle.zip \
	&& ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
	&& rm awscli-bundle.zip \
	&& rm -rf awscli-bundle \
	&& curl -L https://github.com/openshift/origin/releases/download/v1.1.4/openshift-origin-client-tools-v1.1.4-3941102-linux-64bit.tar.gz -o oso.tar.gz \
	&& tar xvfz oso.tar.gz \
	&& mv openshift-origin-client-tools-v1.1.4-3941102-linux-64bit/oc /usr/local/bin \
	&& rm -rf openshift-origin-client-tools-v1.1.4-3941102-linux-64bit \
	&& mkdir /work \
	&& chmod ugo+rwx /work \
	&& rm oso.tar.gz


ENV HOME /work

ADD setenv.sh /work/setenv.sh
RUN chmod -R ugo+rwx /work

COPY bashrc /work/.bashrc
COPY bash_aliases /work/.bash_aliases

USER 1001

