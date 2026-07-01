---
title: Conferences and Workshops
section: Research
description: Conferences, workshops, and schools organized with members of the group.
permalink: /conferences-workshops/
---

{% assign all_people = site.data.people.researchers_madrid | concat: site.data.people.students_madrid | concat: site.data.people.international_collaborators | concat: site.data.people.visitors %}
{% if site.data.workshops.events and site.data.workshops.events.size > 0 %}
{% assign groups = site.data.workshops.events | group_by_exp: "e", "e.start | date: '%Y'" | sort: "name" | reverse %}
{% for group in groups %}
<h2>{{ group.name }}</h2>
<div class="record-list">
{% for event in group.items %}{% include workshop.html event=event people=all_people %}{% endfor %}
</div>
{% endfor %}
{% else %}
<p class="empty">Conferences and workshops will be listed here.</p>
{% endif %}
