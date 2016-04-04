#
# This container provides a 'jump box' for
# troubleshooting applications/services on Openshift
#

FROM		debian:latest
MAINTAINER	Mike Hudgins <mchudgins@dstsystems.com> @mchudgins

ENV OPENSHIFT_DOWNLOAD https://github.com/openshift/origin/releases/download/v${OPENSHIFT_VERSION}/openshift-origin-client-tools-v${OPENSHIFT_VERSION}-3941102-linux-64bit.tar.gz

LABEL io.k8s.description="Platform for building an application troubleshooting jumpbox" \
      io.k8s.display-name="Jump Box" \
      io.openshift.tags="jumpbox"

RUN groupadd --gid 1001 jumper \
	&& useradd --uid 1001 --gid 1001 --home /work jumper \
	&& apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y --no-install-recommends ca-certificates curl dnsutils gettext git nano \
		openssh-client python tar unzip \
	&& apt-get clean \
	&& curl -s "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" \
	&& unzip awscli-bundle.zip \
	&& ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
	&& rm awscli-bundle.zip \
	&& rm -rf awscli-bundle \
	&& curl -L ${OPENSHIFT_DOWNLOAD} -o oso.tar.gz \
	&& tar xvfz oso.tar.gz \
	&& mv openshift-origin-client-tools-v${OPENSHIFT_VERSION}-3941102-linux-64bit/oc /usr/local/bin \
	&& rm -rf openshift-origin-client-tools-v1.1.4-3941102-linux-64bit \
	&& mkdir /work \
	&& chmod ugo+rwx /work \
	&& rm oso.tar.gz


USER 1001

ENV HOME /work

ADD setenv.sh /work/setenv.sh
