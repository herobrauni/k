curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh || wget -O reinstall.sh $_

# gc1
bash reinstall.sh dd --img "https://factory.talos.dev/image/8cd2124cfac26b7f5cdb86d2d715dbbfa98aa6dab396689b3ca6da970930d17a/v1.10.2/metal-amd64.raw.zst"
# gc5
bash reinstall.sh dd --img "https://factory.talos.dev/image/ca8a419ed755b951c6913eada7a37af035f3b756287300e63419ae940aa76067/v1.10.2/metal-amd64.raw.zst"
#gc7
bash reinstall.sh dd --img "https://factory.talos.dev/image/782d6da2f8b1b3c38c91948722f079f179d6a0f461b427db8f0ca4edef01a253/v1.10.2/metal-amd64.raw.zst"
