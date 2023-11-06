# Copyright (c) 2011 The LevelDB Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file. See the AUTHORS file for names of contributors.

# Inherit some settings from environment variables, if available

#-----------------------------------------------

BASH_EXISTS := $(shell which bash)
SHELL := $(shell which bash)
include common.mk

CLEAN_FILES = # deliberately empty, so we can append below.
CFLAGS += ${EXTRA_CFLAGS}
CXXFLAGS += ${EXTRA_CXXFLAGS}
LDFLAGS += $(EXTRA_LDFLAGS)
MACHINE ?= $(shell uname -m)
ARFLAGS = ${EXTRA_ARFLAGS} rs
STRIPFLAGS = -S -x



openssl: rocksdbjavastaticosx_archs
	cd java/target; lipo -create -output librocksdbjni-osx.jnilib librocksdbjni-osx-x86_64.jnilib librocksdbjni-osx-arm64.jnilib
	cd java; $(JAR_CMD)  -cf target/$(ROCKSDB_JAR) HISTORY*.md
	cd java/target; $(JAR_CMD) -uf $(ROCKSDB_JAR) librocksdbjni-osx.jnilib
	cd java/target/classes; $(JAR_CMD) -uf ../$(ROCKSDB_JAR) org/rocksdb/*.class org/rocksdb/util/*.class
	openssl sha1 java/target/$(ROCKSDB_JAR) | sed 's/.*= \([0-9a-f]*\)/\1/' > java/target/$(ROCKSDB_JAR).sha1
