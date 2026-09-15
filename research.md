---
title: Research
section: Research
description: An overview of the group's public research activity and areas of interest.
permalink: /research/
---

<figure class="page-figure">
  <img src="{{ '/assets/images/research-blackboard.jpeg' | relative_url }}" width="1575" height="514" alt="A blackboard covered in handwritten equations and diagrams." loading="lazy">
</figure>

<div class="grid grid--research">
  {% for area in site.data.research %}
    {% include research-area.html area=area %}
  {% endfor %}
</div>
