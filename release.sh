VERSION=$1

if ! [ -n "$VERSION" ]; then
  echo "Specify release version"
  exit
fi

echo "Releasing version $VERSION of Binario"

make clean
make build-universal
tar -cvzf ".build/binario.tar.gz" -C ".build/apple/Products/Release" "./binario"
gh release create "v"$VERSION ".build/binario.tar.gz"
