ARG MARKDOWN_VERSION=latest-minimal
FROM witiko/markdown:$MARKDOWN_VERSION
RUN <<EOF
set -ex
# Install OS dependencies
apt -qy update
apt -qy install --no-install-recommends git pandoc python3 python3-pip retry tidy wget
# Configure Git to consider all directories safe
git config --system --add safe.directory '*'
EOF
# Copy the template
COPY . /opt/istqb_product_base
RUN <<EOF
set -ex
# Install TeX Live dependencies
retry -t 30 -d 60 tlmgr update --self --all
retry -t 30 -d 60 tlmgr install $(sort -u /opt/istqb_product_base/DEPENDS.txt)
tlmgr path add
# Update the library lua-tinyyaml to the latest version.
# As discussed in <https://github.com/istqborg/istqb_product_base/issues/172>.
wget https://github.com/api7/lua-tinyyaml/raw/refs/heads/master/tinyyaml.lua -O /usr/local/texlive/*/texmf-dist/scripts/lua-tinyyaml/tinyyaml.lua  # TODO: Remove me after <https://ctan.org/pkg/lua-tinyyaml> has been updated to version v0.4.4-1-g197632c.
EOF
RUN <<EOF
set -ex
# Install Python packages
pip install -r /opt/istqb_product_base/requirements.txt --break-system-packages
EOF
RUN <<EOF
set -ex
# Install LibreOffice
wget --inet4-only -O- http://downloadarchive.documentfoundation.org/libreoffice/old/7.3.7.2/deb/x86_64/LibreOffice_7.3.7.2_Linux_x86-64_deb.tar.gz | tar xzv
dpkg -iR LibreOffice_7.3.7.2_Linux_x86-64_deb/DEBS/
rm -rf LibreOffice_7.3.7.2_Linux_x86-64_deb
EOF
RUN <<EOF
set -ex
ln -s /usr/local/bin/libreoffice7.3 /usr/local/bin/libreoffice
EOF
# Install the script `istqb-template`
COPY <<EOF /usr/local/bin/istqb-template
#!/bin/bash
python3 /opt/istqb_product_base/template.py \"\$@\"
exit $?
EOF
RUN <<EOF
set -ex
chmod +x /usr/local/bin/istqb-template
EOF
RUN <<EOF
set -ex
# Validate and fixup the template
cd /opt/istqb_product_base
istqb-template validate-files all
istqb-template fixup-line-endings
istqb-template convert-eps-to-pdf
istqb-template convert-xlsx-to-pdf
EOF
ENTRYPOINT ["/usr/local/bin/istqb-template"]
