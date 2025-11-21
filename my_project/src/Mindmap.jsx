// MindMap.js
import React, { useEffect, useRef } from "react";
import * as d3 from "d3";

const MindMap = ({data}) => {
  const svgRef = useRef();

  useEffect(() => {
    /*const data = {
      name: "மனப்பகர்வு வழிகாட்டிகள்",
      children: [
        { name: "தெளிவானது" },
        { name: "மையம்" },
        { name: "பாணி" },
        { name: "பயன்பாடு" },
        { name: "முக்கிய சொற்கள்" },
        { name: "வரிகள்" },
      ],
    };*/

    const svg = d3.select(svgRef.current);
    svg.selectAll("*").remove(); // clear previous render

    const width = 800;
    const height = 600;
    const centerX = width / 2;
    const centerY = height / 2;

    const root = d3.hierarchy(data);
    const radius = 200;

    root.children.forEach((d, i) => {
      const angle = (i / root.children.length) * 2 * Math.PI;
      d.x = centerX + radius * Math.cos(angle);
      d.y = centerY + radius * Math.sin(angle);
    },[data]);

    // Draw links
    svg
      .selectAll(".link")
      .data(root.children)
      .enter()
      .append("line")
      .attr("class", "link")
      .attr("x1", centerX)
      .attr("y1", centerY)
      .attr("x2", (d) => d.x)
      .attr("y2", (d) => d.y)
      .attr("stroke", "#555")
      .attr("stroke-width", 2);

    // Draw child nodes
    svg
      .selectAll(".node.child")
      .data(root.children)
      .enter()
      .append("g")
      .attr("class", "node child")
      .attr("transform", (d) => `translate(${d.x}, ${d.y})`)
      .call((g) => {
        g.append("circle")
          .attr("r", 60)
          .attr("fill", "#03A9F4")
          .attr("stroke", "#0288D1")
          .attr("stroke-width", 2);

        g.append("text")
          .text((d) => d.data.name)
          .attr("text-anchor", "middle")
          .attr("alignment-baseline", "middle")
          .style("fill", "white")
          .style("font-size", "14px")
          .style("font-weight", "bold");
      });

    // Draw center node
    const center = svg
      .append("g")
      .attr("class", "node center")
      .attr("transform", `translate(${centerX}, ${centerY})`);

    center
      .append("circle")
      .attr("r", 80)
      .attr("fill", "#0288D1");

    center
      .append("text")
      .text(root.data.name)
      .attr("font-size", 14)
      .attr("fill", "white")
      .attr("text-anchor", "middle")
      .attr("alignment-baseline", "middle");

  }, []);

  return (
    <div style={{ textAlign: "center", margin: "2rem 0" }}>
      <svg ref={svgRef} width={800} height={600}></svg>
    </div>
  );
};

export default MindMap;
