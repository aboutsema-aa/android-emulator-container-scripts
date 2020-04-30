#!/bin/sh
#
# Copyright 2019 - The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

log_version_info() {
  # This function logs version info.
  $ANDROID_HOME/emulator/emulator -version | head -n 1 | sed -u 's/^/version: /g'
  echo 'version: launch_script: {{version}}'
  img=$ANDROID_SDK_ROOT/system-images/android
  [ -f "$img/x86_64/source.properties" ] && cat "$img/x86_64/source.properties" | sed -u 's/^/version: /g'
  [ -f "$img/x86/source.properties" ] && cat "$img/x86/source.properties" | sed -u 's/^/version: /g'
}

clean_up() {
  # Delete any leftovers from hard exits.
  rm -rf /tmp/*
  rm -rf /android-home/Pixel2.avd/*.lock

  # Check for core-dumps, that might be left over
  if ls core* 1>/dev/null 2>&1; then
    echo "emulator: ** WARNING ** WARNING ** WARNING **"
    echo "emulator: Core dumps exist in this image. This means the emulator has crashed in the past."
  fi

  mkdir -p /root/.android
}

# Let's log the emulator,script and image version.
log_version_info
clean_up

# Override config settings that the user forcefully wants to override.
if [ ! -z "${AVD_CONFIG}" ]; then
  echo "Adding ${AVD_CONFIG} to config.ini"
  echo "${AVD_CONFIG}" >>"/android-home/Pixel2.avd/config.ini"
fi

# Kick off the emulator
exec $ANDROID_HOME/emulator/emulator @Pixel2 -no-audio -wipe-data \
  -no-window -skip-adb-auth -no-snapshot \
  -feature AllowSnapshotMigration \
  -gpu swiftshader_indirect \
  {{extra}} ${EMULATOR_PARAMS} -qemu -append panic=1
# All done!
