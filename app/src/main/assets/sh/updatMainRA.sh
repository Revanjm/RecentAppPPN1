#!/bin/bash

DB_PATH="/storage/emulated/0/.recentappppn1/.db/main.db"

# Проверяем, существует ли база данных
if [ ! -f "$DB_PATH" ]; then
    exit 1
fi

# Начало измерения времени
start_time=$(date +%s%3N)

# Сразу получаем данные из dumpsys activity, исключая hidden tasks
dumpsys_output=$(dumpsys activity | grep -A 100 "Recent tasks" | grep -E 'A=|I=' | grep -vF "$(dumpsys activity | grep 'mHiddenTasks=' | sed 's/mHiddenTasks=//' | tr -d '[]')")

# Обрабатываем данные для recent_apps
recent_apps=$(echo "$dumpsys_output" | sed -E 's/.*A=[0-9]+://;s/.*I=//;s/Task\{[0-9a-f]+ //;s/\}//' | grep -vE 'com\.miui\.home|com\.ppnapptest\.quickpanel1' | sed 's/[^a-zA-Z\/\.]//g')

# Отбор неправильных форматов приложений
invalid_apps=$(echo "$recent_apps" | grep -vE '^[a-zA-Z0-9]+\.[a-zA-Z0-9\.]+$')

# Если есть приложения с неверным форматом, получаем правильные пакеты
if [ -n "$invalid_apps" ]; then
  replacement=$(su -c "dumpsys package | grep -B 20 \"/$invalid_apps\" | grep -oE '[^ ]+/$invalid_apps' | cut -d '/' -f 1 | sort | uniq")
fi

# Обновляем список приложений, заменяя неправильные на правильные пакеты
recent_app_cl="$recent_apps"
if [ -n "$invalid_apps" ] && [ -n "$replacement" ]; then
  recent_app_cl=$(echo "$recent_apps" | sed "s|$invalid_apps|$replacement|g")
fi

# Преобразуем список приложений в массив
apps_array=($(echo "$recent_app_cl" | tr '\n' ' '))

columns="id"
values="1"

# Создаем список колонок и значений для записи в базу данных
for i in "${!apps_array[@]}"; do
    column_name="ra$(($i + 1))"
    columns+=", $column_name"
    value="${apps_array[$i]}"
    values+=", \"$value\""
done


# Выполняем SQLite команду
sqlite3 "$DB_PATH" <<EOF
PRAGMA journal_mode = MEMORY;
BEGIN TRANSACTION;
DELETE FROM main WHERE id = 1;
INSERT INTO main ($columns)
VALUES ($values);
COMMIT;
EOF

# Окончание измерения времени
end_time=$(date +%s%3N)
execution_time=$((end_time - start_time))

# Финальный вывод после завершения скрипта
echo "Время выполнения скрипта: $execution_time мс"