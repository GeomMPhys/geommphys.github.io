---
title: Research
section: Research
description: An overview of the group's public research activity and areas of interest.
permalink: /research/
---

The current public Google Sites research page is primarily a directory of research activity. A concise description of the group's research themes is not provided there.

<div class="grid grid--research">
  {% for area in site.data.research %}
    {% include research-area.html area=area %}
  {% endfor %}
</div>
