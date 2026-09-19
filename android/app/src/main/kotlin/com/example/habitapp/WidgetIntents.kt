package com.example.habitapp

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews

object WidgetIntents {
    fun open(context: Context, action: String, requestCode: Int): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("widget_action", action)
        }
        return PendingIntent.getActivity(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }
}

fun fillRows(views: RemoteViews, lines: List<String>, emptyText: String) {
    val ids = intArrayOf(R.id.widget_row1, R.id.widget_row2, R.id.widget_row3, R.id.widget_row4, R.id.widget_row5)
    ids.forEachIndexed { index, id ->
        if (index < lines.size) {
            views.setViewVisibility(id, View.VISIBLE)
            views.setTextViewText(id, lines[index])
        } else if (index == 0 && lines.isEmpty()) {
            views.setViewVisibility(id, View.VISIBLE)
            views.setTextViewText(id, emptyText)
        } else {
            views.setViewVisibility(id, View.GONE)
        }
    }
}
