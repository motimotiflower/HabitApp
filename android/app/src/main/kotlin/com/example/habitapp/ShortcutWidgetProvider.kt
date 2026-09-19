package com.example.habitapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

class ShortcutWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        ids.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.widget_shortcuts)
            views.setOnClickPendingIntent(R.id.shortcut_habit, WidgetIntents.open(context, "habit", 301))
            views.setOnClickPendingIntent(R.id.shortcut_task, WidgetIntents.open(context, "task", 302))
            views.setOnClickPendingIntent(R.id.shortcut_memo, WidgetIntents.open(context, "memo", 303))
            manager.updateAppWidget(id, views)
        }
    }
}
