CONFIG_MODULE_SIG   = y
PWD                ?= $(shell pwd)
KERNEL_SRC         ?= /lib/modules/`uname -r`/build
KVER               ?= $(shell uname -r)
INCLUDE_DIR        ?= $(PWD)/include
CFILES             := main.c emuc_parse.c transceive.c
TARGET             := emuc2socketcan
OUTPUT             := output
ifneq ($(KERNELRELEASE),)
	KERNEL := /lib/modules/$(KERNELRELEASE)/build
else
	## KERNELRELEASE not set.
	KERNEL := /lib/modules/$(KVER)/build
endif
obj-m              += $(TARGET).o
$(TARGET)-objs     := $(CFILES:.c=.o)

ccflags-m          := -I$(INCLUDE_DIR) -std=gnu99 -Wno-declaration-after-statement
ccflags-m          += -D_DBG_FUNC=0 -D_DBG_RECV_HEX=0 -D_DBG_BUMP=0

ccflags-y          := ${ccflags-m}

modules:
	$(MAKE) -C$(KERNEL_SRC) M=$(PWD) modules
	mkdir -p $(OUTPUT)
	cp $(PWD)/$(TARGET).ko $(OUTPUT)

install:
	$(MAKE) -C $(KERNEL_SRC) M=$(PWD) modules_install
	depmod -a

clean:
	$(MAKE) -C$(KERNEL_SRC) M=$(PWD) clean
	$(RM) -rf $(OUTPUT)
