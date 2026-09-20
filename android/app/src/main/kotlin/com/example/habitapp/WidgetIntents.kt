package com.example.habitapp

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews

data class WidgetRow(val text: String, val id: String)

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

    // ホーム画面上で完了状態を切り替えるBroadcastを作る
    fun toggle(
        context: Context,
        receiver: Class<*>,
        action: String,
        itemId: String,
        requestCode: Int
    ): PendingIntent {
        val intent = Intent(context, receiver).apply {
            this.action = action
            putExtra("item_id", itemId)
        }
        return PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }
}

private val rowIds = intArrayOf(
    R.id.widget_row1, R.id.widget_row2, R.id.widget_row3,
    R.id.widget_row4, R.id.widget_row5
)

fun fillRows(views: RemoteViews, lines: List<String>, emptyText: String) {
    rowIds.forEachIndexed { index, id ->
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

fun bindToggleRows(
    context: Context,
    views: RemoteViews,
    rows: List<WidgetRow>,
    action: String,
    requestCodeBase: Int
) {
    rowIds.forEachIndexed { index, viewId ->
        if (index < rows.size) {
            val receiver = if (action.contains("HABIT")) HabitWidgetProvider::class.java else TaskWidgetProvider::class.java
            views.setOnClickPendingIntent(
                viewId,
                WidgetIntents.toggle(context, receiver, action, rows[index].id, requestCodeBase + index)
            )
        }
    }
}
