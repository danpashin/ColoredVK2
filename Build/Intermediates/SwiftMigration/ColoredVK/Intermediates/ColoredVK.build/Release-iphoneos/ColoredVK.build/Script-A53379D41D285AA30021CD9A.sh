#!/bin/sh
cd ${PROJECT_DIR}
cp -r ColoredVK.bundle Payload/vkclient.app/
cp ${BUILT_PRODUCTS_DIR}/ColoredVK.dylib Payload/vkclient.app/ColoredVK.bundle/
optool install -c load -p "@executable_path/ColoredVK.bundle/ColoredVK.dylib" -t Payload/vkclient.app/vkclient
if [ -f ~/Desktop/vk.ipa ];
    then rm ~/Desktop/vk.ipa 
fi
zip -r ~/Desktop/vk.ipa Payload
optool uninstall -p "@executable_path/ColoredVK.bundle/ColoredVK.dylib" -t Payload/vkclient.app/vkclient
rm -rf Payload/vkclient.app/ColoredVK.bundle

#cp -r ColoredVK.bundle ~/Desktop/
#cp ${BUILT_PRODUCTS_DIR}/ColoredVK.dylib ~/Desktop/ColoredVK.bundle/
