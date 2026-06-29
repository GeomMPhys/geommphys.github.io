---
title: Contact
section: Contact
description: Public contact information for the GeomMPhys research group.
permalink: /contact/
published: false
---

<div class="contact-layout">
  <section>
    <h2>{{ site.data.site.group_name }}</h2>
    <p>{{ site.data.site.department }}<br>{{ site.data.site.institution }}</p>
    <address>
      {% for line in site.data.site.address %}
        {{ line }}<br>
      {% endfor %}
    </address>
    <p class="links links--large">
      <a href="mailto:{{ site.data.site.email }}">{{ site.data.site.email }}</a>
      {% if site.data.site.map_url %}<a href="{{ site.data.site.map_url }}">Map</a>{% endif %}
    </p>
  </section>

  <section class="card">
    <h2>Visitors</h2>
    <p>{{ site.data.contact.visitors }}</p>
    <h2>Directions</h2>
    <p>{{ site.data.contact.directions }}</p>
    <h2>Administration</h2>
    <p>{{ site.data.contact.administration }}</p>
  </section>
</div>
