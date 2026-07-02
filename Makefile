OPENRSDK_ROOT ?= $(CURDIR)/local/OPEN_R_SDK
BUILD_DIR ?= $(CURDIR)/build

HELLOWORLD_DIR := samples/common/HelloWorld
HELLOWORLD_INSTALL_DIR := samples/common/HelloWorld
TINYFTPD_DIR := samples/common/TinyFTPD
TINYFTPD_INSTALL_DIR := samples/common/TinyFTPD
SAMPLES_DIR := samples
ERS7_WCONSOLE_VARIANT ?= memprot
ERS7_WCONSOLE_BASE := $(OPENRSDK_ROOT)/OPEN_R/MS_ERS7/WCONSOLE/$(ERS7_WCONSOLE_VARIANT)/OPEN-R
ERS7_WCONSOLE_BUILD := $(BUILD_DIR)/ers7-wconsole-hello-world/OPEN-R
ERS7_WCONSOLE_TINYFTPD_BUILD := $(BUILD_DIR)/ers7-wconsole-tinyftpd/OPEN-R

.PHONY: help doctor hello-world hello-world-install tinyftpd-install ers7-wconsole-hello-world ers7-wconsole-tinyftpd common-samples all-samples clean

help:
	@printf '%s\n' \
		'Targets:' \
		'  make doctor             Check that the bundled OPEN-R SDK toolchain exists' \
		'  make hello-world        Build the HelloWorld sample set' \
		'  make hello-world-install Build and package HelloWorld into samples/common/HelloWorld/MS' \
		'  make tinyftpd-install   Build and package TinyFTPD into samples/common/TinyFTPD/MS' \
		'  make ers7-wconsole-hello-world Stage an ERS-7 WCONSOLE Memory Stick tree in build/' \
		'  make ers7-wconsole-tinyftpd Stage an ERS-7 WCONSOLE+TinyFTPD tree in build/' \
		'  make common-samples     Build the common sample set' \
		'  make all-samples        Build all sample sets'

doctor:
	test -x "$(OPENRSDK_ROOT)/bin/mipsel-linux-g++"
	test -f "$(OPENRSDK_ROOT)/OPEN_R/bin/mkbin"
	test -f "$(OPENRSDK_ROOT)/OPEN_R/bin/stubgen2"
	@printf 'OPENRSDK_ROOT=%s\n' "$(OPENRSDK_ROOT)"
	@"$(OPENRSDK_ROOT)/bin/mipsel-linux-gcc" -v 2>&1 | tail -n 1

hello-world:
	$(MAKE) -C $(HELLOWORLD_DIR) OPENRSDK_ROOT="$(OPENRSDK_ROOT)"

hello-world-install:
	$(MAKE) -C $(HELLOWORLD_INSTALL_DIR) OPENRSDK_ROOT="$(OPENRSDK_ROOT)" install

tinyftpd-install:
	$(MAKE) -C $(TINYFTPD_INSTALL_DIR) OPENRSDK_ROOT="$(OPENRSDK_ROOT)" install

ers7-wconsole-hello-world: hello-world-install
	test -d "$(ERS7_WCONSOLE_BASE)"
	rm -rf "$(BUILD_DIR)/ers7-wconsole-hello-world"
	mkdir -p "$(BUILD_DIR)/ers7-wconsole-hello-world"
	cp -a "$(ERS7_WCONSOLE_BASE)" "$(ERS7_WCONSOLE_BUILD)"
	chmod -R u+w "$(ERS7_WCONSOLE_BUILD)"
	cp -a "$(HELLOWORLD_INSTALL_DIR)/MS/OPEN-R/." "$(ERS7_WCONSOLE_BUILD)/"
	cp -f "$(ERS7_WCONSOLE_BUILD)/SYSTEM/CONF/WLANDFLT.TXT" "$(ERS7_WCONSOLE_BUILD)/SYSTEM/CONF/WLANCONF.TXT"
	@printf 'Staged ERS-7 WCONSOLE tree at %s\n' "$(ERS7_WCONSOLE_BUILD)"

ers7-wconsole-tinyftpd: tinyftpd-install
	test -d "$(ERS7_WCONSOLE_BASE)"
	rm -rf "$(BUILD_DIR)/ers7-wconsole-tinyftpd"
	mkdir -p "$(BUILD_DIR)/ers7-wconsole-tinyftpd"
	cp -a "$(ERS7_WCONSOLE_BASE)" "$(ERS7_WCONSOLE_TINYFTPD_BUILD)"
	chmod -R u+w "$(ERS7_WCONSOLE_TINYFTPD_BUILD)"
	cp -a "$(TINYFTPD_INSTALL_DIR)/MS/OPEN-R/." "$(ERS7_WCONSOLE_TINYFTPD_BUILD)/"
	cp -f "$(ERS7_WCONSOLE_TINYFTPD_BUILD)/SYSTEM/CONF/WLANDFLT.TXT" "$(ERS7_WCONSOLE_TINYFTPD_BUILD)/SYSTEM/CONF/WLANCONF.TXT"
	@printf 'Staged ERS-7 WCONSOLE TinyFTPD tree at %s\n' "$(ERS7_WCONSOLE_TINYFTPD_BUILD)"

common-samples:
	$(MAKE) -C samples/common OPENRSDK_ROOT="$(OPENRSDK_ROOT)"

all-samples:
	$(MAKE) -C $(SAMPLES_DIR) OPENRSDK_ROOT="$(OPENRSDK_ROOT)"

clean:
	$(MAKE) -C $(HELLOWORLD_DIR) OPENRSDK_ROOT="$(OPENRSDK_ROOT)" clean
