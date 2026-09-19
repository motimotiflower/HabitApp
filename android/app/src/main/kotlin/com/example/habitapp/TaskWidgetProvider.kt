package com.example.habitapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.widget.RemoteViews
import org.json.JSONArray
import java.text.SimpleDateFormat
import java.util.Locale

class TaskWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        ids.forEach { manager.updateAppWidget(it, build(context)) }
    }

    companion object {
        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, TaskWidgetProvider::class.java)
            manager.getAppWidgetIds(component).forEach { manager.updateAppWidget(it, build(context)) }
        }

        private fun build(context: Context): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.widget_list)
            views.setTextViewText(R.id.widget_title, "タスク")
            views.setTextViewText(R.id.widget_add, "＋")
            views.setOnClickPendingIntent(R.id.widget_title, WidgetIntents.open(context, "task", 201))
            views.setOnClickPendingIntent(R.id.widget_add, WidgetIntents.open(context, "task_add", 202))

            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val raw = prefs.getString("flutter.tasks", null)
            val tasks = mutableListOf<Pair<String, String?>>()

            if (raw != null) {
                val array = JSONArray(raw)
                for (i in 0 until array.length()) {
                    val item = array.getJSONObject(i)
                    if (item.optBoolean("isDone", false)) continue
                    val deadline = item.optString("deadline").takeIf { it.isNotBlank() && it != "null" }
                    tasks.add(item.optString("title") to deadline)
                }
            }

            // 期限が近いものを上に表示
            tasks.sortWith(compareBy(nullsLast()) { it.second })
            val input = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.JAPAN)
            val output = SimpleDateFormat("M/d", Locale.JAPAN)
            val lines = tasks.take(5).map { (title, deadline) ->
                val date = deadline?.let {
                    try { output.format(input.parse(it)!!) } catch (_: Exception) { "" }
                } ?: ""
                "□  $title" + if (date.isNotEmpty()) "   $date" else ""
            }

            fillRows(views, lines, "未完了のタスクはありません")
            views.setOnClickPendingIntent(R.id.widget_body, WidgetIntents.open(context, "task", 203))
            return views
        }
    }
}
