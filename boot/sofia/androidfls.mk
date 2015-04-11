# Copyright (C) 2013-2014 Intel Mobile Communications GmbH
# Copyright (C) 2011 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ------------------------------------------------------------------------

# --------------------------------------
# Fls generation of AOSP image files
# -------------------------------------

SYSTEM_FLS		         := $(FLASHFILES_DIR)/system.fls
ANDROID_SIGNED_FLS_LIST  += $(SIGN_FLS_DIR)/system_signed.fls

USERDATA_FLS 	         := $(FLASHFILES_DIR)/userdata.fls
ANDROID_SIGNED_FLS_LIST  += $(SIGN_FLS_DIR)/userdata_signed.fls

CACHE_FLS 	  	         := $(FLASHFILES_DIR)/cache.fls
ANDROID_SIGNED_FLS_LIST  += $(SIGN_FLS_DIR)/cache_signed.fls

BOOTIMG_FLS		         := $(FLASHFILES_DIR)/boot.fls
SYSTEM_SIGNED_FLS_LIST   += $(SIGN_FLS_DIR)/boot_signed.fls

RECOVERY_FLS		     := $(FLASHFILES_DIR)/recovery.fls
SYSTEM_SIGNED_FLS_LIST   += $(SIGN_FLS_DIR)/recovery_signed.fls


$(SYSTEM_FLS): createflashfile_dir $(FLSTOOL) $(INTEL_PRG_FILE) systemimage $(INSTALLED_SYSTEMIMAGE) $(FLASHLOADER_FLS)
	$(FLSTOOL) --prg $(INTEL_PRG_FILE) --output $@ --tag SYSTEM $(INJECT_FLASHLOADER_FLS) $(INSTALLED_SYSTEMIMAGE) --replace --to-fls2

$(USERDATA_FLS): createflashfile_dir $(FLSTOOL) $(INTEL_PRG_FILE) userdataimage  $(INSTALLED_USERDATAIMAGE_TARGET) $(FLASHLOADER_FLS)
	$(FLSTOOL) --prg $(INTEL_PRG_FILE) --output $@ --tag USERDATA $(INJECT_FLASHLOADER_FLS) $(INSTALLED_USERDATAIMAGE_TARGET) --replace --to-fls2

$(CACHE_FLS): createflashfile_dir $(FLSTOOL) $(INTEL_PRG_FILE) cacheimage $(INSTALLED_CACHEIMAGE_TARGET) $(PSI_RAM_FLB) $(FLASHLOADER_FLS)
	$(FLSTOOL) --prg $(INTEL_PRG_FILE) --output $@ --tag CACHE $(INJECT_FLASHLOADER_FLS) $(INSTALLED_CACHEIMAGE_TARGET) --replace --to-fls2

$(BOOTIMG_FLS): createflashfile_dir $(FLSTOOL) $(INTEL_PRG_FILE) $(BUILT_RAMDISK_TARGET) $(INSTALLED_KERNEL_TARGET) bootimage $(INSTALLED_BOOTIMAGE_TARGET) $(FLASHLOADER_FLS)
	$(FLSTOOL) --prg $(INTEL_PRG_FILE) --output $@ --tag BOOT_IMG $(INJECT_FLASHLOADER_FLS) $(INSTALLED_BOOTIMAGE_TARGET) --replace --to-fls2
$(RECOVERY_FLS): createflashfile_dir $(FLSTOOL) $(INTEL_PRG_FILE) $(INSTALLED_KERNEL_TARGET) recoveryimage $(INSTALLED_RECOVERYIMAGE_TARGET) $(FLASHLOADER_FLS)
	$(FLSTOOL) --prg=$(INTEL_PRG_FILE) --output $@ --tag=RECOVERY $(INJECT_FLASHLOADER_FLS) $(INSTALLED_RECOVERYIMAGE_TARGET) --replace --to-fls2


.PHONY: system.fls userdata.fls cache.fls boot.fls recovery.fls

system.fls: $(SYSTEM_FLS)
userdata.fls: $(USERDATA_FLS)
cache.fls: $(CACHE_FLS)
boot.fls: $(BOOTIMG_FLS)
recovery.fls: $(RECOVERY_FLS)

ifeq ($(findstring sofia3g,$(TARGET_BOARD_PLATFORM)), sofia3g)
android_fls: $(SYSTEM_FLS) $(USERDATA_FLS) $(CACHE_FLS) $(BOOTIMG_FLS) $(if $(findstring true,$(TARGET_NO_RECOVERY)),,$(RECOVERY_FLS))
else
android_fls: $(SYSTEM_FLS) $(USERDATA_FLS) $(CACHE_FLS) $(BOOTIMG_FLS)
endif

ifeq ($(GEN_ANDROID_FLS_FILES),true)
droidcore: android_fls
endif

flsinfo:
	@echo "-------------------------------------------------------------"
	@echo " Android Images:"
	@echo " All fls files are generated by default. Specific fls file can be generated using below targets."
	@echo "-make system.fls : Will create fls file for system image."
	@echo "-make userdata.fls : Will create fls file for userdata image."
	@echo "-make boot.fls : Will create fls file for boot image."
	@echo "-make cache.fls : Will create fls file for cache image."
	@echo "-make recovery.fls : Will create fls file for recovery image."

build_info: flsinfo

