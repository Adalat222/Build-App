# sync rom
repo init --depth=1 --no-repo-verify -u repo init -u https://github.com/Project-Elixir/manifest -b Tiramisu -g default,-mips,-darwin,-notdefault
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j 30 || repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j 8
repo sync -j1 --fail-fast

echo 'Starting to clone stuffs needed for your device'

echo 'Cloning Vendor tree [1/3]'
# Vendor Tree
git clone --depth=1 https://github.com/iitzrohan/vendor_xiaomi_gauguin.git vendor/xiaomi/gauguin

echo 'Cloning Kernel tree [2/3]'
# Kernel Tree
git clone --depth=1 https://github.com/iitzrohan/android_kernel_xiaomi_gauguin.git kernel/xiaomi/gauguin

echo 'Cloning atomx clang [3/3]'
# atomx Clang
git clone --depth=1 https://gitlab.com/ElectroPerf/atom-x-clang.git prebuilts/clang/host/linux-x86/clang-atomx


# build rom 1
source build/envsetup.sh
lunch aosp_gauguin-userdebug
export CCACHE_DIR=/tmp/ccache
export CCACHE_EXEC=$(which ccache)
export USE_CCACHE=1
ccache -M 20G
ccache -o compression=true
ccache -z 
export SELINUX_IGNORE_NEVERALLOWS=true
export TZ=Asia/Kolkata
mka mka bacon -j10

# upload rom (if you don't need to upload multiple files, then you don't need to edit next line)
rclone copy out/target/product/$(grep unch $CIRRUS_WORKING_DIR/build_rom.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1)/*.zip cirrus:$(grep unch $CIRRUS_WORKING_DIR/build_rom.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1) -P
