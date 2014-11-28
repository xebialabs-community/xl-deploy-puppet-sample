module=$1
echo "remove submodule $module"
git submodule deinit $module
git rm $module
rm -rf .git/modules/$module

