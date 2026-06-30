---
title: Research Lines
section: Research
description: The group's main research lines and the members working on them.
permalink: /research-lines/
---

{% assign all_people = site.data.people.researchers_madrid | concat: site.data.people.students_madrid | concat: site.data.people.international_collaborators | concat: site.data.people.visitors %}

{% if site.data.research_lines.lines and site.data.research_lines.lines.size > 0 %}
<div class="stack">
  {% for line in site.data.research_lines.lines %}
    {% include research-line.html line=line people=all_people %}
  {% endfor %}
</div>
{% else %}
<p class="empty">Research lines will be listed here.</p>
{% endif %}
