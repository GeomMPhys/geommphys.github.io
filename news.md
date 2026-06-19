---
title: News
section: Updates
description: Group announcements and updates.
permalink: /news/
---

The current public Google Sites page does not contain a dedicated news section.

{% assign items = site.news | sort: "date" | reverse %}

{% if items and items.size > 0 %}
  <div class="news-list">
    {% for item in items %}
      {% include news-card.html item=item %}
    {% endfor %}
  </div>
{% else %}
  <p class="empty">TODO: Add public news posts in the <code>_news</code> folder.</p>
{% endif %}
