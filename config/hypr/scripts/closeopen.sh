pkill $(echo "$1" | cut -d ' ' -f 1)

$1 &
orphan
