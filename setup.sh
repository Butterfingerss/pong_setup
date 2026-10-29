#!/bin/bash

# Welcome message
echo ""
echo "=========================================================================="
echo "   Welcome to the Custom ROM Setup Script for Nothing Phone 2 (Pong)!   "
echo "=========================================================================="
echo ""
echo "✨ Happy custom ROM building! ✨"
echo ""

# Explain Depth Cloning
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📌 Git Depth Cloning Explanation:"
echo ""
echo "   - Shallow Clone (--depth=1): Only fetches the latest commit, making cloning faster and saving space."
echo "   - Full Clone: Fetches the entire repository history, useful for development but slower."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Ask user whether to use depth cloning
echo ""
read -p "Do you want to use depth cloning (--depth=1) for faster cloning? (y/n) [default: y]: " DEPTH_CHOICE
DEPTH_CHOICE="${DEPTH_CHOICE:-y}"
if [[ "$DEPTH_CHOICE" =~ ^[Nn]$ ]]; then
    CLONE_DEPTH=()
    echo ""
    echo "✅ Using full repository clone."
    echo ""
else
    CLONE_DEPTH=(--depth=1)
    echo ""
    echo "✅ Using shallow clone (--depth=1) for faster setup."
    echo ""
fi

# Override host metadata for reproducible builds
read -p "Do you want to override BUILD_USERNAME and BUILD_HOSTNAME? (y/n) [default: n]: " OVERRIDE_CHOICE
OVERRIDE_CHOICE="${OVERRIDE_CHOICE:-n}"
if [[ "$OVERRIDE_CHOICE" =~ ^[Yy]$ ]]; then
    read -p "Enter your desired BUILD_USERNAME: " BUILD_USERNAME
    read -p "Enter your desired BUILD_HOSTNAME: " BUILD_HOSTNAME

    export BUILD_USERNAME="$BUILD_USERNAME"
    export BUILD_HOSTNAME="$BUILD_HOSTNAME"

    echo ""
    echo "BUILD_USERNAME is set to: $BUILD_USERNAME"
    echo "BUILD_HOSTNAME is set to: $BUILD_HOSTNAME"
    echo ""
fi

# Define repositories
declare -A REPOS=(
    ["device/nothing/Pong"]="https://github.com/Butterfingerss/device_nothing_Pong.git|17"
    ["vendor/nothing/Pong"]="https://github.com/Butterfingerss/Vendor_nothing_Pong.git|17"
    ["vendor/nothing/camera"]="https://github.com/Butterfingerss/vendor_nothing_camera.git|calcite-phone2"
    ["vendor/qcom/opensource/interfaces"]="https://github.com/Butterfingerss/android_vendor_qcom_opensource_interfaces.git|lineage-24.0"
    ["kernel/nothing/sm8475"]="https://github.com/Butterfingerss/kernel_nothing_sm8475.git|17"
    ["kernel/nothing/sm8475-modules"]="https://github.com/Pong-Development/kernel_nothing_sm8475-modules.git|17"
    ["kernel/nothing/sm8475-devicetrees"]="https://github.com/Nothing-phone-2-Development/android_kernel_nothing_sm8475-devicetrees.git|lineage-23.0"
    ["hardware/qcom-caf/sm8450/display"]="https://github.com/Pong-Development/hardware_qcom-caf_sm8450_display.git|16"
    ["hardware/dolby"]="https://github.com/Pong-Development/hardware_dolby.git|16"
    ["packages/apps/ParanoidGlyphPhone2"]="https://github.com/Pong-Development/packages_apps_ParanoidGlyph.git|17"
    ["packages/apps/GlyphAdapter"]="https://github.com/Pong-Development/packages_apps_GlyphAdapter.git|16"
)

# Function to clone a repository with error handling
clone_repo() {
    local target_dir="$1"
    local repo_data="$2"

    IFS='|' read -r repo_url branch <<< "$repo_data"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Cloning $target_dir..."
    echo "Repository: $repo_url"
    echo "Branch:     $branch"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ -e "$target_dir" ]; then
        echo "Removing existing directory: $target_dir"
        rm -rf -- "$target_dir"
    fi

    mkdir -p "$(dirname "$target_dir")"

    if git clone "${CLONE_DEPTH[@]}" -b "$branch" "$repo_url" "$target_dir"; then
        echo ""
        echo "✅ Successfully cloned ✨ $target_dir"
        echo "🌿 Branch: $branch"
        echo ""
    else
        echo ""
        echo "❌ Failed to clone $target_dir"
        echo "🌿 Branch: $branch"
        echo ""
        exit 1
    fi
}

# Clone all repositories
for target_dir in "${!REPOS[@]}"; do
    clone_repo "$target_dir" "${REPOS[$target_dir]}"
done

# Patch invalid lto_Instr100 in display Android.bp if present
DISPLAY_BP="hardware/qcom-caf/sm8450/display/Android.bp"
if [ -f "$DISPLAY_BP" ] && grep -q 'lto_Instr100' "$DISPLAY_BP"; then
    echo "🔧 Patching invalid lto_Instr100 in display Android.bp..."
    sed -i '/lto_Instr100/d' "$DISPLAY_BP"
    echo "✅ Display Android.bp patched."
    echo ""
fi

# Reassemble split Hyperzoom library if split parts exist
HYPERZOOM_DIR="vendor/nothing/Pong/proprietary/vendor/lib64"
HYPERZOOM_SO="$HYPERZOOM_DIR/libhyperzoom.arcsoft.so"
if [ -f "$HYPERZOOM_DIR/libhyperzoom.arcsoft.so.part00" ] && [ ! -f "$HYPERZOOM_SO" ]; then
    echo "🔨 Reassembling libhyperzoom.arcsoft.so..."
    cat "$HYPERZOOM_DIR"/libhyperzoom.arcsoft.so.part* > "$HYPERZOOM_SO"
    echo "✅ Assembled $HYPERZOOM_SO"
    echo ""
fi

# Reassemble split NTCamera APK if split parts exist
NTCAM_DIR="vendor/nothing/camera/proprietary/system_ext/priv-app/NTCamera"
NTCAM_APK="$NTCAM_DIR/NTCamera.apk"
if [ -f "$NTCAM_DIR/NTCamera.apk.part00" ] && [ ! -f "$NTCAM_APK" ]; then
    echo "🔨 Reassembling NTCamera.apk..."
    cat "$NTCAM_DIR"/NTCamera.apk.part* > "$NTCAM_APK"
    echo "✅ Assembled $NTCAM_APK"
    echo ""
fi

# Setup done
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " ✅ Setup completed successfully! "
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🚀 All repositories have been cloned successfully!"
echo ""
echo "🎉 Enjoy building your custom ROM!"
echo "✨ Done! Happy flashing! ✨"
echo ""
