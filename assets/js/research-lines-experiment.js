(() => {
  const linesNode = document.getElementById("research-lines-experiment-data");
  const peopleNode = document.getElementById("research-lines-experiment-people");
  const workspace = document.querySelector(".research-lines-experiment__workspace");
  if (!linesNode || !peopleNode || !workspace) return;

  const lines = JSON.parse(linesNode.textContent);
  const people = JSON.parse(peopleNode.textContent);
  const labels = {
    "geometry-physics": "Geometry · Physics",
    "geometry-math": "Geometry · Mathematics",
    "math-physics": "Mathematics · Physics"
  };
  const title = document.getElementById("research-lines-experiment-title");
  const placement = document.getElementById("research-lines-experiment-placement");
  const keywords = document.getElementById("research-lines-experiment-keywords");
  const description = document.getElementById("research-lines-experiment-description");
  const memberList = document.getElementById("research-lines-experiment-members");
  const detail = document.querySelector(".research-lines-experiment__detail");
  const connector = document.querySelector(".research-lines-experiment__connector");
  const connectorPath = connector.querySelector("path");
  const points = [...document.querySelectorAll(".research-lines-experiment__point")];

  function drawConnector() {
    if (window.matchMedia("(max-width: 980px)").matches) return;
    const selected = document.querySelector(".research-lines-experiment__point.is-selected");
    if (!selected) return;

    const workspaceRect = workspace.getBoundingClientRect();
    const pointRect = selected.getBoundingClientRect();
    const headerRect = detail.querySelector("header").getBoundingClientRect();
    const startX = pointRect.left + pointRect.width / 2 - workspaceRect.left;
    const startY = pointRect.top + pointRect.height / 2 - workspaceRect.top;
    const endX = headerRect.left - workspaceRect.left;
    const endY = headerRect.top + headerRect.height / 2 - workspaceRect.top;
    const bend = Math.max(24, (endX - startX) * 0.48);

    connector.setAttribute("viewBox", `0 0 ${workspaceRect.width} ${workspaceRect.height}`);
    connectorPath.setAttribute("d", `M ${startX} ${startY} C ${startX + bend} ${startY}, ${endX - bend} ${endY}, ${endX} ${endY}`);
    workspace.style.setProperty("--connector-color", getComputedStyle(selected).getPropertyValue("--point-color"));
  }

  function selectLine(id) {
    const line = lines.find((item) => item.id === id);
    if (!line) return;

    title.textContent = line.name;
    placement.textContent = labels[line.placement] || "Research line";
    detail.dataset.placement = line.placement;
    keywords.textContent = (line.keywords || []).join(" · ");
    description.textContent = line.description;
    memberList.replaceChildren();

    [
      { label: "Researchers", people: people.researchers },
      { label: "PhD students", people: people.students }
    ].forEach((group) => {
      const members = (line.people || [])
        .map((personId) => group.people.find((person) => person.id === personId))
        .filter(Boolean);
      if (!members.length) return;

      const section = document.createElement("section");
      section.className = "research-lines-experiment__member-group";
      const heading = document.createElement("h4");
      heading.textContent = group.label;
      const list = document.createElement("ul");
      members.forEach((person) => {
        const item = document.createElement("li");
        const link = document.createElement("a");
        link.href = `/people/#${encodeURIComponent(person.id)}`;
        link.textContent = person.name;
        item.append(link);
        list.append(item);
      });
      section.append(heading, list);
      memberList.append(section);
    });

    points.forEach((point) => {
      const selected = point.dataset.lineId === id;
      point.classList.toggle("is-selected", selected);
      point.setAttribute("aria-pressed", String(selected));
    });

    drawConnector();
  }

  points.forEach((point) => {
    point.addEventListener("click", () => selectLine(point.dataset.lineId));
    point.addEventListener("pointerenter", () => selectLine(point.dataset.lineId));
    point.addEventListener("focus", () => selectLine(point.dataset.lineId));
  });

  window.addEventListener("resize", drawConnector);
  window.addEventListener("load", drawConnector, { once: true });
  selectLine(lines[0]?.id);
})();
