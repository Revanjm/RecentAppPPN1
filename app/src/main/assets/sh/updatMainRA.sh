#!/bin/bash

DB_PATH="/storage/emulated/0/.recentappppn1/.db/main.db"

# Проверяем наличие базы данных
[ ! -f "$DB_PATH" ] && exit 1

# Получаем список скрытых задач (mHiddenTasks)
hidden_tasks=$(dumpsys activity | awk '/mHiddenTasks=/{print $0}' | tr -d '[]' | sed 's/mHiddenTasks=//g')

# Получаем список недавних приложений, исключая те, что находятся в hidden_tasks
recent_apps=$(dumpsys activity recents | awk '/A=|I=/{print $0}' | sed -E 's/.*A=[0-9]+://;s/.*I=//;s/Task\{[0-9a-f]+ //;s/\}//' | grep -vF "$hidden_tasks" | grep -vE 'com\.miui\.home|com\.ppnapptest\.quickpanel1' | sed 's/[^a-zA-Z\/\.]//g')

# Убедимся, что полученные значения recent_apps соответствуют формату пакетов
recent_apps=$(echo "$recent_apps" | grep -E '^[a-zA-Z0-9]+\.[a-zA-Z0-9\.]+$')

# Преобразуем recent_apps в массив
apps_array=($(echo "$recent_apps" | tr '\n' ' '))

# Добавляем "NULL" для недостающих значений до 30 элементов
while [ "${#apps_array[@]}" -lt 30 ]; do
  apps_array+=("NULL")
done

# Убедимся, что таблица обновляется для id = 1
sqlite3 "$DB_PATH" <<EOF
BEGIN TRANSACTION;

-- Обновляем значения в строке с id = 1
UPDATE main
SET ra1 = '${apps_array[0]}', ra2 = '${apps_array[1]}', ra3 = '${apps_array[2]}', ra4 = '${apps_array[3]}', ra5 = '${apps_array[4]}', ra6 = '${apps_array[5]}', ra7 = '${apps_array[6]}', ra8 = '${apps_array[7]}', ra9 = '${apps_array[8]}', ra10 = '${apps_array[9]}', ra11 = '${apps_array[10]}', ra12 = '${apps_array[11]}', ra13 = '${apps_array[12]}', ra14 = '${apps_array[13]}', ra15 = '${apps_array[14]}', ra16 = '${apps_array[15]}', ra17 = '${apps_array[16]}', ra18 = '${apps_array[17]}', ra19 = '${apps_array[18]}', ra20 = '${apps_array[19]}', ra21 = '${apps_array[20]}', ra22 = '${apps_array[21]}', ra23 = '${apps_array[22]}', ra24 = '${apps_array[23]}', ra25 = '${apps_array[24]}', ra26 = '${apps_array[25]}', ra27 = '${apps_array[26]}', ra28 = '${apps_array[27]}', ra29 = '${apps_array[28]}', ra30 = '${apps_array[29]}'
WHERE id = 1;

COMMIT;
EOF
