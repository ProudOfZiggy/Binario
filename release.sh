make clean
make build
tar -cvzf ".build/binario.zip" -C ".build/apple/Products/Release" "./binario"
gh release create 0.80.5 ".build/binario.zip"