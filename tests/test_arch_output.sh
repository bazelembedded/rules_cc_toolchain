# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v2 ---

arch_info() {
    $(rlocation "clang_llvm_12_00_x86_64_linux_gnu_ubuntu_16_04/bin/llvm-readelf") --arch-specific $1
}

ARCH_INFO=`arch_info $1`
shift

for var in "$@"; do
    echo $var
    if ! echo $ARCH_INFO | grep "$var" ; then
      echo "FAIL: architecture info from readelf does not contain $var."
      echo $ARCH_INFO
      exit 1
    fi
done