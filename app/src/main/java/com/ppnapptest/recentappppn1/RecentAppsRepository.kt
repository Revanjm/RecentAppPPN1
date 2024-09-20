package com.ppnapptest.recentappppn1

import android.content.Context
import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData

class RecentAppsRepository(private val context: Context) {

    private val _recentApps = MutableLiveData<List<String>>()
    val recentApps: LiveData<List<String>> = _recentApps

    fun updateRecentApps() {
        val dbHelper = RecentAppsDbHelper(context)
        val recentAppsList = dbHelper.getRecentApps()
        Log.d("RecentAppsRepository", "Recent apps list: $recentAppsList")
        _recentApps.postValue(recentAppsList) // Изменено на postValue
    }
}
