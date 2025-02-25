#!/bin/bash

git clone https://github.com/YL2209/luci-app-campus-network-login.git package/luci-app-campus-network-login
./scripts/feeds install luci-app-campus-network-login
echo "CONFIG_ALL_NONSHARED=n" > .config
echo "CONFIG_ALL_KMODS=n" >> .config
echo "CONFIG_ALL=n" >> .config
echo "CONFIG_AUTOREMOVE=n" >> .config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> .config
echo "CONFIG_PACKAGE_luci-app-campus-network-login=m" >> .config