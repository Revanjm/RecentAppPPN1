DB_PATH="/storage/emulated/0/.recentappppn1/.db/main.db"

if [ ! -f "$DB_PATH" ]; then
    exit 1
fi

recent_apps=$(dumpsys activity recents | grep -E 'A=|I=' | sed -E 's/.*A=[0-9]+://;s/.*I=//;s/Task\{[0-9a-f]+ //;s/\}//')

apps_array=($(echo "$recent_apps" | tr '\n' ' '))

filtered_apps=()
for app in "${apps_array[@]}"; do
  if [[ "$app" != "com.ppnapptest.quickpanel1/.MainActivity" && "$app" != "com.miui.home/.launcher.Launcher" ]]; then
    filtered_apps+=("$app")
  fi
done

for i in {${#filtered_apps[@]}..29}; do
    filtered_apps+=("NULL")
done

sqlite3 "$DB_PATH" "DELETE FROM main; INSERT INTO main (ra1, ra2, ra3, ra4, ra5, ra6, ra7, ra8, ra9, ra10, ra11, ra12, ra13, ra14, ra15, ra16, ra17, ra18, ra19, ra20, ra21, ra22, ra23, ra24, ra25, ra26, ra27, ra28, ra29, ra30) VALUES ('${filtered_apps[0]}', '${filtered_apps[1]}', '${filtered_apps[2]}', '${filtered_apps[3]}', '${filtered_apps[4]}', '${filtered_apps[5]}', '${filtered_apps[6]}', '${filtered_apps[7]}', '${filtered_apps[8]}', '${filtered_apps[9]}', '${filtered_apps[10]}', '${filtered_apps[11]}', '${filtered_apps[12]}', '${filtered_apps[13]}', '${filtered_apps[14]}', '${filtered_apps[15]}', '${filtered_apps[16]}', '${filtered_apps[17]}', '${filtered_apps[18]}', '${filtered_apps[19]}', '${filtered_apps[20]}', '${filtered_apps[21]}', '${filtered_apps[22]}', '${filtered_apps[23]}', '${filtered_apps[24]}', '${filtered_apps[25]}', '${filtered_apps[26]}', '${filtered_apps[27]}', '${filtered_apps[28]}', '${filtered_apps[29]}');"