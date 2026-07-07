---
title: Research
section: Research
description: An overview of the group's public research activity and areas of interest.
permalink: /research/
---


<div class="grid grid--research">
  {% for area in site.data.research %}
    {% include research-area.html area=area %}
  {% endfor %}
</div>
