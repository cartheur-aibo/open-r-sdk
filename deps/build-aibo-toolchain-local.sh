#!/bin/sh

set -eu

# ***************************
# ****** CONFIGURATION ****** 
# ***************************

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
PREFIX=${PREFIX:-"$REPO_ROOT/local/rebuilt_OPEN_R_SDK"}
TARGET=mipsel-linux

BINUTILS=binutils-2.15
GCC=gcc-3.3.6
NEWLIB=newlib-1.15.0
OPENRSDK=OPEN_R_SDK-1.1.5-r5

BUILDDIR=bld-
export CFLAGS="${CFLAGS:--O2 -std=gnu89 -traditional-cpp}"
OPENRSDK_SOURCE_DIR=${OPENRSDK_SOURCE_DIR:-"$REPO_ROOT/local/OPEN_R_SDK"}
MAKE_COMPAT_FLAGS="MAKEINFO=true"

ensure_libc_dash() {
	if [ ! -f "$PREFIX/$TARGET/lib/libc.a" ]; then
		echo "Missing $PREFIX/$TARGET/lib/libc.a, cannot prepare libc-.a."
		exit 1
	fi

	echo "Preparing libc-.a compatibility archive..."
	rm -f "$PREFIX/$TARGET/lib/libc-.a" || exit 1
	cp "$PREFIX/$TARGET/lib/libc.a" "$PREFIX/$TARGET/lib/libc-.a" || exit 1
	"$PREFIX/bin/$TARGET-ar" d "$PREFIX/$TARGET/lib/libc-.a" \
		mallocr.o freer.o reallocr.o callocr.o cfreer.o malignr.o \
		vallocr.o pvallocr.o mallinfor.o mallstatsr.o msizer.o malloptr.o \
		calloc.o malign.o msize.o mstats.o mtrim.o realloc.o valloc.o malloc.o \
		abort.o sbrkr.o exit.o rename.o || exit 1
	"$PREFIX/bin/$TARGET-ranlib" "$PREFIX/$TARGET/lib/libc-.a" || exit 1
}


# *******************
# ****** SETUP ******
# ******************* 

PACKAGES="$BINUTILS $GCC $NEWLIB"

cd "$SCRIPT_DIR"

# Check packages, if they haven't been de-archived, do it
for p in $PACKAGES; do
	if [ ! -d "$p" ]; then
		if [ -f "$p.tar.gz" ]; then
			echo "Extracting $p.tar.gz"
			tar -xzf "$p.tar.gz" || exit 1;
		elif [ -f "$p.tgz" ]; then
			echo "Extracting $p.tgz"
			tar -xzf "$p.tgz" || exit 1;
		
		elif [ -f "$p.tar.bz2" ]; then
			echo "Extracting $p.tar.bz2"
			tar -xjf "$p.tar.bz2" || exit 1;
		elif [ -f "$p.tbz" ]; then
			echo "Extracting $p.tbz"
			tar -xjf "$p.tbz" || exit 1;
		
		elif [ -f "$p.tar" ]; then
			echo "Extracting $p.tar"
			tar -xf "$p.tar" || exit 1;
		
		else
			echo "Missing package $p in the current directory, cannot continue."
			exit 1;
		fi;
	fi;
done;

# check we can write to the destination directory
if mkdir -p "$PREFIX/tmp$$" > /dev/null 2>&1 ; then
	rmdir "$PREFIX/tmp$$";
else
	echo "Cannot write to destination directory $PREFIX, need to run as root/sudo?"
	exit 1;
fi;

# *********************
# ****** PATCHES ******
# ********************* 

# Make libstdc++-v3 use newlib, adjust version_string to advertise our
# modifications, and make strsignal non-const to match expected signature
if [ ! -e "$GCC/.patched" ] ; then
patch -N -p0 <<'EOF' || exit 1
diff -ru gcc-3.3.6/libstdc++-v3/configure gcc-3.3.6-patched/libstdc++-v3/configure
--- gcc-3.3.6/libstdc++-v3/configure.orig	2003-09-11 12:08:35.000000000 +0900
+++ gcc-3.3.6/libstdc++-v3/configure	2003-11-18 15:12:29.552891100 +0900
@@ -4213,7 +4213,8 @@
   # GLIBCPP_CHECK_MATH_SUPPORT
 
   case "$target" in
-    *-linux*)
+#    *-linux*)
+    *-linux-nevermatch*)
       os_include_dir="os/gnu-linux"
       for ac_hdr in nan.h ieeefp.h endian.h sys/isa_defs.h \
         machine/endian.h machine/param.h sys/machine.h sys/types.h \
diff -ur gcc-3.3.6/gcc/version.c gcc-3.3.6-patched/gcc/version.c
--- gcc-3.3.6/gcc/version.c	2005-09-21 04:58:56.000000000 +0100
+++ gcc-3.3.6-patched/gcc/version.c	2005-12-12 22:10:36.000000000 +0000
@@ -5,7 +5,7 @@
    please modify this string to indicate that, e.g. by putting your
    organization's name in parentheses at the end of the string.  */
 
-const char version_string[] = "3.3.6";
+const char version_string[] = "3.3.6 (AIBO special edition)";
 
 /* This is the location of the online document giving instructions for
    reporting bugs.  If you distribute a modified version of GCC,
diff -ru gcc-3.3.6/libiberty/strsignal.c.old gcc-3.3.6/libiberty/strsignal.c
--- gcc-3.3.6/libiberty/strsignal.c.old	2001-10-17 22:15:41.000000000 +0100
+++ gcc-3.3.6/libiberty/strsignal.c	2005-12-20 20:14:49.000000000 +0000
@@ -409,7 +409,7 @@

 #ifndef HAVE_STRSIGNAL

-const char *
+char *
 strsignal (signo)
   int signo;
 {
EOF
touch "$GCC/.patched"
fi;

if [ ! -e "$NEWLIB/.patched" ] ; then
# AIBO's file system requires a larger BUFSIZ in newlib's stdio.h
# also, reduce vfprintf's stack size, newlib support (?), don't allow negative ctype index
patch -p0 <<'EOF' || exit
diff -ru newlib-1.15.0/newlib/libc/include/stdio.h newlib-1.15.0-patched/newlib/libc/include/stdio.h
--- newlib-1.15.0/newlib/libc/include/stdio.h	2004-11-23 19:45:40.000000000 -0500
+++ newlib-1.15.0-patched/newlib/libc/include/stdio.h	2005-09-11 03:22:28.000000000 -0400
@@ -106,7 +106,7 @@
 #ifdef __BUFSIZ__
 #define	BUFSIZ		__BUFSIZ__
 #else
-#define	BUFSIZ		1024
+#define	BUFSIZ		16384
 #endif
 
 #ifdef __FOPEN_MAX__
diff -ru newlib-1.15.0/newlib/libc/stdio/vfprintf.c newlib-1.15.0-patched/newlib/libc/stdio/vfprintf.c
--- newlib-1.15.0/newlib/libc/stdio/vfprintf.c	2004-06-11 16:37:10.000000000 -0400
+++ newlib-1.15.0-patched/newlib/libc/stdio/vfprintf.c	2005-09-11 03:22:28.000000000 -0400
@@ -543,11 +543,14 @@
 	}
 
 	/* optimise fprintf(stderr) (and other unbuffered Unix files) */
+/* comment out: __sbprintf requires too large stack size (> BUFSIZ) */
+#if 0
 	if ((fp->_flags & (__SNBF|__SWR|__SRW)) == (__SNBF|__SWR) &&
 	    fp->_file >= 0) {
 		_funlockfile (fp);
 		return (__sbprintf (data, fp, fmt0, ap));
 	}
+#endif
 
 	fmt = (char *)fmt0;
 	uio.uio_iov = iovp = iov;
diff -ru newlib-1.15.0/configure newlib-1.15.0-patched/configure
--- newlib-1.15.0/configure	2004-12-16 14:51:28.000000000 -0500
+++ newlib-1.15.0-patched/configure	2005-09-11 03:34:59.000000000 -0400
@@ -1505,7 +1505,7 @@
     noconfigdirs="$noconfigdirs target-newlib ${libgcj}"
     ;;
   mips*-*-linux*)
-    noconfigdirs="$noconfigdirs target-newlib target-libgloss"
+#    noconfigdirs="$noconfigdirs target-newlib target-libgloss"
     ;;
   mips*-*-*)
     noconfigdirs="$noconfigdirs gprof ${libgcj}"
diff -ru newlib-1.15.0/newlib/libc/ctype/ctype_.c newlib-1.15.0-patched/newlib/libc/ctype/ctype_.c
--- newlib-1.15.0/newlib/libc/ctype/ctype_.c	2003-05-13 05:46:47.000000000 -0400
+++ newlib-1.15.0-patched/newlib/libc/ctype/ctype_.c	2005-09-11 04:13:36.000000000 -0400
@@ -77,7 +77,7 @@
 #define ALLOW_NEGATIVE_CTYPE_INDEX
 #endif
 
-#if defined(ALLOW_NEGATIVE_CTYPE_INDEX)
+#if 0
 static _CONST char _ctype_b[128 + 256] = {
 	_CTYPE_DATA_128_256,
 	_CTYPE_DATA_0_127,
diff -ru newlib-1.15.0/libgloss/mips/crt0_cfe.S newlib-1.15.0-patched/libgloss/mips/crt0_cfe.S
--- newlib-1.15.0/libgloss/mips/crt0_cfe.S	2004-06-14 07:57:29.000000000 -0400
+++ newlib-1.15.0-patched/libgloss/mips/crt0_cfe.S	2026-07-02 00:00:00.000000000 +0000
@@ -223,9 +223,9 @@
 	jal	main			# call the program start function
 	move	a0,zero			# set argc to 0; delay slot.
 
-	# fall through to the "exit" routine
+	/* fall through to the "exit" routine */
 	jal	exit			# call libc exit to run the G++
-					# destructors
 +					/* destructors */
 	move	a0, v0			# pass through the exit code
 	.end	_crt0init
diff -ru newlib-1.15.0/libgloss/config/default.mh newlib-1.15.0-patched/libgloss/config/default.mh
--- newlib-1.15.0/libgloss/config/default.mh	2003-06-05 19:25:04.000000000 -0400
+++ newlib-1.15.0-patched/libgloss/config/default.mh	2026-07-02 00:00:00.000000000 +0000
@@ -20,4 +20,4 @@
 # GCC knows to run the preprocessor on .S files before it assembles them.
 #
 .S.o:
-	$(CC) $(CFLAGS_FOR_TARGET) $(INCLUDES) $(CFLAGS) -c $<
+	$(CC) $(CFLAGS_FOR_TARGET) $(INCLUDES) $(CFLAGS) -traditional-cpp -c $<
diff -ru newlib-1.15.0/libgloss/mips/Makefile.in newlib-1.15.0-patched/libgloss/mips/Makefile.in
--- newlib-1.15.0/libgloss/mips/Makefile.in	2004-01-14 20:47:54.000000000 -0500
+++ newlib-1.15.0-patched/libgloss/mips/Makefile.in	2026-07-02 00:00:00.000000000 +0000
@@ -217,13 +217,13 @@
 # these are for the BSPs
 crt0.o: ${srcdir}/crt0.S
 pcrt0.o: ${srcdir}/crt0.S
-	$(CC) -c $(CFLAGS_FOR_TARGET) $(CFLAGS) -DGCRT0 ${srcdir}/crt0.S -o ${PCRT0}
+	$(CC) -c $(CFLAGS_FOR_TARGET) $(CFLAGS) -traditional-cpp -DGCRT0 ${srcdir}/crt0.S -o ${PCRT0}
 crt0_cfe.o: ${srcdir}/crt0_cfe.S
 crt0_cygmon.o: ${srcdir}/crt0_cygmon.S
 idtmon.o: ${srcdir}/idtmon.S
 pmon.o: ${srcdir}/pmon.S
-	$(CC) -c $(CFLAGS_FOR_TARGET) $(CFLAGS) $(PART_SPECIFIC_DEFINES) ${srcdir}/pmon.S -o pmon.o
+	$(CC) -c $(CFLAGS_FOR_TARGET) $(CFLAGS) -traditional-cpp $(PART_SPECIFIC_DEFINES) ${srcdir}/pmon.S -o pmon.o
 vr4300.o: ${srcdir}/vr4300.S
-	$(CC) -c $(CFLAGS_FOR_TARGET) $(CFLAGS) ${srcdir}/vr4300.S
+	$(CC) -c $(CFLAGS_FOR_TARGET) $(CFLAGS) -traditional-cpp ${srcdir}/vr4300.S
 vr5xxx.o: ${srcdir}/vr5xxx.S
-	$(CC) -c $(CFLAGS_FOR_TARGET) $(CFLAGS) ${srcdir}/vr5xxx.S
+	$(CC) -c $(CFLAGS_FOR_TARGET) $(CFLAGS) -traditional-cpp ${srcdir}/vr5xxx.S
diff -ru newlib-1.15.0/libgloss/mips/pmon.S newlib-1.15.0-patched/libgloss/mips/pmon.S
--- newlib-1.15.0/libgloss/mips/pmon.S	2004-01-14 20:47:54.000000000 -0500
+++ newlib-1.15.0-patched/libgloss/mips/pmon.S	2026-07-02 00:00:00.000000000 +0000
@@ -161,8 +161,8 @@
 
 #ifdef LSI
 
-# For the LSI MiniRISC board, we can safely assume that we have
-# at least one megabyte of RAM.
+/* For the LSI MiniRISC board, we can safely assume that we have */
+/* at least one megabyte of RAM. */
 
 	.globl	__sizemem
 	.ent	__sizemem
diff -ru newlib-1.15.0/libgloss/mips/vr4300.S newlib-1.15.0-patched/libgloss/mips/vr4300.S
--- newlib-1.15.0/libgloss/mips/vr4300.S	2005-09-13 05:19:16.000000000 -0400
+++ newlib-1.15.0-patched/libgloss/mips/vr4300.S	2026-07-02 00:00:00.000000000 +0000
@@ -221,8 +221,8 @@
 	nop
 	nop
 	eret
-#        j       k0
-#        rfe
+/*      j       k0 */
+/*      rfe */
         .set reorder
         .set at
         .end __buserr
diff -ru newlib-1.15.0/libgloss/mips/vr5xxx.S newlib-1.15.0-patched/libgloss/mips/vr5xxx.S
--- newlib-1.15.0/libgloss/mips/vr5xxx.S	2004-11-22 13:42:03.000000000 -0500
+++ newlib-1.15.0-patched/libgloss/mips/vr5xxx.S	2026-07-02 00:00:00.000000000 +0000
@@ -337,8 +337,8 @@
 	nop
 	nop
 	eret
-#        j       k0
-#        rfe
+/*      j       k0 */
+/*      rfe */
         .set reorder
         .set at
         .end __buserr
EOF
touch "$NEWLIB/.patched"
fi;


# ****************************************
# ****** BUILD AND INSTALL BINUTILS ******
# ****************************************
p="${BINUTILS}";
BLD="${BUILDDIR}${p}";
if [ ! -d "$BLD" ] ; then
	echo "Configuring ${p}..."
	mkdir -p "$BLD" || exit 1;
	(
		cd "$BLD" \
		&& "../${p}/configure" --prefix="$PREFIX" --target="$TARGET" \
	) || exit 1;
fi;
if [ ! -e "$BLD/.installed" ] ; then
	(
		cd "$BLD" \
		&& echo "Building ${p}..." \
		&& make $MAKE_COMPAT_FLAGS \
		&& echo "Installing ${p}..." \
		&& make $MAKE_COMPAT_FLAGS install \
		&& touch ".installed"
	) || exit 1;
fi;
# make $TARGET-ar available via PATH
export PATH="$PREFIX/bin:$PATH"


# ***********************************
# ****** BUILD AND INSTALL GCC ******
# ***********************************
p="${GCC}";
BLD="${BUILDDIR}${p}";
if [ ! -d "$BLD" ] ; then
	echo "Configuring ${p}..."
	mkdir -p "$BLD" || exit 1;
	(
		cd "$BLD" \
		&& "../${p}/configure" --prefix="$PREFIX" --target="$TARGET" \
			--with-gnu-as --with-gnu-ld \
			--with-headers="../$NEWLIB/newlib/libc/include" \
			--with-as=$PREFIX/bin/$TARGET-as \
			--with-ld=$PREFIX/bin/$TARGET-ld \
			--disable-shared --enable-languages=c,c++ --disable-threads \
			--disable-libmudflap --with-newlib \
	) || exit 1;
	sed -i 's/^OUTPUT_OPTION =.*/OUTPUT_OPTION = -o $@/' "$BLD/gcc/Makefile" || exit 1;
fi;
if [ ! -e "$BLD/.installed" ] ; then
	(
		cd "$BLD" \
		&& echo "Building ${p}..." \
		&& make $MAKE_COMPAT_FLAGS \
		&& echo "Installing ${p}..." \
		&& make $MAKE_COMPAT_FLAGS install \
		&& touch ".installed"
	) || exit 1;
fi;


# **************************************
# ****** BUILD AND INSTALL NEWLIB ******
# **************************************
p="${NEWLIB}";
BLD="${BUILDDIR}${p}";
if [ ! -d "$BLD" ] ; then
	echo "Configuring ${p}..."
	mkdir -p "$BLD" || exit 1;
	(
		cd "$BLD" \
		&& "../${p}/configure" --prefix="$PREFIX" --target="$TARGET" --enable-newlib-hw-fp \
	) || exit 1;
fi;
if [ ! -e "$BLD/.installed" ] ; then
	(
		cd "$BLD" \
		&& echo "Building ${p}..." \
		&& make $MAKE_COMPAT_FLAGS \
		&& echo "Installing ${p}..." \
		&& make $MAKE_COMPAT_FLAGS install \
		&& touch ".installed"
	) || exit 1;
fi;


# ***************************
# ****** PATCH libc-.a ******
# ***************************
# Says Sony:
# Some functions in libc.a have improper implementation.  Correct
# version of them are provided by libapsys.a.  To avoid mislinking, we
# use libc-.a, from which the duplicated functions are removed.
ensure_libc_dash

# ********************************
# ****** EXTRACT OPEN-R SDK ******
# ********************************
if [ ! -d "$PREFIX/OPEN_R" ] ; then
	p="$OPENRSDK"
	if [ -f "$p.tar.gz" ]; then
		echo "Extracting $p.tar.gz"
		tar -C "$PREFIX" -xzf "$p.tar.gz" || exit 1;
	elif [ -f "$p.tgz" ]; then
		echo "Extracting $p.tgz"
		tar -C "$PREFIX" -xzf "$p.tgz" || exit 1;
	
	elif [ -f "$p.tar.bz2" ]; then
		echo "Extracting $p.tar.bz2"
		tar -C "$PREFIX" -xjf "$p.tar.bz2" || exit 1;
	elif [ -f "$p.tbz" ]; then
		echo "Extracting $p.tbz"
		tar -C "$PREFIX" -xjf "$p.tbz" || exit 1;
	
	elif [ -f "$p.tar" ]; then
		echo "Extracting $p.tar"
		tar -C "$PREFIX" -xf "$p.tar" || exit 1;
	
	else
		if [ -d "$OPENRSDK_SOURCE_DIR/OPEN_R" ]; then
			echo "Copying SDK payload from $OPENRSDK_SOURCE_DIR"
			cp -a \
				"$OPENRSDK_SOURCE_DIR/CHANGES_E.txt" \
				"$OPENRSDK_SOURCE_DIR/CHANGES_J.txt" \
				"$OPENRSDK_SOURCE_DIR/OPEN_R" \
				"$OPENRSDK_SOURCE_DIR/RP_OPEN_R" \
				"$OPENRSDK_SOURCE_DIR/tcpgw-robocup.txt" \
				"$PREFIX"/ || exit 1
			echo "Reusing existing OPEN_R_SDK payload because $p archive is not present."
			echo "Toolchain and target libs are rebuilt from source tarballs in deps/."
			echo "If you later add $p.tar.gz to deps/, this script can extract it directly."
			echo "All Done!"
			exit 0
		fi
		echo "Missing package $p in the current directory, cannot continue."
		exit 1;
	fi;
	mv "$PREFIX/OPEN_R_SDK/"* "$PREFIX" || exit 1
fi;


# *************************
# ****** USER REPORT ******
# *************************
echo "All Done!"
