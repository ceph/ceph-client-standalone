#
# Makefile for CEPH filesystem.
#

ifneq ($(KERNELRELEASE),)

obj-$(CONFIG_BLK_DEV_RBD) += rbd.o

else
#Otherwise we were called directly from the command
# line; invoke the kernel build system.

KERNELDIR ?= /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)

default: all

all:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) CONFIG_BLK_DEV_RBD=m modules

modules_install:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) CONFIG_BLK_DEV_RBD=m modules_install

clean:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) clean

endif
