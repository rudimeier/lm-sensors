#  Module.mk - Makefile for a Linux module for reading sensor data.
#  Copyright (c) 1998  Frodo Looijaard <frodol@dds.nl>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

# Note that MODULE_DIR (the directory in which this file resides) is a
# 'simply expanded variable'. That means that its value is substituted
# verbatim in the rules, until it is redefined. 
MODULE_DIR := lib

# The main and minor version of the library
LIBMAINVER := 0
LIBMINORVER := 0.0
LIBVER := $(LIBMAINVER).$(LIBMINORVER)

# The static lib name, the shared lib name, and the internal ('so') name of
# the shared lib.
LIBSHBASENAME := libsensors.so
LIBSHLIBNAME := libsensors.so.$(LIBVER)
LIBSTLIBNAME := libsensors.a
LIBSHSONAME := libsensors.so.$(LIBMAINVER)

LIBTARGETS := $(MODULE_DIR)/$(LIBSTLIBNAME) $(MODULE_DIR)/$(LIBSHLIBNAME) \
              $(MODULE_DIR)/$(LIBSHSONAME) $(MODULE_DIR)/$(LIBSHBASENAME)

LIBCSOURCES := $(MODULE_DIR)/data.c $(MODULE_DIR)/general.c \
               $(MODULE_DIR)/error.c $(MODULE_DIR)/chips.c \
               $(MODULE_DIR)/proc.c $(MODULE_DIR)/access.c \
               $(MODULE_DIR)/init.c
LIBOTHEROBJECTS := $(MODULE_DIR)/conf-parse.o $(MODULE_DIR)/conf-lex.o
LIBSHOBJECTS := $(LIBCSOURCES:.c=.lo) $(LIBOTHEROBJECTS:.o=.lo)
LIBSTOBJECTS := $(LIBCSOURCES:.c=.ao) $(LIBOTHEROBJECTS:.o=.ao)
LIBEXTRACLEAN := $(MODULE_DIR)/conf_parse.h

LIBHEADERFILES := $(MODULE_DIR)/error.h $(MODULE_DIR)/sensors.h

# How to create the shared library
$(MODULE_DIR)/$(LIBSHLIBNAME): $(LIBSHOBJECTS)
	$(CC) -shared -Wl,-soname,$(LIBSHSONAME) -o $@ $^ -lc

$(MODULE_DIR)/$(LIBSHSONAME): $(MODULE_DIR)/$(LIBSHLIBNAME)
	$(RM) $@
	$(LN) $(LIBSHLIBNAME) $@

$(MODULE_DIR)/$(LIBSHBASENAME): $(MODULE_DIR)/$(LIBSHLIBNAME)
	$(RM) $@ 
	$(LN) $(LIBSHLIBNAME) $@

# And the static library
$(MODULE_DIR)/$(LIBSTLIBNAME): $(LIBSTOBJECTS)
	$(RM) $@
	$(AR) rcvs $@ $^

# Depencies for non-C sources
$(MODULE_DIR)/conf-lex.c: $(MODULE_DIR)/conf-lex.l $(MODULE_DIR)/general.h \
                          $(MODULE_DIR)/data.h $(MODULE_DIR)/conf-parse.h
$(MODULE_DIR)/conf-parse.c: $(MODULE_DIR)/conf-parse.y $(MODULE_DIR)/general.h \
                            $(MODULE_DIR)/data.h
$(MODULE_DIR)/conf-parse.h: $(MODULE_DIR)/conf-parse.c

# Include all dependency files
INCLUDEFILES += $(LIBCSOURCES:.c=.ld) $(LIBCSOURCES:.c=.ad)

all-lib: $(LIBTARGETS)
all :: all-lib

install-lib:
	$(MKDIR) $(LIBDIR) $(LIBINCLUDEDIR)
	$(INSTALL) -o root -g root -m 644 $(LIBTARGETS) $(LIBDIR)
	$(LN) $(LIBSHLIBNAME) $(LIBDIR)/$(LIBSHSONAME)
	$(LN) $(LIBSHSONAME) $(LIBDIR)/$(LIBSHBASENAME)
	$(INSTALL) -o root -g root -m 644 $(LIBHEADERFILES) $(LIBINCLUDEDIR)
install :: install-lib

clean-lib:
	$(RM) $(LIBTARGETS) $(LIBSHOBJECTS) $(LIBSTOBJECTS)
	$(RM) $(LIBSHOBJECTS:.lo=.ld) $(LIBSTOBJECTS:.ao=.ad)
	$(RM) $(LIBOTHEROBJECTS:.o=.c) $(LIBEXTRACLEAN)
clean :: clean-lib
