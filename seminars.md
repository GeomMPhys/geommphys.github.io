---
title: Group Seminars
section: Research
description: Talks in the Geometry and Mathematical Physics group seminar series.
permalink: /seminars/
---

<h2>Upcoming</h2>
{% if site.data.seminars.upcoming and site.data.seminars.upcoming.size > 0 %}
  <div class="stack">
    {% for seminar in site.data.seminars.upcoming %}
      {% include seminar-item.html seminar=seminar %}
    {% endfor %}
  </div>
{% else %}
  <p class="empty">Upcoming seminars will be posted here.</p>
{% endif %}

<h2>Past</h2>
{% if site.data.seminars.past and site.data.seminars.past.size > 0 %}
  <div class="stack">
    {% for seminar in site.data.seminars.past %}
      {% include seminar-item.html seminar=seminar %}
    {% endfor %}
  </div>
{% else %}
  <p class="empty">Past seminars can be archived here.</p>
{% endif %}
