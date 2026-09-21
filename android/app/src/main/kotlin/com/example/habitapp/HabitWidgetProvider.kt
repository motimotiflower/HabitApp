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
import java.util.Calendar
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
            val weekdays = arrayOf("月", "火", "水", "木", "金", "土", "日")
            val formatter = SimpleDateFormat("yyyy-MM-dd", Locale.JAPAN)
            val todayDate = Date()
            val today = formatter.format(todayDate)
            val calendar = Calendar.getInstance()
            val day = weekdays[calendar.get(Calendar.DAY_OF_WEEK).let { if (it == 1) 6 else it - 2 }]
            val rows = mutableListOf<WidgetRow>()

            if (raw != null) {
                val array = JSONArray(raw)
                val candidates = mutableListOf<Triple<Int, Int, WidgetRow>>()

                for (i in 0 until array.length()) {
                    val item = array.getJSONObject(i)
                    val startedAt = item.optString("startedAt").takeIf { it.isNotBlank() && it != "null" }
                    val archivedAt = item.optString("archivedAt").takeIf { it.isNotBlank() && it != "null" }
                    if (startedAt != null && startedAt.substringBefore("T") > today) continue
                    if (archivedAt != null && archivedAt.substringBefore("T") <= today) continue

                    val skipped = item.optJSONArray("skippedDates") ?: JSONArray()
                    fun isSkipped(key: String): Boolean {
                        for (j in 0 until skipped.length()) if (skipped.optString(j) == key) return true
                        return false
                    }

                    val days = item.optJSONArray("days") ?: JSONArray()
                    fun scheduled(weekday: String): Boolean {
                        for (j in 0 until days.length()) if (days.optString(j) == weekday) return true
                        return false
                    }

                    var sourceKey: String? = null
                    if (scheduled(day) && !isSkipped(today)) {
                        sourceKey = today
                    } else if (item.optBoolean("carryOverIfIncomplete", false)) {
                        //直近の設定日から次の設定日前までだけ、未達成を引き継ぐ
                        for (offset in 1..7) {
                            val previous = Calendar.getInstance().apply { add(Calendar.DAY_OF_YEAR, -offset) }
                            val previousDay = weekdays[previous.get(Calendar.DAY_OF_WEEK).let { if (it == 1) 6 else it - 2 }]
                            val key = formatter.format(previous.time)
                            if (!scheduled(previousDay)) continue
                            if (!isSkipped(key)) sourceKey = key
                            break
                        }
                    }

                    if (sourceKey == null) continue
                    val done = item.optJSONObject("completionHistory")?.optBoolean(sourceKey, false) ?: false
                    if (sourceKey != today && done) continue

                    val priority = item.optInt("priority", 2)
                    candidates.add(
                        Triple(
                            priority,
                            i,
                            WidgetRow((if (done) "☑  " else "☐  ") + item.optString("title"), item.optString("id"))
                        )
                    )
                }

                //アプリと同じく優先度順。同じ優先度は保存順を保つ
                candidates.sortWith(compareByDescending<Triple<Int, Int, WidgetRow>> { it.first }.thenBy { it.second })
                rows.addAll(candidates.take(5).map { it.third })
            }

            fillRows(views, rows.map { it.text }, "今日の習慣はありません")
            bindToggleRows(context, views, rows, ACTION_TOGGLE_HABIT, 1000)
            return views
        }
    }
}
