FROM debian:buster-slim

ENV pelican_version=4.2

RUN apt-get update && \
    apt-get install python-minimal \
    make \
    git \
    python-pip \
    python-setuptools \
    python-wheel \
    pelican \
    --no-install-recommends -y && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* && \
    apt-get clean
RUN pip install pelican=="${pelican_version}" markdown && \
    rm -rf /root/.cache

EXPOSE 8000

COPY pelican/ /opt/pelican/

CMD cd /opt/pelican/output && \
    python -m pelican.server
