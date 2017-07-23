LINUX_VER=4.11.11
LINUX_KPATH=arch/x86/boot/bzImage

src/linux/Makefile:
	mk/tarball linux https://www.kernel.org/pub/linux/kernel/v4.x/linux-$(LINUX_VER).tar.xz

include/linux/fcntl.h: src/linux/Makefile
	mkdir -p include
	make -j$(THREADS) -C src/linux ARCH="$(ARCH)" INSTALL_HDR_PATH="$(CURDIR)" headers_install

include/linux/%.h: include/linux/fcntl.h
	true

src/linux/.config:
	make -j$(THREADS) -C src/linux ARCH=$(ARCH) defconfig

src/linux/vmlinux: src/linux/.config src/linux/Makefile
	make -j$(THREADS) -C src/linux ARCH=$(ARCH) \
	        CROSS_COMPILE="$(CROSS_COMPILE)" \
	        CC="$(CC)" CFLAGS="$(CFLAGS)" \
	        KBUILD_BUILD_USER=root \
	        KBUILD_BUILD_HOST=tonic

boot/vmlinux: src/linux/$(LINUX_KPATH)
	mkdir -p boot
	cp src/linux/$(LINUX_KPATH) boot/vmlinux