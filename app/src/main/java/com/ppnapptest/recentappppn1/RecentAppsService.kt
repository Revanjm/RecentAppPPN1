package com.ppnapptest.recentappppn1

import android.annotation.SuppressLint
import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.util.Log
import android.widget.Toast
import com.topjohnwu.superuser.Shell
import kotlinx.coroutines.*

@SuppressLint("ForegroundServiceType")
class RecentAppsService : Service() {

    private lateinit var repository: RecentAppsRepository
    private var scriptJob: Job? = null
    private var updateJob: Job? = null
    private val serviceScope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    override fun onCreate() {
        super.onCreate()
        repository = RecentAppsRepository(this)

        Toast.makeText(this, "Сервис RecentAppsService запущен", Toast.LENGTH_SHORT).show()

        val notificationHelper = NotificationHelper(this)
        val notification = notificationHelper.createNotification()
        startForeground(1, notification)
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startExecutingCommand()
        startUpdatingRecentApps()
        return START_STICKY
    }

    private fun startExecutingCommand() {
        scriptJob = serviceScope.launch(Dispatchers.IO) {
            while (isActive) {
                try {
                    val shell = Shell.getShell()
                    if (shell.isRoot) {
                        val result = Shell.cmd("su -c '/system/bin/sh /storage/emulated/0/.recentappppn1/.sh/updatMainRA.sh'").exec()

                        if (result.isSuccess) {
                            Log.d("RecentAppsService", "Скрипт успешно выполнен")
                            repository.updateRecentApps()
                        } else {
                            Log.e("RecentAppsService", "Ошибка выполнения скрипта: ${result.code} - ${result.err}")
                            withContext(Dispatchers.Main) {
                                Toast.makeText(this@RecentAppsService, "Ошибка выполнения скрипта", Toast.LENGTH_SHORT).show()
                            }
                        }
                    } else {
                        Log.e("RecentAppsService", "Root права не получены")
                        withContext(Dispatchers.Main) {
                            Toast.makeText(this@RecentAppsService, "Нет root прав", Toast.LENGTH_SHORT).show()
                        }
                    }
                } catch (e: Exception) {
                    Log.e("RecentAppsService", "Ошибка: ${e.message}")
                    withContext(Dispatchers.Main) {
                        Toast.makeText(this@RecentAppsService, "Ошибка: ${e.message}", Toast.LENGTH_SHORT).show()
                    }
                }
                delay(3000L)
            }
        }
    }

    private fun startUpdatingRecentApps() {
        updateJob = serviceScope.launch {
            while (isActive) {
                repository.updateRecentApps()
                delay(1000L)
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        scriptJob?.cancel()
        updateJob?.cancel()
        serviceScope.cancel()
        Toast.makeText(this, "Сервис RecentAppsService завершён", Toast.LENGTH_SHORT).show()
    }
}
