---
title: Awards and Honours
section: Research
description: Publicly listed awards, fellowships, and professional recognition received by group members.
permalink: /awards-honours/
---

{% assign all_people = site.data.people.researchers_madrid | concat: site.data.people.students_madrid | concat: site.data.people.international_collaborators | concat: site.data.people.visitors %}
{% if site.data.awards.awards and site.data.awards.awards.size > 0 %}
{% assign groups = site.data.awards.awards | group_by_exp: "a", "a.year" | sort: "name" | reverse %}
{% for group in groups %}
<h2>{{ group.name }}</h2>
<div class="record-list">
{% for award in group.items %}{% assign p = all_people | where: "id", award.person | first %}
<article class="record record--compact">
  <div class="record__body">
    <h3>{% if p %}{{ p.name }}{% else %}{{ award.person }}{% endif %}</h3>
    <p class="record__meta">{{ award.award }}</p>
    {% if award.category %}<p class="record__note">{{ award.category }}.</p>{% endif %}
  </div>
  <p class="record__date">{{ award.year }}</p>
</article>
{% endfor %}
</div>
{% endfor %}
{% else %}
<p class="empty">Awards and honours will be listed here.</p>
{% endif %}
