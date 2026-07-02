OPENRSDK_ROOT ?= $(CURDIR)/local/OPEN_R_SDK

HELLOWORLD_DIR := samples/common/HelloWorld
HELLOWORLD_INSTALL_DIR := samples/common/HelloWorld
SAMPLES_DIR := samples

.PHONY: help doctor hello-world hello-world-install common-samples all-samples clean

help:
	@printf '%s\n' \
		'Targets:' \
		'  make doctor             Check that the bundled OPEN-R SDK toolchain exists' \
		'  make hello-world        Build the HelloWorld sample set' \
		'  make hello-world-install Build and package HelloWorld into samples/common/HelloWorld/MS' \
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

common-samples:
	$(MAKE) -C samples/common OPENRSDK_ROOT="$(OPENRSDK_ROOT)"

all-samples:
	$(MAKE) -C $(SAMPLES_DIR) OPENRSDK_ROOT="$(OPENRSDK_ROOT)"

clean:
	$(MAKE) -C $(HELLOWORLD_DIR) OPENRSDK_ROOT="$(OPENRSDK_ROOT)" clean
