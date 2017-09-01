$( document ).ready(function() {
var width = 1200,
    height = 900;

var nodeSize = 9;
var strokeWidth = 2;

var color = d3.scale.ordinal()
  .domain([0,1,2])
  .range(["#f79000","#99b62A","#41c7DB"]);

var force = d3.layout.force()
    .charge(-630)
    .linkStrength(0.6)
    .gravity(.05)
    .linkDistance(40)
    .size([width, height]);

var title = d3.select("body").append("div")
    .attr('width', width)


var svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height);


var graph = data;
  force
      .nodes(graph.nodes)
      .links(graph.links)
      .start();

  var link = svg.selectAll(".link")
      .data(graph.links)
    .enter().append("line")
      .attr("class", "link")
      .style("stroke-width", function(link) {return link.weight});

  var nodes = svg.selectAll(".node")
      .data(graph.nodes)
    .enter().append("circle")
      .attr("class", "node")
      .attr("r", function(node) { return node.usage * 1.1; })
      .style("fill", function(node) { return color(node.category); })
      .call(force.drag);

  nodes.append("title")
      .text(function(d) { return d.name  + " \nlinks: " + d.usage; });


  // mouse events

  nodes.on('mouseover', function(node){
    // grow node by 1.2 on hoovering.
    d3.select(this).transition()
      .duration(200)
      .attr('r', (node.usage * 1.1 * 1.2));

     // grow ancient links stroke and stroke width.
     link.style('stroke-width', function(l) {
        if (node === l.source || node === l.target)
          return l.weight * 1.1;
        else
          return l.weight;
        });
      link.style('stroke', function(l) {
        if (node === l.source || node === l.target)
          return color(node.value);
      else
          return "#999";
      });
   });

  nodes.on('mouseout', function(node){
    d3.select(this).attr('r', node.usage * 1.1 ) ;
    link.style('stroke-width', function(link) {return link.weight});
    link.style('stroke', "#999");
   });


  force.on("tick", function(e) {
    var k = 10 * e.alpha;
     nodes.forEach(function(o, i) {
      o.x += i & 2 ? k : -k;
      o.y += i & 1 ? k : -k;
     });

    link.attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });

    nodes.attr("cx", function(d) { return d.x; })
        .attr("cy", function(d) { return d.y; });


  });
});
