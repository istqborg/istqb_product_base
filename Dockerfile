FROM witiko/markdown:latest-minimal
RUN <<EOF
# Install Git, Pandoc, Python, and Tidy
set -ex
apt -qy update
apt -qy install --no-install-recommends git pandoc python3 python3-pip tidy
EOF
COPY requirements.txt /requirements.txt
RUN <<EOF
# Install Python packages
pip install -U pip wheel setuptools
pip install -r /requirements.txt --break-system-packages
EOF
RUN <<EOF
# Install LibreOffice
wget -O- http://downloadarchive.documentfoundation.org/libreoffice/old/7.3.7.2/deb/x86_64/LibreOffice_7.3.7.2_Linux_x86-64_deb.tar.gz | tar xzv
dpkg -iR LibreOffice_7.3.7.2_Linux_x86-64_deb/DEBS/
rm -rf LibreOffice_7.3.7.2_Linux_x86-64_deb
EOF
