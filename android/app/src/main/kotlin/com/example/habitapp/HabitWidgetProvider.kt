package com.example.habitapp

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import org.json.JSONArray
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class HabitWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        ids.forEach { manager.updateAppWidget(it, build(context)) }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action != ACTION_TOGGLE_HABIT) return

        val habitId = intent.getStringExtra(EXTRA_ID) ?: return
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val raw = prefs.getString("flutter.habits", null) ?: return
        val array = JSONArray(raw)
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.JAPAN).format(Date())

        // 押された習慣の「今日」の達成状態だけを反転する
        for (i in 0 until array.length()) {
            val item = array.getJSONObject(i)
            if (item.optString("id") != habitId) continue
            val history = item.optJSONObject("completionHistory")
                ?: org.json.JSONObject().also { item.put("completionHistory", it) }
            history.put(today, !history.optBoolean(today, false))
            break
        }

        prefs.edit().putString("flutter.habits", array.toString()).apply()
        updateAll(context)
    }

    companion object {
        private const val ACTION_TOGGLE_HABIT = "com.example.habitapp.TOGGLE_HABIT"
        private const val EXTRA_ID = "item_id"

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, HabitWidgetProvider::class.java)
            manager.getAppWidgetIds(component).forEach { manager.updateAppWidget(it, build(context)) }
        }

        private fun build(context: Context): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.widget_list)
            views.setTextViewText(R.id.widget_title, "今日の習慣")
            views.setTextViewText(R.id.widget_add, "＋")
            views.setOnClickPendingIntent(R.id.widget_title, WidgetIntents.open(context, "habit", 101))
            views.setOnClickPendingIntent(R.id.widget_add, WidgetIntents.open(context, "habit_add", 102))

            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val raw = prefs.getString("flutter.habits", null)
            val day = arrayOf("月", "火", "水", "木", "金", "土", "日")[java.util.Calendar.getInstance().get(java.util.Calendar.DAY_OF_WEEK).let { if (it == 1) 6 else it - 2 }]
            val today = SimpleDateFormat("yyyy-MM-dd", Locale.JAPAN).format(Date())
            val rows = mutableListOf<WidgetRow>()

            if (raw != null) {
                val array = JSONArray(raw)
                for (i in 0 until array.length()) {
                    val item = array.getJSONObject(i)
                    val days = item.optJSONArray("days") ?: JSONArray()
                    var matches = false
                    for (j in 0 until days.length()) if (days.optString(j) == day) matches = true
                    if (!matches) continue

                    val done = item.optJSONObject("completionHistory")?.optBoolean(today, false) ?: false
                    rows.add(WidgetRow((if (done) "☑  " else "☐  ") + item.optString("title"), item.optString("id")))
                    if (rows.size == 5) break
                }
            }

            fillRows(views, rows.map { it.text }, "今日の習慣はありません")
            bindToggleRows(context, views, rows, ACTION_TOGGLE_HABIT, 1000)
            return views
        }
    }
}
