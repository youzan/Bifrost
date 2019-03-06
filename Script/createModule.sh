#！/bin/bash

# Cashier="Cashier"
# templateName="SampleModule"
# Common="Common"
# Phone="Phone"
# Pad="Pad"

# Template

ModuleName=$1

if [[ "$ModuleName"x == "x" ]]; then
echo "Please provide ModuleName!!!"
exit
fi

# git clone "git@gitlab.qima-inc.com:normandy-ios/ZanXcodeTemplates.git"

# cd ./ZanXcodeTemplates/Samples

rm -rf $ModuleName
cp -r TemplateModule $ModuleName
cd $ModuleName

echo ""
echo "Replacing placeholders in all files..."
sed -i "" "s/Template/$ModuleName/g" `grep Template -rl "./Template"`
sed -i "" "s/Template/$ModuleName/g" `grep Template -rl "./Template.xcodeproj"`

echo ""
echo "Renaming folders and files..."
IFS=$'\n'
for ((i=0; i<1;))
do
	i=1
	for file in `find . -name "*Template*"`
	do
		i=0
		newFile=${file//Template/$ModuleName}
		mv "$file" "$newFile"
		echo "Renamed $file to $newFile"
		break
	done
done

echo "Done! Now you have your $ModuleName project."
open .
