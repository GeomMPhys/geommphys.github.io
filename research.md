---
title: Research
section: Research
description: An overview of the group's public research activity and areas of interest.
permalink: /research/
---

<div class="page-intro">
  <p>This section collects the group's public research activity, including publications, seminar activity, research visits, conferences and workshops, and awards.</p>
  <p class="page-intro__note">TODO: Add a concise public description of the group's research themes.</p>
</div>

<div class="grid grid--research">
  {% for area in site.data.research %}
    {% include research-area.html area=area %}
  {% endfor %}
</div>
