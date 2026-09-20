package com.example.habitapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import org.json.JSONArray
import java.text.SimpleDateFormat
import java.util.Locale

class TaskWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        ids.forEach { manager.updateAppWidget(it, build(context)) }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action != ACTION_TOGGLE_TASK) return

        val taskId = intent.getStringExtra(EXTRA_ID) ?: return
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val raw = prefs.getString("flutter.tasks", null) ?: return
        val array = JSONArray(raw)

        // 押されたタスクの完了状態を反転する
        for (i in 0 until array.length()) {
            val item = array.getJSONObject(i)
            if (item.optString("id") != taskId) continue
            item.put("isDone", !item.optBoolean("isDone", false))
            break
        }

        prefs.edit().putString("flutter.tasks", array.toString()).apply()
        updateAll(context)
    }

    companion object {
        private const val ACTION_TOGGLE_TASK = "com.example.habitapp.TOGGLE_TASK"
        private const val EXTRA_ID = "item_id"

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
            val tasks = mutableListOf<Triple<String, String?, String>>()

            if (raw != null) {
                val array = JSONArray(raw)
                for (i in 0 until array.length()) {
                    val item = array.getJSONObject(i)
                    if (item.optBoolean("isDone", false)) continue
                    val deadline = item.optString("deadline").takeIf { it.isNotBlank() && it != "null" }
                    tasks.add(Triple(item.optString("title"), deadline, item.optString("id")))
                }
            }

            // 期限が近いものを上に表示
            tasks.sortWith(Comparator { a, b ->
                when {
                    a.second == null && b.second == null -> 0
                    a.second == null -> 1
                    b.second == null -> -1
                    else -> a.second!!.compareTo(b.second!!)
                }
            })

            val input = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.JAPAN)
            val output = SimpleDateFormat("M/d", Locale.JAPAN)
            val rows = tasks.take(5).map { (title, deadline, id) ->
                val date = deadline?.let {
                    try { output.format(input.parse(it)!!) } catch (_: Exception) { "" }
                } ?: ""
                WidgetRow("☐  $title" + if (date.isNotEmpty()) "   $date" else "", id)
            }

            fillRows(views, rows.map { it.text }, "未完了のタスクはありません")
            bindToggleRows(context, views, rows, ACTION_TOGGLE_TASK, 2000)
            return views
        }
    }
}
