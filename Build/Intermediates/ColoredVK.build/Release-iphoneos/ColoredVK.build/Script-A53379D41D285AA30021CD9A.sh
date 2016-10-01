#!/bin/sh
cd ${PROJECT_DIR}
echo "TEST"
cp -r ColoredVK.bundle/. ~/Desktop/vkUnarch/Payload/vkclient.app/${PRODUCT_NAME}.bundle/
cp ${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.dylib ~/Desktop/vkUnarch/Payload/vkclient.app/${PRODUCT_NAME}.bundle/
cd ~/Desktop/vkUnarch
optool install -c load -p "@executable_path/${PRODUCT_NAME}.bundle/${PRODUCT_NAME}.dylib" -t Payload/vkclient.app/vkclient
if [ -f ~/Desktop/vk.ipa ];
    then rm ~/Desktop/vk.ipa 
fi
zip -r ~/Desktop/${PRODUCT_NAME}.ipa Payload
optool uninstall -p "@executable_path/${PRODUCT_NAME}.bundle/${PRODUCT_NAME}.dylib" -t Payload/vkclient.app/vkclient
rm -rf Payload/vkclient.app/${PRODUCT_NAME}.bundle

cp -r ${PROJECT_DIR}/ColoredVK.bundle ~/Desktop/${PRODUCT_NAME}.bundle
cp ${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.dylib ~/Desktop/${PRODUCT_NAME}.bundle/
