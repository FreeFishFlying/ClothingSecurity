read -p "Which pod do your want remove? (enter nothing will remove all) " RESP
if [ "$RESP" = "" ]; then
echo "Clear All Cache"
rm -rf "${HOME}/Library/Caches/CocoaPods"
rm -rf "`pwd`/Pods/"
pod update
else
echo "Clear Cache "  $RESP
rm -rf "${HOME}/Library/Caches/CocoaPods/Pods/Release/"$RESP
rm -rf "`pwd`/Pods/"$RESP
pod install
fi


