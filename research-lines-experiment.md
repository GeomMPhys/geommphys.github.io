---
title: Research Lines
section: Research
description: An experimental, interactive view of how our research lines connect geometry, mathematics, and physics.
permalink: /research-lines-experiment/
---

{% assign all_people = site.data.people.researchers_madrid | concat: site.data.people.students_madrid | concat: site.data.people.international_collaborators | concat: site.data.people.former_members | concat: site.data.people.visitors %}
{% assign initial_line = site.data.research_lines.lines | first %}
{% assign initial_placement = initial_line.placement %}

<section class="research-map" aria-label="Interactive map of research disciplines and lines">
  <div class="research-map__diagram">
    <svg class="research-map__bubbles" viewBox="0 0 900 650" role="img" aria-labelledby="research-map-title research-map-description">
      <title id="research-map-title">Three overlapping research disciplines</title>
      <desc id="research-map-description">Geometry, Mathematics, and Physics overlap. Select a research line marker to see its description and researchers.</desc>
      <circle class="research-map__bubble research-map__bubble--geometry" cx="300" cy="320" r="270" />
      <circle class="research-map__bubble research-map__bubble--math" cx="500" cy="275" r="270" />
      <circle class="research-map__bubble research-map__bubble--physics" cx="610" cy="380" r="270" />
      <g class="research-map__discipline-badge research-map__discipline-badge--geometry">
        <rect x="75" y="355" width="300" height="74" rx="5" />
        <image class="research-map__discipline-icon" href="{{ '/assets/images/people-icons/geom_icon.png' | relative_url }}" x="83" y="357" width="94" height="70" aria-hidden="true" />
        <text class="research-map__discipline" x="273" y="402">Geometry</text>
      </g>
      <g class="research-map__discipline-badge research-map__discipline-badge--math">
        <rect x="315" y="60" width="320" height="74" rx="5" />
        <image class="research-map__discipline-icon" href="{{ '/assets/images/people-icons/math_icon.png' | relative_url }}" x="323" y="62" width="94" height="70" aria-hidden="true" />
        <text class="research-map__discipline" x="520" y="107">Mathematics</text>
      </g>
      <g class="research-map__discipline-badge research-map__discipline-badge--physics">
        <rect x="660" y="390" width="225" height="74" rx="5" />
        <image class="research-map__discipline-icon" href="{{ '/assets/images/people-icons/physics_icon.png' | relative_url }}" x="668" y="392" width="86" height="70" aria-hidden="true" />
        <text class="research-map__discipline" x="808" y="437">Physics</text>
      </g>
    </svg>

    {% for line in site.data.research_lines.lines %}
      {% case line.placement %}
        {% when "geometry" %}{% assign marker_x = "25%" %}{% assign marker_y = "46%" %}
        {% when "math-physics" %}{% assign marker_x = "65%" %}{% assign marker_y = "34%" %}
        {% when "physics-geometry" %}{% assign marker_x = "51%" %}{% assign marker_y = "77%" %}
      {% endcase %}
      <button class="research-map__marker{% if line.id == initial_line.id %} is-selected{% endif %}"
        type="button" style="--marker-x: {{ marker_x }}; --marker-y: {{ marker_y }}"
        data-line-id="{{ line.id }}" aria-pressed="{% if line.id == initial_line.id %}true{% else %}false{% endif %}">
        <span class="research-map__marker-dot" aria-hidden="true"></span>
        <span class="research-map__marker-label">{{ line.name }}</span>
      </button>
    {% endfor %}
  </div>

  <article class="research-map__detail" aria-live="polite" aria-atomic="true">
    <p class="eyebrow" id="research-map-placement">
      {% case initial_placement %}
        {% when "geometry" %}Geometry
        {% when "math-physics" %}Mathematics · Physics
        {% when "physics-geometry" %}Physics · Geometry
      {% endcase %}
    </p>
    <h2 id="research-map-line-title">{{ initial_line.name }}</h2>
    {% if initial_line.keywords %}<p class="research-map__keywords" id="research-map-keywords">{{ initial_line.keywords | join: " · " }}</p>{% else %}<p class="research-map__keywords" id="research-map-keywords"></p>{% endif %}
    <p id="research-map-description-text">{{ initial_line.description }}</p>
    <div class="research-map__contributors">
      <h3>Researchers</h3>
      <ul id="research-map-people">
        {% for pid in initial_line.people %}
          {% assign person = all_people | where: "id", pid | first %}
          {% if person %}<li><a href="{{ '/people/' | relative_url }}#{{ pid }}">{{ person.name }}</a></li>{% endif %}
        {% endfor %}
      </ul>
    </div>
  </article>
</section>

<script type="application/json" id="research-map-lines">{{ site.data.research_lines.lines | jsonify }}</script>
<script type="application/json" id="research-map-people-data">{{ all_people | jsonify }}</script>
<script src="{{ '/assets/js/research-lines-map.js' | relative_url }}" defer></script>
