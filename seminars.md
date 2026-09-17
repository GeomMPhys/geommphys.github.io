---
title: Group Seminars
section: Research
description: Talks in the Geometry and Mathematical Physics group seminar series.
permalink: /seminars/
math: true
---

{%- assign upcoming = site.data.seminars.upcoming -%}
{%- assign past = site.data.seminars.past -%}

{%- comment -%}
  Between terms `upcoming` is empty, and that is the normal state rather than an
  edge case — so when it is, the page leads with the empty state and goes
  straight to the talks that did happen. The count comes from the data, so it
  cannot go stale.
{%- endcomment -%}

{% if upcoming and upcoming.size > 0 %}
<h2>Upcoming</h2>
<div class="stack">
  {% for seminar in upcoming %}{% include seminar-item.html seminar=seminar %}{% endfor %}
</div>

<h2>Past</h2>
{% else %}
<p class="empty">Nothing is scheduled at the moment.{% if past and past.size > 0 %} The group has held {{ past.size }} seminars.{% endif %}</p>
{% endif %}

{% if past and past.size > 0 %}
<div class="stack">
  {% for seminar in past %}{% include seminar-item.html seminar=seminar %}{% endfor %}
</div>
{% elsif upcoming == nil or upcoming.size == 0 %}
{% else %}
<p class="empty">Past seminars can be archived here.</p>
{% endif %}
