curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh || wget -O reinstall.sh $_

# gc1
bash reinstall.sh dd --img "https://factory.talos.dev/image/8cd2124cfac26b7f5cdb86d2d715dbbfa98aa6dab396689b3ca6da970930d17a/v1.10.2/metal-amd64.raw.zst"
# gc5
bash reinstall.sh dd --img "https://factory.talos.dev/image/ca8a419ed755b951c6913eada7a37af035f3b756287300e63419ae940aa76067/v1.10.2/metal-amd64.raw.zst"
# gc7
bash reinstall.sh dd --img "https://factory.talos.dev/image/782d6da2f8b1b3c38c91948722f079f179d6a0f461b427db8f0ca4edef01a253/v1.10.2/metal-amd64.raw.zst"
# terabit1
bash reinstall.sh dd --img "https://factory.talos.dev/image/fdd74614afcfc1b15de5512fe9a713092f61b08137236664da79de9b6bed140f/v1.10.2/metal-amd64.raw.zst"
# terabit2
bash reinstall.sh dd --img "https://factory.talos.dev/image/5154b72f67c5f8e36f0b8627938a89aa6391d89321754076883b8ce171425ab7/v1.10.2/metal-amd64.raw.zst"
